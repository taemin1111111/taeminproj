package CCategory;

import java.sql.*;
import java.util.*;
import DB.DbConnect;

public class CCategoryDao {
    private DbConnect db = new DbConnect();

    // community_category 테이블의 모든 카테고리 조회
    public List<CCategoryDto> getAllCategories() {
        List<CCategoryDto> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT id, name FROM community_category ORDER BY id";
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                list.add(new CCategoryDto(id, name));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        return list;
    }
}
