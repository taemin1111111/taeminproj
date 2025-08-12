package content_images;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class ContentImagesDao {
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
    
    // 특정 장소의 모든 이미지 조회 (순서대로)
    public List<ContentImagesDto> getImagesByHotplaceId(int hotplaceId) {
        List<ContentImagesDto> imageList = new ArrayList<>();
        getConnection();
        
        try {
            String sql = "SELECT * FROM content_images WHERE hotplace_id = ? ORDER BY image_order ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, hotplaceId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ContentImagesDto dto = new ContentImagesDto();
                dto.setId(rs.getInt("id"));
                dto.setHotplaceId(rs.getInt("hotplace_id"));
                dto.setImagePath(rs.getString("image_path"));
                dto.setImageOrder(rs.getInt("image_order"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                imageList.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return imageList;
    }
    
    // 특정 장소의 첫 번째 이미지만 조회 (대표 이미지용)
    public ContentImagesDto getFirstImageByHotplaceId(int hotplaceId) {
        ContentImagesDto dto = null;
        getConnection();
        
        try {
            String sql = "SELECT * FROM content_images WHERE hotplace_id = ? ORDER BY image_order ASC LIMIT 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, hotplaceId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                dto = new ContentImagesDto();
                dto.setId(rs.getInt("id"));
                dto.setHotplaceId(rs.getInt("hotplace_id"));
                dto.setImagePath(rs.getString("image_path"));
                dto.setImageOrder(rs.getInt("image_order"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return dto;
    }
    
    // 이미지 추가 (관리자용)
    public boolean insertImage(ContentImagesDto dto) {
        boolean result = false;
        getConnection();
        
        try {
            String sql = "INSERT INTO content_images (hotplace_id, image_path, image_order) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getHotplaceId());
            pstmt.setString(2, dto.getImagePath());
            pstmt.setInt(3, dto.getImageOrder());
            
            int count = pstmt.executeUpdate();
            if (count > 0) result = true;
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 이미지 순서 업데이트 (관리자용)
    public boolean updateImageOrder(int imageId, int newOrder) {
        boolean result = false;
        getConnection();
        
        try {
            String sql = "UPDATE content_images SET image_order = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, newOrder);
            pstmt.setInt(2, imageId);
            
            int count = pstmt.executeUpdate();
            if (count > 0) result = true;
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 이미지 삭제 (관리자용)
    public boolean deleteImage(int imageId) {
        boolean result = false;
        getConnection();
        
        try {
            String sql = "DELETE FROM content_images WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, imageId);
            
            int count = pstmt.executeUpdate();
            if (count > 0) result = true;
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 특정 장소의 모든 이미지 삭제 (관리자용)
    public boolean deleteAllImagesByHotplaceId(int hotplaceId) {
        boolean result = false;
        getConnection();
        
        try {
            String sql = "DELETE FROM content_images WHERE hotplace_id = ?";
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
    
    // 특정 장소의 이미지 개수 조회
    public int getImageCountByHotplaceId(int hotplaceId) {
        int count = 0;
        getConnection();
        
        try {
            String sql = "SELECT COUNT(*) FROM content_images WHERE hotplace_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, hotplaceId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return count;
    }
    
    // 다음 이미지 순서 번호 조회 (새 이미지 추가 시 사용)
    public int getNextImageOrder(int hotplaceId) {
        int nextOrder = 1;
        getConnection();
        
        try {
            String sql = "SELECT MAX(image_order) FROM content_images WHERE hotplace_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, hotplaceId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int maxOrder = rs.getInt(1);
                if (maxOrder > 0) {
                    nextOrder = maxOrder + 1;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            disConnection();
        }
        
        return nextOrder;
    }
}
