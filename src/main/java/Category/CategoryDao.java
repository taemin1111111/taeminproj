package Category;

import java.sql.*;
import java.util.*;
import DB.DbConnect;

public class CategoryDao {
    DbConnect db = new DbConnect();

    public List<CategoryDto> getAllCategories() {
        List<CategoryDto> list = new ArrayList<>();
        String sql = "SELECT * FROM place_category ORDER BY id";

        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                CategoryDto dto = new CategoryDto();
                dto.setId(rs.getInt("id"));
                dto.setName(rs.getString("name"));
                list.add(dto);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}
