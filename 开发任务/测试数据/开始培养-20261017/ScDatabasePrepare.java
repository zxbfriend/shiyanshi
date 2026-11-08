import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;
import java.io.*;

/** Bounded one-time preparation of the explicitly authorized existing test DB. No credentials in output. */
class ScDatabasePrepare {
 static final String[] TABLES={"res_culture","run_workflow_instance","workflow_node","workflow_subflow","workflow_step","res_project","res_project_lab","res_batch","res_culture_occupancy","dev_bench_reactor","dev_integrated_reactor","lab_bench_reactor","lab_bench_reactor_controller","lab_floor_scale","lab_integrated_reactor"};
 static long scalar(Connection c,String sql)throws Exception{try(var s=c.createStatement();var r=s.executeQuery(sql)){r.next();return r.getLong(1);}}
 static void require(boolean ok,String message){if(!ok)throw new IllegalStateException(message);}
 static void backup(Connection c,Path dir)throws Exception{
  Files.createDirectory(dir);
  for(String table:TABLES){
   require(scalar(c,"SELECT COUNT(*) FROM "+table)<=10000,"Backup row bound exceeded");
   try(var s=c.createStatement();var r=s.executeQuery("SHOW CREATE TABLE "+table)){r.next();Files.writeString(dir.resolve(table+".ddl.sql"),r.getString(2)+";\n");}
   try(var s=c.createStatement();var r=s.executeQuery("SELECT * FROM "+table);var w=Files.newBufferedWriter(dir.resolve(table+".base64.tsv"))){
    var m=r.getMetaData();for(int i=1;i<=m.getColumnCount();i++){if(i>1)w.write('\t');w.write(m.getColumnName(i));}w.newLine();
    while(r.next()){for(int i=1;i<=m.getColumnCount();i++){if(i>1)w.write('\t');byte[] bytes=r.getBytes(i);w.write(bytes==null?"NULL":Base64.getEncoder().encodeToString(bytes));}w.newLine();}
   }
  }
  Files.writeString(dir.resolve("README.txt"),"Pre-change existing-test-DB snapshot. TSV header has column names, each value Base64 encoded, NULL literal for SQL NULL. Includes generated columns: omit those on restore. Review newer user data before any restore. No automatic rollback or DROP.\n");
 }
 public static void main(String[] args)throws Exception{
  var config=new HashMap<String,String>();for(String raw:Files.readAllLines(Path.of(args[0]),StandardCharsets.UTF_8)){String l=raw.replace("\uFEFF","").trim();int p=l.indexOf(':');if(p>0)config.put(l.substring(0,p).trim(),l.substring(p+1).trim());}
  String url=config.get("url");require(url!=null&&url.matches("jdbc:mysql://[^/]+/ymsw_v2(?:\\?.*)?"),"Unexpected target");
  var props=new Properties();props.setProperty("user",config.get("username"));props.setProperty("password",config.get("password"));props.setProperty("connectTimeout","5000");props.setProperty("socketTimeout","20000");
  Path dir=Path.of(args[1]);String mode=args[2];int index=0;
  try(var c=DriverManager.getConnection(url,props)){
   try(var s=c.createStatement()){s.execute("SET time_zone='+00:00'");}
   require(scalar(c,"SELECT DATE(CONVERT_TZ(UTC_TIMESTAMP(),'+00:00','+08:00'))='2026-10-17'")==1,"Fixture business day no longer current");
   if(mode.equals("upgrade")){
    require(scalar(c,"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('run_start_culture_session','run_start_culture_receipt','run_workflow_step_visit','run_workflow_step_visit_member','alarm_start_culture_collection')")==0,"Upgrade already applied or partial: inspect before continuing");
    require(scalar(c,"SELECT COUNT(*) FROM res_culture c LEFT JOIN res_culture_change_candidate cc ON cc.candidate_id=c.initial_weight_candidate_id AND cc.culture_id=c.culture_id AND cc.state='APPLIED' WHERE c.initial_weight_g IS NOT NULL AND cc.candidate_id IS NULL")==0,"Unproven existing weight source");
    backup(c,dir.resolve("db-before-preparation"));
   }else if(mode.equals("seed")){
    require(Files.isDirectory(dir.resolve("db-before-preparation")),"Pre-change backup missing");
    require(Files.exists(dir.resolve("db-upgrade-success.txt")),"Successful upgrade receipt missing");
    require(scalar(c,"SELECT COUNT(*) FROM workflow_node WHERE node_id=3 AND node_code='start_culture' AND status='0' AND del_flag='0'")==1,"Unexpected existing node");
    require(scalar(c,"SELECT COUNT(*) FROM workflow_subflow WHERE subflow_id IN (40011,40012) OR (node_id=3 AND sort_order IN (3,4))")==0,"Definition collision");
    require(scalar(c,"SELECT COUNT(*) FROM res_project WHERE project_id=861017001 OR project_code='SC-20261017'")==0,"Fixture already exists");
    c.setAutoCommit(false);
   }else throw new IllegalArgumentException("Expected upgrade or seed");
   String input=Files.readString(dir.resolve("test-environment-"+mode+".sql"));
   input=input.replaceAll("(?m)^--[^\\r\\n]*","");
   for(String sql:input.split(";\\s*(?:\\r?\\n|$)")){sql=sql.trim();if(sql.isEmpty())continue;index++;
    require(sql.matches("(?is)^(CREATE TABLE|ALTER TABLE|UPDATE res_culture|INSERT INTO)\\b.*"),"Unexpected SQL operation");
    try(var s=c.createStatement()){s.execute(sql);}catch(SQLException e){if(mode.equals("seed"))c.rollback();throw e;}System.out.println(mode+" statement "+index+" OK");
   }
   if(mode.equals("seed"))c.commit();
   Files.writeString(dir.resolve("db-"+mode+"-success.txt"),java.time.Instant.now()+" statements="+index+"\n");
   System.out.println(mode+" completed; "+index+" statements");
  }catch(SQLException e){System.err.println("Failed statement "+index+" SQLState="+e.getSQLState()+" code="+e.getErrorCode());System.exit(2);}
 }
}
