package Notice;

import DB.DbConnect;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NoticeDao {
    DbConnect db = new DbConnect();
    
    // 공지사항 목록 조회 (활성화된 것만, 상단고정 우선)
    public List<NoticeDto> getAllNotices() {
        List<NoticeDto> list = new ArrayList<>();
        String sql = "SELECT * FROM notice WHERE is_active = true ORDER BY pinned DESC, created_at DESC";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                NoticeDto dto = new NoticeDto();
                dto.setNoticeId(rs.getInt("notice_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setWriter(rs.getString("writer"));
                dto.setPhoto(rs.getString("photo"));
                dto.setPinned(rs.getBoolean("pinned"));
                dto.setViewCount(rs.getInt("view_count"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setUpdatedAt(rs.getTimestamp("updated_at"));
                dto.setActive(rs.getBoolean("is_active"));
                
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return list;
    }
    
    // 공지사항 상세 조회 (조회수 증가 포함)
    public NoticeDto getNoticeById(int noticeId) {
        NoticeDto dto = null;
        String sql = "SELECT * FROM notice WHERE notice_id = ? AND is_active = true";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, noticeId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                dto = new NoticeDto();
                dto.setNoticeId(rs.getInt("notice_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setWriter(rs.getString("writer"));
                dto.setPhoto(rs.getString("photo"));
                dto.setPinned(rs.getBoolean("pinned"));
                dto.setViewCount(rs.getInt("view_count"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setUpdatedAt(rs.getTimestamp("updated_at"));
                dto.setActive(rs.getBoolean("is_active"));
                
                // 조회수 증가
                updateViewCount(noticeId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return dto;
    }
    
    // 공지사항 작성
    public void insertNotice(NoticeDto dto) {
        String sql = "INSERT INTO notice (title, content, writer, photo, pinned, view_count, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getWriter());
            pstmt.setString(4, dto.getPhoto());
            pstmt.setBoolean(5, dto.isPinned());
            pstmt.setInt(6, dto.getViewCount());
            pstmt.setBoolean(7, dto.isActive());
            
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 공지사항 수정
    public void updateNotice(NoticeDto dto) {
        String sql = "UPDATE notice SET title = ?, content = ?, photo = ?, pinned = ? WHERE notice_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getPhoto());
            pstmt.setBoolean(4, dto.isPinned());
            pstmt.setInt(5, dto.getNoticeId());
            
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 공지사항 삭제 (실제 삭제 대신 비활성화)
    public void deleteNotice(int noticeId) {
        String sql = "UPDATE notice SET is_active = false WHERE notice_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, noticeId);
            
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 조회수 증가
    public void updateViewCount(int noticeId) {
        String sql = "UPDATE notice SET view_count = view_count + 1 WHERE notice_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, noticeId);
            
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 상단고정 토글
    public void togglePinned(int noticeId) {
        String sql = "UPDATE notice SET pinned = NOT pinned WHERE notice_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, noticeId);
            
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 전체 공지사항 수 조회
    public int getTotalCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM notice WHERE is_active = true";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return count;
    }
    
    // 페이징을 위한 공지사항 목록 조회
    public List<NoticeDto> getNoticesWithPaging(int start, int perPage) {
        List<NoticeDto> list = new ArrayList<>();
        String sql = "SELECT * FROM notice WHERE is_active = true ORDER BY pinned DESC, created_at DESC LIMIT ?, ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, perPage);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                NoticeDto dto = new NoticeDto();
                dto.setNoticeId(rs.getInt("notice_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setWriter(rs.getString("writer"));
                dto.setPhoto(rs.getString("photo"));
                dto.setPinned(rs.getBoolean("pinned"));
                dto.setViewCount(rs.getInt("view_count"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setUpdatedAt(rs.getTimestamp("updated_at"));
                dto.setActive(rs.getBoolean("is_active"));
                
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return list;
    }
}
