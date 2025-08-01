package wishList;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import DB.DbConnect;

public class WishListDao {
    DbConnect db = new DbConnect();

    // 찜 추가 (personal_note는 null로 설정)
    public boolean insertWishlist(String userid, int placeId) {
        String sql = "INSERT INTO wishlist (userid, place_id, personal_note) VALUES (?, ?, NULL)";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            pstmt.setInt(2, placeId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // personal_note와 함께 찜 추가
    public boolean insertWishlistWithNote(String userid, int placeId, String personalNote) {
        String sql = "INSERT INTO wishlist (userid, place_id, personal_note) VALUES (?, ?, ?)";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            pstmt.setInt(2, placeId);
            pstmt.setString(3, personalNote);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // personal_note 업데이트
    public boolean updatePersonalNote(int wishId, String userid, String personalNote) {
        String sql = "UPDATE wishlist SET personal_note = ? WHERE id = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, personalNote);
            pstmt.setInt(2, wishId);
            pstmt.setString(3, userid);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // personal_note 조회
    public String getPersonalNote(int wishId, String userid) {
        String sql = "SELECT personal_note FROM wishlist WHERE id = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, wishId);
            pstmt.setString(2, userid);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("personal_note");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 찜 해제
    public boolean deleteWishlist(String userid, int placeId) {
        String sql = "DELETE FROM wishlist WHERE userid = ? AND place_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            pstmt.setInt(2, placeId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 찜 여부 확인
    public boolean isWished(String userid, int placeId) {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE userid = ? AND place_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            pstmt.setInt(2, placeId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 해당 장소 찜 수
    public int getWishCount(int placeId) {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE place_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, placeId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 내 찜 목록 (place_id 리스트)
    public List<Integer> getWishlist(String userid) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT place_id FROM wishlist WHERE userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("place_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 마이페이지용: 위시리스트와 장소 정보 함께 조회
    public List<Map<String, Object>> getWishListWithPlaceInfo(String userid) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT w.id, w.userid, w.place_id, w.wish_date, w.personal_note, " +
                    "h.name as place_name, h.address, h.lat, h.lng, h.category_id, " +
                    "COALESCE(pc.name, '기타') as category_name " +
                    "FROM wishlist w " +
                    "LEFT JOIN hotplace_info h ON w.place_id = h.id " +
                    "LEFT JOIN place_category pc ON h.category_id = pc.id " +
                    "WHERE w.userid = ? " +
                    "ORDER BY w.wish_date DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    
                    map.put("id", rs.getInt("id"));
                    map.put("userid", rs.getString("userid"));
                    map.put("place_id", rs.getInt("place_id"));
                    map.put("wish_date", rs.getTimestamp("wish_date"));
                    map.put("place_name", rs.getString("place_name"));
                    map.put("address", rs.getString("address"));
                    map.put("lat", rs.getDouble("lat"));
                    map.put("lng", rs.getDouble("lng"));
                    map.put("category_id", rs.getInt("category_id"));
                    map.put("category_name", rs.getString("category_name"));
                    map.put("personal_note", rs.getString("personal_note"));
                    
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 위시리스트 개수 조회
    public int getWishListCount(String userid) {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE userid = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 위시리스트 ID로 삭제 (마이페이지용)
    public boolean deleteWishListById(int wishId, String userid) {
        String sql = "DELETE FROM wishlist WHERE id = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, wishId);
            pstmt.setString(2, userid);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


}
