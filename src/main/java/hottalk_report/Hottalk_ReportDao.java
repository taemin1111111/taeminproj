package hottalk_report;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class Hottalk_ReportDao {
    DbConnect db = new DbConnect();
    
    // 신고 추가 (user_id 포함)
    public boolean insertReport(Hottalk_ReportDto dto) {
        boolean success = false;
        String sql = "INSERT INTO hottalk_report (post_id, user_id, reason, content, report_time) VALUES (?, ?, ?, ?, NOW())";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getPost_id());
            pstmt.setString(2, dto.getUser_id());
            pstmt.setString(3, dto.getReason());
            pstmt.setString(4, dto.getContent());
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }
    
    // 특정 글의 신고 목록 조회
    public List<Hottalk_ReportDto> getReportsByPostId(int postId) {
        List<Hottalk_ReportDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_report WHERE post_id = ? ORDER BY report_time DESC";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Hottalk_ReportDto dto = mapDto(rs);
                list.add(dto);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    
    // 전체 신고 목록 조회
    public List<Hottalk_ReportDto> getAllReports() {
        List<Hottalk_ReportDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_report ORDER BY report_time DESC";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Hottalk_ReportDto dto = mapDto(rs);
                list.add(dto);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    
    // 특정 신고 조회
    public Hottalk_ReportDto getReportById(int id) {
        Hottalk_ReportDto dto = null;
        String sql = "SELECT * FROM hottalk_report WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) dto = mapDto(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return dto;
    }
    
    // 신고 삭제
    public boolean deleteReport(int id) {
        boolean success = false;
        String sql = "DELETE FROM hottalk_report WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }
    
    // 특정 글의 신고 개수 조회
    public int getReportCountByPostId(int postId) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM hottalk_report WHERE post_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return count;
    }
    
    // ResultSet -> Dto 매핑 (user_id 포함)
    private Hottalk_ReportDto mapDto(ResultSet rs) throws SQLException {
        Hottalk_ReportDto dto = new Hottalk_ReportDto();
        dto.setId(rs.getInt("id"));
        dto.setPost_id(rs.getInt("post_id"));
        dto.setUser_id(rs.getString("user_id"));
        dto.setReason(rs.getString("reason"));
        dto.setContent(rs.getString("content"));
        dto.setReport_time(rs.getTimestamp("report_time"));
        return dto;
    }

    // 특정 글에 대해 해당 user_id가 이미 신고했는지 확인
    public boolean hasUserReported(int postId, String userId) {
        String sql = "SELECT COUNT(*) FROM hottalk_report WHERE post_id = ? AND user_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
