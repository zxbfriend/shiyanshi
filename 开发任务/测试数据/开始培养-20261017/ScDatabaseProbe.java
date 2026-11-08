import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

/** Read-only inventory. Credentials are read from the user's existing local file, never echoed. */
class ScDatabaseProbe {
    public static void main(String[] args) throws Exception {
        Map<String,String> config=new HashMap<>();
        for(String raw:Files.readAllLines(Path.of(args[0]),StandardCharsets.UTF_8)) {
            String line=raw.replace("\uFEFF","").trim();int sep=line.indexOf(':');
            if(sep>0)config.put(line.substring(0,sep).trim(),line.substring(sep+1).trim());
        }
        String url=config.get("url");
        if(url==null||!url.matches("jdbc:mysql://[^/]+/ymsw_v2(?:\\?.*)?"))throw new IllegalArgumentException("Unexpected target database");
        Properties props=new Properties();props.setProperty("user",config.get("username"));props.setProperty("password",config.get("password"));
        props.setProperty("connectTimeout","5000");props.setProperty("socketTimeout","15000");
        try(Connection c=DriverManager.getConnection(url,props)){
            c.setReadOnly(true);
            for(String sql:Files.readString(Path.of(args[1]),StandardCharsets.UTF_8).split(";")){
                sql=sql.trim();if(sql.isEmpty())continue;
                if(!sql.matches("(?is)^(SELECT|SHOW|DESCRIBE)\\b.*"))throw new IllegalArgumentException("Read-only statements required");
                try(Statement st=c.createStatement();ResultSet rs=st.executeQuery(sql)){
                    ResultSetMetaData md=rs.getMetaData();List<String> columns=new ArrayList<>();for(int i=1;i<=md.getColumnCount();i++)columns.add(md.getColumnLabel(i));
                    System.out.println(String.join("\t",columns));int n=0;
                    while(rs.next()){List<String> row=new ArrayList<>();for(int i=1;i<=md.getColumnCount();i++){Object v=rs.getObject(i);row.add(v==null?"NULL":v.toString().replace("\t"," ").replace("\n"," "));}System.out.println(String.join("\t",row));n++;}
                    System.out.println("ROWS="+n);
                }
            }
        }catch(SQLException ex){System.err.println("Database probe failed: SQLState="+ex.getSQLState()+" vendorCode="+ex.getErrorCode());System.exit(2);}
    }
}
