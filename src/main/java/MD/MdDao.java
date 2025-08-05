package MD;

import java.sql.*;
import java.util.*;
import DB.DbConnect;

public class MdDao {
    DbConnect db = new DbConnect();
    
    // MD 정보 등록 (관리자만)
    public boolean insertMd(MdDto mdDto) {
        String sql = "INSERT INTO md_info (md_name, club_name, region, contact, description, photo) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, mdDto.getMdName());
            pstmt.setString(2, mdDto.getClubName());
            pstmt.setString(3, mdDto.getRegion());
            pstmt.setString(4, mdDto.getContact());
            pstmt.setString(5, mdDto.getDescription());
            pstmt.setString(6, mdDto.getPhoto());
            
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
                md.setMdName(rs.getString("md_name"));
                md.setClubName(rs.getString("club_name"));
                md.setRegion(rs.getString("region"));
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
                md.setMdName(rs.getString("md_name"));
                md.setClubName(rs.getString("club_name"));
                md.setRegion(rs.getString("region"));
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
                    md.setMdName(rs.getString("md_name"));
                    md.setClubName(rs.getString("club_name"));
                    md.setRegion(rs.getString("region"));
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
    
    // 클럽별 MD 정보 조회
    public List<MdDto> getMdByClubName(String clubName) {
        List<MdDto> mdList = new ArrayList<>();
        String sql = "SELECT * FROM md_info WHERE club_name LIKE ? AND is_visible = TRUE ORDER BY created_at DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, "%" + clubName + "%");
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MdDto md = new MdDto();
                    md.setMdId(rs.getInt("md_id"));
                    md.setMdName(rs.getString("md_name"));
                    md.setClubName(rs.getString("club_name"));
                    md.setRegion(rs.getString("region"));
                    md.setContact(rs.getString("contact"));
                    md.setDescription(rs.getString("description"));
                    md.setPhoto(rs.getString("photo"));
                    md.setCreatedAt(rs.getTimestamp("created_at"));
                    md.setVisible(rs.getBoolean("is_visible"));
                    
                    mdList.add(md);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("클럽별 MD 정보 조회 오류: " + e.getMessage());
        }
        
        return mdList;
    }
    
    // 지역별 MD 정보 조회
    public List<MdDto> getMdByRegion(String region) {
        List<MdDto> mdList = new ArrayList<>();
        String sql = "SELECT * FROM md_info WHERE region LIKE ? AND is_visible = TRUE ORDER BY created_at DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, "%" + region + "%");
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MdDto md = new MdDto();
                    md.setMdId(rs.getInt("md_id"));
                    md.setMdName(rs.getString("md_name"));
                    md.setClubName(rs.getString("club_name"));
                    md.setRegion(rs.getString("region"));
                    md.setContact(rs.getString("contact"));
                    md.setDescription(rs.getString("description"));
                    md.setPhoto(rs.getString("photo"));
                    md.setCreatedAt(rs.getTimestamp("created_at"));
                    md.setVisible(rs.getBoolean("is_visible"));
                    
                    mdList.add(md);
                }
            }
            
        } catch (SQLException e) {
            System.out.println("지역별 MD 정보 조회 오류: " + e.getMessage());
        }
        
        return mdList;
    }
    
    // MD 정보 수정 (관리자만)
    public boolean updateMd(MdDto mdDto) {
        String sql = "UPDATE md_info SET md_name = ?, club_name = ?, region = ?, " +
                     "contact = ?, description = ?, photo = ?, is_visible = ? WHERE md_id = ?";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, mdDto.getMdName());
            pstmt.setString(2, mdDto.getClubName());
            pstmt.setString(3, mdDto.getRegion());
            pstmt.setString(4, mdDto.getContact());
            pstmt.setString(5, mdDto.getDescription());
            pstmt.setString(6, mdDto.getPhoto());
            pstmt.setBoolean(7, mdDto.isVisible());
            pstmt.setInt(8, mdDto.getMdId());
            
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
} 