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
    
    // 모든 이미지 조회 (관리자용)
    public List<ContentImagesDto> getAllImages() {
        List<ContentImagesDto> imageList = new ArrayList<>();
        getConnection();
        
        try {
            String sql = "SELECT * FROM content_images ORDER BY hotplace_id ASC, image_order ASC";
            pstmt = conn.prepareStatement(sql);
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
    
    // 특정 이미지 ID로 조회
    public ContentImagesDto getImageById(int imageId) {
        ContentImagesDto dto = null;
        getConnection();
        
        try {
            String sql = "SELECT * FROM content_images WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, imageId);
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
    
    // 이미지 삭제 후 순서 재정렬
    public boolean reorderImagesAfterDelete(int hotplaceId) {
        boolean result = false;
        getConnection();
        
        try {
            // 해당 장소의 남은 이미지들을 순서대로 조회
            String selectSql = "SELECT id FROM content_images WHERE hotplace_id = ? ORDER BY image_order ASC";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setInt(1, hotplaceId);
            rs = pstmt.executeQuery();
            
            List<Integer> imageIds = new ArrayList<>();
            while (rs.next()) {
                imageIds.add(rs.getInt("id"));
            }
            
            // 순서를 1, 2, 3...으로 재정렬
            if (!imageIds.isEmpty()) {
                String updateSql = "UPDATE content_images SET image_order = ? WHERE id = ?";
                pstmt = conn.prepareStatement(updateSql);
                
                for (int i = 0; i < imageIds.size(); i++) {
                    pstmt.setInt(1, i + 1); // 새로운 순서 (1부터 시작)
                    pstmt.setInt(2, imageIds.get(i)); // 이미지 ID
                    pstmt.executeUpdate();
                }
                
                result = true;
                System.out.println("이미지 순서 재정렬 완료: " + hotplaceId + " -> " + imageIds.size() + "개 이미지");
            } else {
                // 이미지가 없으면 성공으로 처리
                result = true;
                System.out.println("재정렬할 이미지가 없음: " + hotplaceId);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("이미지 순서 재정렬 실패: " + hotplaceId + " - " + e.getMessage());
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 이미지 삭제 롤백 (복구)
    public boolean rollbackImageDelete(ContentImagesDto imageDto) {
        boolean result = false;
        getConnection();
        
        try {
            // 삭제된 이미지 정보를 다시 삽입
            String sql = "INSERT INTO content_images (id, hotplace_id, image_path, image_order, created_at) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, imageDto.getId());
            pstmt.setInt(2, imageDto.getHotplaceId());
            pstmt.setString(3, imageDto.getImagePath());
            pstmt.setInt(4, imageDto.getImageOrder());
            pstmt.setTimestamp(5, imageDto.getCreatedAt());
            
            int count = pstmt.executeUpdate();
            if (count > 0) {
                result = true;
                System.out.println("이미지 삭제 롤백 성공: " + imageDto.getId());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("이미지 삭제 롤백 실패: " + imageDto.getId() + " - " + e.getMessage());
        } finally {
            disConnection();
        }
        
        return result;
    }
    
    // 대표사진 변경 (해당 이미지를 1번 순서로 설정)
    public boolean setAsMainImage(int imageId, int hotplaceId) {
        boolean result = false;
        getConnection();
        
        try {
            // 1. 해당 이미지의 현재 순서 확인
            String selectSql = "SELECT image_order FROM content_images WHERE id = ?";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setInt(1, imageId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                System.out.println("이미지를 찾을 수 없음: " + imageId);
                return false;
            }
            
            int currentOrder = rs.getInt("image_order");
            System.out.println("이미지 " + imageId + "의 현재 순서: " + currentOrder);
            
            // 이미 1번이면 변경 불필요
            if (currentOrder == 1) {
                System.out.println("이미 1번 순서임: " + imageId);
                return true;
            }
            
            // 2. 기존 1번 이미지의 순서를 해당 이미지의 원래 순서로 변경
            String updateSql1 = "UPDATE content_images SET image_order = ? WHERE hotplace_id = ? AND image_order = 1";
            pstmt = conn.prepareStatement(updateSql1);
            pstmt.setInt(1, currentOrder);
            pstmt.setInt(2, hotplaceId);
            int count1 = pstmt.executeUpdate();
            System.out.println("기존 1번 이미지 순서 변경: " + count1 + "개");
            
            // 3. 해당 이미지를 1번 순서로 변경
            String updateSql2 = "UPDATE content_images SET image_order = 1 WHERE id = ?";
            pstmt = conn.prepareStatement(updateSql2);
            pstmt.setInt(1, imageId);
            int count2 = pstmt.executeUpdate();
            System.out.println("해당 이미지를 1번으로 변경: " + count2 + "개");
            
            // 4. 나머지 이미지들의 순서 재정렬 (2번부터)
            boolean reordered = reorderImagesAfterDelete(hotplaceId);
            
            if (count1 > 0 && count2 > 0 && reordered) {
                result = true;
                System.out.println("대표사진 변경 성공: " + imageId + " -> 1번 순서");
            } else {
                System.out.println("대표사진 변경 실패: " + imageId);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("대표사진 변경 중 오류: " + e.getMessage());
        } finally {
            disConnection();
        }
        
        return result;
    }
}
