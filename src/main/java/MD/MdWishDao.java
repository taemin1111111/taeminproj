package MD;

import java.sql.*;
import java.util.*;
import DB.DbConnect;

public class MdWishDao {
    DbConnect db = new DbConnect();
    
    // MD 찜 추가
    public boolean addMdWish(int mdId, String userid) {
        String sql = "INSERT INTO md_wish (md_id, userid) VALUES (?, ?)";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdId);
            pstmt.setString(2, userid);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.out.println("MD 찜 추가 오류: " + e.getMessage());
            return false;
        }
    }
    
    // MD 찜 삭제
    public boolean removeMdWish(int mdId, String userid) {
        String sql = "DELETE FROM md_wish WHERE md_id = ? AND userid = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdId);
            pstmt.setString(2, userid);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.out.println("MD 찜 삭제 오류: " + e.getMessage());
            return false;
        }
    }
    
    // 특정 MD가 찜되었는지 확인
    public boolean isMdWished(int mdId, String userid) {
        String sql = "SELECT COUNT(*) FROM md_wish WHERE md_id = ? AND userid = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdId);
            pstmt.setString(2, userid);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
            
        } catch (SQLException e) {
            System.out.println("MD 찜 확인 오류: " + e.getMessage());
        }
        
        return false;
    }
    
    // 사용자의 찜한 MD 목록 조회
    public List<MdWishDto> getUserMdWishes(String userid) {
        List<MdWishDto> wishList = new ArrayList<>();
        String sql = "SELECT * FROM md_wish WHERE userid = ? ORDER BY created_at DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MdWishDto wish = new MdWishDto();
                    wish.setWishId(rs.getInt("wish_id"));
                    wish.setMdId(rs.getInt("md_id"));
                    wish.setUserid(rs.getString("userid"));
                    wish.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    wishList.add(wish);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("사용자 MD 찜 목록 조회 오류: " + e.getMessage());
        }
        
        return wishList;
    }
    
    // 특정 MD의 찜 개수 조회
    public int getMdWishCount(int mdId) {
        String sql = "SELECT COUNT(*) FROM md_wish WHERE md_id = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("MD 찜 개수 조회 오류: " + e.getMessage());
        }
        
        return 0;
    }
    
    // 사용자의 MD 찜 개수 조회
    public int getUserMdWishCount(String userid) {
        String sql = "SELECT COUNT(*) FROM md_wish WHERE userid = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("사용자 MD 찜 개수 조회 오류: " + e.getMessage());
        }
        
        return 0;
    }
    
    // 사용자의 찜한 MD 목록과 MD 정보 함께 조회
    public List<Map<String, Object>> getUserMdWishesWithInfo(String userid, int limit) {
        List<Map<String, Object>> wishList = new ArrayList<>();
        String sql = "SELECT w.wish_id, w.md_id, w.userid, w.created_at, " +
                    "m.md_name, m.contact, m.description, m.photo, " +
                    "p.name as place_name, p.address " +
                    "FROM md_wish w " +
                    "JOIN md_info m ON w.md_id = m.md_id " +
                    "JOIN hotplace_info p ON m.place_id = p.id " +
                    "WHERE w.userid = ? " +
                    "ORDER BY w.created_at DESC " +
                    "LIMIT ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            pstmt.setInt(2, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> wish = new HashMap<>();
                    wish.put("wishId", rs.getInt("wish_id"));
                    wish.put("mdId", rs.getInt("md_id"));
                    wish.put("userid", rs.getString("userid"));
                    wish.put("createdAt", rs.getTimestamp("created_at"));
                    wish.put("mdName", rs.getString("md_name"));
                    wish.put("contact", rs.getString("contact"));
                    wish.put("description", rs.getString("description"));
                    wish.put("photo", rs.getString("photo"));
                    wish.put("placeName", rs.getString("place_name"));
                    wish.put("address", rs.getString("address"));
                    
                    wishList.add(wish);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("사용자 MD 찜 목록 조회 오류: " + e.getMessage());
        }
        
        return wishList;
    }
} 