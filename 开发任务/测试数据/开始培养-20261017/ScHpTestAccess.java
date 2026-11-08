import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

/** One-time test provisioning, explicitly approved by the user on 2026-10-17. No login secrets touched. */
class ScHpTestAccess {
 static final long USER=1307496099426209792L, ROLE=861017901L;
 static long scalar(Connection c,String sql)throws Exception {try(var s=c.createStatement();var r=s.executeQuery(sql)){if(!r.next())throw new IllegalStateException("Missing expected row");return r.getLong(1);}}
 static void require(boolean ok,String message){if(!ok)throw new IllegalStateException(message);}
 static void snapshot(Connection c,Path dir,String name,String query)throws Exception {
  try(var s=c.createStatement();var r=s.executeQuery(query);var w=Files.newBufferedWriter(dir.resolve(name+".base64.tsv"))){
   var m=r.getMetaData();for(int i=1;i<=m.getColumnCount();i++){if(i>1)w.write('\t');w.write(m.getColumnName(i));}w.newLine();
   while(r.next()){for(int i=1;i<=m.getColumnCount();i++){if(i>1)w.write('\t');byte[] b=r.getBytes(i);w.write(b==null?"NULL":Base64.getEncoder().encodeToString(b));}w.newLine();}
  }
 }
 public static void main(String[] args)throws Exception {
  var cfg=new HashMap<String,String>();for(String raw:Files.readAllLines(Path.of(args[0]),StandardCharsets.UTF_8)){String l=raw.replace("\uFEFF","").trim();int p=l.indexOf(':');if(p>0)cfg.put(l.substring(0,p).trim(),l.substring(p+1).trim());}
  String url=cfg.get("url");require(url!=null&&url.matches("jdbc:mysql://[^/]+/ymsw_v2(?:\\?.*)?"),"Unexpected database");
  var props=new Properties();props.setProperty("user",cfg.get("username"));props.setProperty("password",cfg.get("password"));props.setProperty("connectTimeout","5000");props.setProperty("socketTimeout","20000");
  Path out=Path.of(args[1]);
  try(var c=DriverManager.getConnection(url,props)){
   c.createStatement().execute("SET time_zone='+00:00'");c.setAutoCommit(false);
   try {
    require(scalar(c,"SELECT DATE(CONVERT_TZ(UTC_TIMESTAMP(),'+00:00','+08:00'))='2026-10-17'")==1,"Test day expired");
    long rev=scalar(c,"SELECT revision FROM sys_management_revision WHERE scope_key='SYSTEM' FOR UPDATE");
    require(scalar(c,"SELECT user_id FROM sys_user WHERE user_id="+USER+" AND user_name='houpan' AND status='0' AND del_flag='0' FOR UPDATE")==USER,"User changed");
    long pv=scalar(c,"SELECT object_version FROM res_project WHERE project_id=861017001 AND project_code='SC-20261017' AND del_flag='0' FOR UPDATE");
    require(scalar(c,"SELECT COUNT(*) FROM sys_role WHERE role_id="+ROLE+" OR role_key='sc_test_hp_20261017' OR role_name='开始培养测试-hp-1017'")==0,"Role already exists");
    require(scalar(c,"SELECT COUNT(*) FROM sys_menu WHERE menu_id IN (1306294778882822145,1306294778882822146,1306294778882822147) AND perms IN ('run:workflow:query','run:workflow:start','run:workflow:operate') AND status='0'")==3,"Workflow permissions changed");
    require(scalar(c,"SELECT COUNT(*) FROM sys_user_lab WHERE user_id="+USER+" AND lab_id IN (11001,11002) AND auth_type='0'")==2,"Lab permission changed");
    require(scalar(c,"SELECT COUNT(*) FROM res_project_member WHERE project_id=861017001 AND user_id="+USER)==0,"Member already exists");
    Path backup=out.resolve("db-before-hp-access");Files.createDirectory(backup);
    snapshot(c,backup,"sys_role","SELECT * FROM sys_role WHERE role_id="+ROLE);
    snapshot(c,backup,"sys_role_menu","SELECT * FROM sys_role_menu WHERE role_id="+ROLE);
    snapshot(c,backup,"sys_user_role","SELECT * FROM sys_user_role WHERE user_id="+USER);
    snapshot(c,backup,"sys_user_lab","SELECT * FROM sys_user_lab WHERE user_id="+USER);
    snapshot(c,backup,"res_project_member","SELECT * FROM res_project_member WHERE project_id=861017001");
    snapshot(c,backup,"res_project","SELECT project_id,object_version,update_by,update_time FROM res_project WHERE project_id=861017001");
    snapshot(c,backup,"sys_management_revision","SELECT * FROM sys_management_revision WHERE scope_key='SYSTEM'");
    String[] sql={
     "INSERT INTO sys_role(role_id,role_name,role_key,role_sort,data_scope,menu_check_strictly,dept_check_strictly,status,del_flag,create_by,create_time,remark) VALUES ("+ROLE+",'开始培养测试-hp-1017','sc_test_hp_20261017',99,'5',1,1,'0','0','SC_TEST_SETUP',UTC_TIMESTAMP(),'User-approved test provisioning 2026-10-17; assigned only to houpan; three workflow permissions only')",
     "INSERT INTO sys_role_menu(role_id,menu_id) VALUES ("+ROLE+",1306294778882822145),("+ROLE+",1306294778882822146),("+ROLE+",1306294778882822147)",
     "INSERT INTO sys_user_role(user_id,role_id,assigned_at) VALUES ("+USER+","+ROLE+",UTC_TIMESTAMP(3))",
     "UPDATE sys_user_lab SET auth_type='1',update_by='SC_TEST_SETUP',update_time=UTC_TIMESTAMP() WHERE user_id="+USER+" AND lab_id IN (11001,11002) AND auth_type='0'",
     "INSERT INTO res_project_member(project_id,user_id,permission_type,expire_date,source_type,joined_time,grant_type,granted_at,selection_origin,selection_ref) VALUES (861017001,"+USER+",'member','2026-10-17','direct',UTC_TIMESTAMP(),'MEMBER',UTC_TIMESTAMP(3),'USER','SC_TEST_SETUP:user-approved-20261017')",
     "UPDATE res_project SET object_version=object_version+1,update_by='SC_TEST_SETUP',update_time=UTC_TIMESTAMP() WHERE project_id=861017001 AND object_version="+pv,
     "UPDATE sys_management_revision SET revision=revision+1,update_time=UTC_TIMESTAMP(3) WHERE scope_key='SYSTEM' AND revision="+rev
    };
    int[] expected={1,3,1,2,1,1,1};
    for(int i=0;i<sql.length;i++){try(var s=c.createStatement()){require(s.executeUpdate(sql[i])==expected[i],"Unexpected row count at statement "+(i+1));}}
    c.commit();Files.writeString(out.resolve("db-hp-access-success.txt"),java.time.Instant.now()+" user="+USER+" role="+ROLE+" statements=7 revision="+(rev+1)+"\n");
    System.out.println("hp test access committed: 3 workflow permissions, 2 lab OPERATE grants, 1 test project MEMBER through 2026-10-17; revision="+(rev+1));
   }catch(Exception e){c.rollback();throw e;}
  }catch(SQLException e){System.err.println("Provision failed: SQLState="+e.getSQLState()+" vendorCode="+e.getErrorCode());System.exit(2);}
 }
}
