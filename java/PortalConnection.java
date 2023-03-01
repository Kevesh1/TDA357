
import java.sql.*; // JDBC stuff.
import java.util.Objects;
import java.util.Properties;
import org.json.JSONArray;
import org.json.JSONObject;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "portal";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){

       try(PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Registrations VALUES (?,?)"
        );){

            ps.setString(1,student);
            ps.setString(2,courseCode);
            ps.executeUpdate();
            //System.out.println(rs);

            return "{\"success\":\"true\"}";

        } catch (SQLException e) {
            return "{\"success\":false, \"error\":" + getError(e) + "}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        /*try(PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM Registrations WHERE student = ? AND course = ?"
        );) {
            ps.setString(1, student);
            ps.setString(2, courseCode);*/

        try(Statement s = conn.createStatement();){

            String query = "DELETE FROM Registrations WHERE student = '"+student+"' AND course = '"+courseCode+"'";

            //System.out.println(rs);



            int preDeleteCount;
            try (PreparedStatement preCount = conn.prepareStatement(
                    "SELECT COUNT(*) FROM Registrations");) {
                //Get the size of Registrations before the DELETE
                ResultSet count = preCount.executeQuery();
                count.next();
                preDeleteCount = count.getInt(1);
            }
            s.executeUpdate(query);

            int postDeleteCount;
            try (PreparedStatement postCount = conn.prepareStatement(
                    "SELECT COUNT(*) FROM Registrations");) {
                ResultSet count = postCount.executeQuery();
                count.next();
                postDeleteCount = count.getInt(1);
            }

            if (preDeleteCount == postDeleteCount) {
                throw new SQLException(" Nothing was deleted, check that student and/or course exists");
            }

            //System.out.println(rs);

            return "{\"success\":\"true\"}";

        } catch (SQLException e) {

            return "{\"success\":false, \"error\":" + getError(e) + "}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        JSONObject information = new JSONObject();
        try(PreparedStatement ps = conn.prepareStatement(
            // replace this with something more useful
            //"SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
                "SELECT idnr AS student, name, login, program, branch FROM BasicInformation WHERE idnr=?"
            );){
            ps.setString(1, student);
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData rsmd = rs.getMetaData();
            int column = rsmd.getColumnCount();

            while(rs.next()){
                for (int i = 1; i <= column; i++){
                    String columnName = rsmd.getColumnName(i);
                    information.put(columnName, rs.getString(i));
                }
                //informations.put("a",information);
            }
        }
        try(PreparedStatement ps = conn.prepareStatement(
                // replace this with something more useful
                //"SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
                "SELECT Courses.name AS course, Courses.code,grade,Courses.credits FROM FinishedCourses JOIN Courses ON FinishedCourses.course = Courses.code WHERE student=?"
        );) {
            ps.setString(1, student);
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData rsmd = rs.getMetaData();
            int column = rsmd.getColumnCount();

            JSONArray finishedCourses = new JSONArray();

            while (rs.next()) {
                JSONObject info = new JSONObject();
                for (int i = 1; i <= column; i++){
                    String columnName = rsmd.getColumnName(i);

                    info.put(columnName, rs.getString(i));
                }
                finishedCourses.put(info);
                information.put("finished",finishedCourses);
            }

        }

        try(PreparedStatement ps = conn.prepareStatement(
                // replace this with something more useful
                //"SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
                "SELECT Courses.code AS code, Courses.name AS course, status FROM Registrations JOIN Courses ON Registrations.course = Courses.code WHERE student=?;"
        );) {
            ps.setString(1, student);
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData rsmd = rs.getMetaData();
            int column = rsmd.getColumnCount();

            JSONArray registration = new JSONArray();

            while (rs.next()) {
                JSONObject reg = new JSONObject();
                for (int i = 1; i <= column; i++){

                    String columnName = rsmd.getColumnName(i);
                    reg.put(columnName, rs.getString(i));
                }
                //informations.put("c",information);
                registration.put(reg);
                information.put("registered", registration);
            }

        }

        try(PreparedStatement ps = conn.prepareStatement(
                // replace this with something more useful
                //"SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
                "SELECT totalCredits,mandatoryLeft,mathCredits,researchCredits, seminarCourses, qualified FROM PathToGraduation WHERE student=?"
        );) {
            ps.setString(1, student);
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData rsmd = rs.getMetaData();
            int column = rsmd.getColumnCount();


            while (rs.next()) {
                for (int i = 1; i <= column; i++){
                    String columnName = rsmd.getColumnName(i);
                    switch (columnName){
                        case "totalcredits" -> columnName = "totalCredits";

                        case "mandatoryleft" -> columnName = "mandatoryLeft";

                        case "mathcredits" -> columnName = "mathCredits";

                        case "researchcredits" -> columnName = "researchCredits";

                        case "seminarcourses" -> columnName = "seminarCourses";

                        case "qualified" -> columnName = "canGraduate";
                    }
                    information.put(columnName, rs.getString(i));
                }
            }
        }
        return information.toString();
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}