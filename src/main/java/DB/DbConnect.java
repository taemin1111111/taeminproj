package DB;

import java.sql.*;

public class DbConnect {

    static final String MYSQL_DRIVER = "com.mysql.cj.jdbc.Driver";
    static final String MYSQL_URL = "jdbc:mysql://127.0.0.1:3306/hothot?serverTimezone=Asia/Seoul&characterEncoding=utf8";
    static final String MYSQL_USER = "root";
    static final String MYSQL_PASSWORD = "a1234";

    public DbConnect() {
        try {
            Class.forName(MYSQL_DRIVER);
        } catch (ClassNotFoundException e) {
            System.out.println("MySQL 드라이버 로딩 실패: " + e.getMessage());
        }
    }

    public Connection getConnection() {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(MYSQL_URL, MYSQL_USER, MYSQL_PASSWORD);
            System.out.println("MySQL 연결 성공!");
        } catch (SQLException e) {
            System.out.println("MySQL 연결 실패!");
            e.printStackTrace();
        }
        return conn;
    }

    public void dbClose(ResultSet rs, Statement stmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void dbClose(Statement stmt, Connection conn) {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void dbClose(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void dbClose(PreparedStatement pstmt, Connection conn) {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
