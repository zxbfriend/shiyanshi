import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

/** Narrow completion of authorized start-culture test DB preparation; no existing facts synthesized. */
class ScRuntimeSupplement {
 static long n(Connection c,String q)throws Exception {try(var s=c.createStatement();var r=s.executeQuery(q)){r.next();return r.getLong(1);}}
 static void require(boolean b,String m){if(!b)throw new IllegalStateException(m);}
 public static void main(String[] args)throws Exception {
  var cfg=new HashMap<String,String>();for(String raw:Files.readAllLines(Path.of(args[0]),StandardCharsets.UTF_8)){String l=raw.replace("\uFEFF","").trim();int p=l.indexOf(':');if(p>0)cfg.put(l.substring(0,p).trim(),l.substring(p+1).trim());}
  String url=cfg.get("url");require(url!=null&&url.matches("jdbc:mysql://[^/]+/ymsw_v2(?:\\?.*)?"),"Unexpected target");
  var props=new Properties();props.setProperty("user",cfg.get("username"));props.setProperty("password",cfg.get("password"));props.setProperty("connectTimeout","5000");props.setProperty("socketTimeout","20000");
  Path dir=Path.of(args[1]);
  try(var c=DriverManager.getConnection(url,props)){
   require(n(c,"SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='run_culture_runtime' AND column_name IN ('runtime_stream_id','runtime_stream_sequence','runtime_last_event_key')")==0,"Already supplemented or partial schema");
   require(n(c,"SELECT COUNT(*) FROM run_culture_runtime")==2,"Existing row count changed; re-inspect");
   require(n(c,"SELECT COUNT(*) FROM run_culture_runtime r JOIN res_culture c ON c.culture_id=r.culture_id WHERE c.runtime_stream_id IS NOT NULL OR c.runtime_stream_sequence IS NOT NULL")==0,"Existing owner stream needs evidence-based handling");
   require(n(c,"SELECT COUNT(*) FROM run_event WHERE source_event_key IS NOT NULL AND culture_id IN (SELECT culture_id FROM run_culture_runtime)")==0,"Existing producer facts need evidence-based handling");
   Path backup=dir.resolve("db-before-runtime-supplement");Files.createDirectory(backup);
   try(var s=c.createStatement();var r=s.executeQuery("SHOW CREATE TABLE run_culture_runtime")){r.next();Files.writeString(backup.resolve("run_culture_runtime.ddl.sql"),r.getString(2)+";\n");}
   try(var s=c.createStatement();var r=s.executeQuery("SELECT * FROM run_culture_runtime");var w=Files.newBufferedWriter(backup.resolve("run_culture_runtime.base64.tsv"))){
    var m=r.getMetaData();for(int i=1;i<=m.getColumnCount();i++){if(i>1)w.write('\t');w.write(m.getColumnName(i));}w.newLine();
    while(r.next()){for(int i=1;i<=m.getColumnCount();i++){if(i>1)w.write('\t');byte[] b=r.getBytes(i);w.write(b==null?"NULL":Base64.getEncoder().encodeToString(b));}w.newLine();}
   }
   String sql=Files.readString(dir.resolve("runtime-stream-supplement.sql"),StandardCharsets.UTF_8).replaceAll("(?m)^--[^\\r\\n]*", "").trim();
   require(sql.startsWith("ALTER TABLE run_culture_runtime")&&sql.chars().filter(v->v==';').count()==1,"Unexpected SQL");
   try(var s=c.createStatement()){s.execute(sql);}
   require(n(c,"SELECT COUNT(*) FROM run_culture_runtime WHERE runtime_stream_sequence=0 AND runtime_stream_id IS NULL AND runtime_last_event_key IS NULL")==2,"Postcheck failed");
   Files.writeString(dir.resolve("db-runtime-supplement-success.txt"),java.time.Instant.now()+" table=run_culture_runtime columns=3 constraint=1 preservedRows=2\n");
   System.out.println("Runtime supplement completed: 3 columns + 1 constraint; original 2 rows preserved; backup saved.");
  }catch(SQLException e){System.err.println("Supplement failed: SQLState="+e.getSQLState()+" vendorCode="+e.getErrorCode());System.exit(2);}
 }
}
