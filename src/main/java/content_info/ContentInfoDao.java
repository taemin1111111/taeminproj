package content_info;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class ContentInfoDao {
    private Connection conn;
    private PreparedStatement pstmt;
    private ResultSet rs;
    
    // DB 연결
    public void getConnection() {
        try {
            DbConnect dbConnect = new DbConnect();
            conn = dbConnect.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // DB 연결 해제
    public void disConnection() {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // 특정 장소의 내용 조회
    public ContentInfoDto getContentByHotplaceId(int hotplaceId) {
        ContentInfoDto dto = null;
        getConnection();
        
        try {
            String sql = "SELECT * FROM content_info WHERE hotplace_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, hotplaceId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                dto = new ContentInfoDto();
                dto.setId(rs.getInt("id"));
                dto.setHotplaceId(rs.getInt("hotplace_id"));
                dto.setContentText(rs.getString("content_text"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setUpdatedAt(rs.getTimestamp("updated_at"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return dto;
    }
    
    // 내용 추가 (관리자용)
    public boolean insertContent(ContentInfoDto dto) {
        boolean result = false;
        getConnection();
        
        try {
            String sql = "INSERT INTO content_info (hotplace_id, content_text) VALUES (?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getHotplaceId());
            pstmt.setString(2, dto.getContentText());
            
            int count = pstmt.executeUpdate();
            if (count > 0) result = true;
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 내용 수정 (관리자용)
    public boolean updateContent(ContentInfoDto dto) {
        boolean result = false;
        getConnection();
        
        try {
            String sql = "UPDATE content_info SET content_text = ? WHERE hotplace_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getContentText());
            pstmt.setInt(2, dto.getHotplaceId());
            
            int count = pstmt.executeUpdate();
            if (count > 0) result = true;
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 내용 삭제 (관리자용)
    public boolean deleteContent(int hotplaceId) {
        boolean result = false;
        getConnection();
        
        try {
            String sql = "DELETE FROM content_info WHERE hotplace_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, hotplaceId);
            
            int count = pstmt.executeUpdate();
            if (count > 0) result = true;
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 내용이 존재하는지 확인
    public boolean isContentExists(int hotplaceId) {
        boolean exists = false;
        getConnection();
        
        try {
            String sql = "SELECT COUNT(*) FROM content_info WHERE hotplace_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, hotplaceId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return exists;
    }
}
