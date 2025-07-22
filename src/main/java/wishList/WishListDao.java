package wishList;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class WishListDao {
    DbConnect db = new DbConnect();

    // 찜 추가
    public boolean insertWishlist(String userid, int placeId) {
        String sql = "INSERT INTO wishlist (userid, place_id) VALUES (?, ?)";
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
}
