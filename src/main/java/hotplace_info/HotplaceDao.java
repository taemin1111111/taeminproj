package hotplace_info;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import DB.DbConnect;

public class HotplaceDao {

    private final DbConnect db = new DbConnect();

    // 1. 전체 핫플 조회
    public List<HotplaceDto> getAllHotplaces() {
        List<HotplaceDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hotplace_info";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToDto(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. 카테고리별 핫플 조회
    public List<HotplaceDto> getHotplacesByCategory(int categoryId) {
        List<HotplaceDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hotplace_info WHERE category_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToDto(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. ID로 핫플 조회
    public HotplaceDto getHotplaceById(int id) {
        String sql = "SELECT * FROM hotplace_info WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToDto(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ResultSet → DTO 매핑 분리
    private HotplaceDto mapRowToDto(ResultSet rs) throws SQLException {
        HotplaceDto dto = new HotplaceDto();
        dto.setId(         rs.getInt("id") );
        dto.setName(       rs.getString("name") );
        dto.setAddress(    rs.getString("address") );
        dto.setLat(        rs.getDouble("lat") );
        dto.setLng(        rs.getDouble("lng") );
        dto.setCategoryId( rs.getInt("category_id") );
        dto.setRegionId(   rs.getInt("region_id") );

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            dto.setCreatedAt(ts.toLocalDateTime());
        }
        return dto;
    }
}
