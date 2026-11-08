import java.sql.*;
import java.nio.file.*;
/** Opt-in, insert-only fixture loader. Credentials come only from environment. */
class SeedM07Dev {
 public static void main(String[] args) throws Exception {
  if(args.length!=3 || !args[1].equals("DEV-M07-1016")) throw new IllegalArgumentException("Expected SQL path and fixture key and expected rows");
  try(var c=DriverManager.getConnection(System.getenv("SMP_REVIEW_DB_URL"),System.getenv("SMP_REVIEW_DB_USER"),System.getenv("SMP_REVIEW_DB_PASSWORD"))){
   if(!"ymsw_v2".equals(c.getCatalog())) throw new IllegalStateException("Development database only");
   c.setAutoCommit(false);
   try {
    String sql=Files.readString(Path.of(args[0])).replaceAll("(?m)^--[^\r\n]*", "");
    int rows=0;
    for(String q:sql.split(";")) { q=q.trim(); if(q.isEmpty())continue;
     if(!q.matches("(?is)^INSERT INTO (res_culture_occupancy|res_batch|res_batch_leader|lab_bench_reactor|res_culture|run_culture_runtime|res_culture_change_candidate) .*")) throw new IllegalArgumentException("Unexpected statement");
     try(var s=c.createStatement()){ rows+=s.executeUpdate(q); }
    }
    if(rows!=Integer.parseInt(args[2]))throw new IllegalStateException("Unexpected new row count: "+rows);
    c.commit(); System.out.println("DEV-M07-1016 committed fixture rows. No existing rows changed.");
   }catch(Exception e){c.rollback();throw e;}
  }
 }
}
