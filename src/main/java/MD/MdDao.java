package MD;

import java.sql.*;
import java.util.*;
import DB.DbConnect;

public class MdDao {
    DbConnect db = new DbConnect();
    
    // MD 정보 등록 (관리자만)
    public boolean insertMd(MdDto mdDto) {
        String sql = "INSERT INTO md_info (place_id, md_name, contact, description, photo) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdDto.getPlaceId());
            pstmt.setString(2, mdDto.getMdName());
            pstmt.setString(3, mdDto.getContact());
            pstmt.setString(4, mdDto.getDescription());
            pstmt.setString(5, mdDto.getPhoto());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.out.println("MD 정보 등록 오류: " + e.getMessage());
            return false;
        }
    }
    
    // 모든 MD 정보 조회 (사용자용 - visible=true만)
    public List<MdDto> getAllVisibleMd() {
        List<MdDto> mdList = new ArrayList<>();
        String sql = "SELECT * FROM md_info WHERE is_visible = TRUE ORDER BY created_at DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                MdDto md = new MdDto();
                md.setMdId(rs.getInt("md_id"));
                md.setPlaceId(rs.getInt("place_id"));
                md.setMdName(rs.getString("md_name"));
                md.setContact(rs.getString("contact"));
                md.setDescription(rs.getString("description"));
                md.setPhoto(rs.getString("photo"));
                md.setCreatedAt(rs.getTimestamp("created_at"));
                md.setVisible(rs.getBoolean("is_visible"));
                
                mdList.add(md);
            }
            
        } catch (SQLException e) {
            System.out.println("MD 정보 조회 오류: " + e.getMessage());
        }
        
        return mdList;
    }
    
    // 모든 MD 정보 조회 (관리자용 - 전체)
    public List<MdDto> getAllMd() {
        List<MdDto> mdList = new ArrayList<>();
        String sql = "SELECT * FROM md_info ORDER BY created_at DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                MdDto md = new MdDto();
                md.setMdId(rs.getInt("md_id"));
                md.setPlaceId(rs.getInt("place_id"));
                md.setMdName(rs.getString("md_name"));
                md.setContact(rs.getString("contact"));
                md.setDescription(rs.getString("description"));
                md.setPhoto(rs.getString("photo"));
                md.setCreatedAt(rs.getTimestamp("created_at"));
                md.setVisible(rs.getBoolean("is_visible"));
                
                mdList.add(md);
            }
            
        } catch (SQLException e) {
            System.out.println("MD 정보 조회 오류: " + e.getMessage());
        }
        
        return mdList;
    }
    
    // 특정 MD 정보 조회
    public MdDto getMdById(int mdId) {
        String sql = "SELECT * FROM md_info WHERE md_id = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    MdDto md = new MdDto();
                    md.setMdId(rs.getInt("md_id"));
                    md.setPlaceId(rs.getInt("place_id"));
                    md.setMdName(rs.getString("md_name"));
                    md.setContact(rs.getString("contact"));
                    md.setDescription(rs.getString("description"));
                    md.setPhoto(rs.getString("photo"));
                    md.setCreatedAt(rs.getTimestamp("created_at"));
                    md.setVisible(rs.getBoolean("is_visible"));
                    
                    return md;
                }
            }
            
        } catch (SQLException e) {
            System.out.println("MD 정보 조회 오류: " + e.getMessage());
        }
        
        return null;
    }
    
    // 특정 장소의 MD 정보 조회
    public List<MdDto> getMdByPlaceId(int placeId) {
        List<MdDto> mdList = new ArrayList<>();
        String sql = "SELECT * FROM md_info WHERE place_id = ? AND is_visible = TRUE ORDER BY created_at DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, placeId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MdDto md = new MdDto();
                    md.setMdId(rs.getInt("md_id"));
                    md.setPlaceId(rs.getInt("place_id"));
                    md.setMdName(rs.getString("md_name"));
                    md.setContact(rs.getString("contact"));
                    md.setDescription(rs.getString("description"));
                    md.setPhoto(rs.getString("photo"));
                    md.setCreatedAt(rs.getTimestamp("created_at"));
                    md.setVisible(rs.getBoolean("is_visible"));
                    
                    mdList.add(md);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("장소별 MD 정보 조회 오류: " + e.getMessage());
        }
        
        return mdList;
    }
    
    // MD 정보와 장소 정보를 함께 조회 (JOIN)
    public List<Map<String, Object>> getMdWithPlaceInfo() {
        List<Map<String, Object>> mdList = new ArrayList<>();
        String sql = "SELECT m.*, h.name as place_name, h.address, h.lat, h.lng " +
                     "FROM md_info m " +
                     "JOIN hotplace_info h ON m.place_id = h.id " +
                     "WHERE m.is_visible = TRUE " +
                     "ORDER BY m.created_at DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> mdMap = new HashMap<>();
                mdMap.put("mdId", rs.getInt("md_id"));
                mdMap.put("placeId", rs.getInt("place_id"));
                mdMap.put("mdName", rs.getString("md_name"));
                mdMap.put("contact", rs.getString("contact"));
                mdMap.put("description", rs.getString("description"));
                mdMap.put("photo", rs.getString("photo"));
                mdMap.put("createdAt", rs.getTimestamp("created_at"));
                mdMap.put("isVisible", rs.getBoolean("is_visible"));
                mdMap.put("placeName", rs.getString("place_name"));
                mdMap.put("address", rs.getString("address"));
                mdMap.put("lat", rs.getDouble("lat"));
                mdMap.put("lng", rs.getDouble("lng"));
                
                mdList.add(mdMap);
            }
            
        } catch (SQLException e) {
            System.out.println("MD와 장소 정보 조회 오류: " + e.getMessage());
        }
        
        return mdList;
    }
    
    // MD 정보 수정 (관리자만)
    public boolean updateMd(MdDto mdDto) {
        String sql = "UPDATE md_info SET place_id = ?, md_name = ?, " +
                     "contact = ?, description = ?, photo = ?, is_visible = ? WHERE md_id = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdDto.getPlaceId());
            pstmt.setString(2, mdDto.getMdName());
            pstmt.setString(3, mdDto.getContact());
            pstmt.setString(4, mdDto.getDescription());
            pstmt.setString(5, mdDto.getPhoto());
            pstmt.setBoolean(6, mdDto.isVisible());
            pstmt.setInt(7, mdDto.getMdId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.out.println("MD 정보 수정 오류: " + e.getMessage());
            return false;
        }
    }
    
    // MD 정보 삭제 (관리자만)
    public boolean deleteMd(int mdId) {
        String sql = "DELETE FROM md_info WHERE md_id = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, mdId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.out.println("MD 정보 삭제 오류: " + e.getMessage());
            return false;
        }
    }
    
    // MD 표시/숨김 토글 (관리자만)
    public boolean toggleMdVisibility(int mdId, boolean isVisible) {
        String sql = "UPDATE md_info SET is_visible = ? WHERE md_id = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBoolean(1, isVisible);
            pstmt.setInt(2, mdId);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.out.println("MD 표시 상태 변경 오류: " + e.getMessage());
            return false;
        }
    }
    
    // MD 정보 개수 조회
    public int getMdCount() {
        String sql = "SELECT COUNT(*) FROM md_info WHERE is_visible = TRUE";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.out.println("MD 개수 조회 오류: " + e.getMessage());
        }
        
        return 0;
    }
    
    // MD 정보 개수 조회 (전체 - 관리자용)
    public int getTotalMdCount() {
        String sql = "SELECT COUNT(*) FROM md_info";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.out.println("전체 MD 개수 조회 오류: " + e.getMessage());
        }
        
        return 0;
    }
    
    // 페이징을 위한 MD 정보와 장소 정보를 함께 조회 (JOIN)
    public List<Map<String, Object>> getMdWithPlaceInfoPaged(int page, int pageSize) {
        List<Map<String, Object>> mdList = new ArrayList<>();
        String sql = "SELECT m.*, h.name as place_name, h.address, h.lat, h.lng " +
                     "FROM md_info m " +
                     "JOIN hotplace_info h ON m.place_id = h.id " +
                     "WHERE m.is_visible = TRUE " +
                     "ORDER BY m.created_at DESC " +
                     "LIMIT ? OFFSET ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            int offset = (page - 1) * pageSize;
            pstmt.setInt(1, pageSize);
            pstmt.setInt(2, offset);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> mdMap = new HashMap<>();
                    mdMap.put("mdId", rs.getInt("md_id"));
                    mdMap.put("placeId", rs.getInt("place_id"));
                    mdMap.put("mdName", rs.getString("md_name"));
                    mdMap.put("contact", rs.getString("contact"));
                    mdMap.put("description", rs.getString("description"));
                    mdMap.put("photo", rs.getString("photo"));
                    mdMap.put("createdAt", rs.getTimestamp("created_at"));
                    mdMap.put("isVisible", rs.getBoolean("is_visible"));
                    mdMap.put("placeName", rs.getString("place_name"));
                    mdMap.put("address", rs.getString("address"));
                    mdMap.put("lat", rs.getDouble("lat"));
                    mdMap.put("lng", rs.getDouble("lng"));
                    
                    mdList.add(mdMap);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("페이징 MD와 장소 정보 조회 오류: " + e.getMessage());
        }
        
        return mdList;
    }
    
    // 총 페이지 수 계산
    public int getTotalPages(int pageSize) {
        int totalCount = getMdCount();
        return (int) Math.ceil((double) totalCount / pageSize);
    }
} 