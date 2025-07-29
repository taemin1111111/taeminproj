package hottalk_report;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class Hottalk_ReportDao {
    DbConnect db = new DbConnect();
    
    // 신고 추가
    public boolean insertReport(Hottalk_ReportDto dto) {
        boolean success = false;
        String sql = "INSERT INTO hottalk_report (post_id, reason, report_time) VALUES (?, ?, NOW())";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getPost_id());
            pstmt.setString(2, dto.getReason());
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
    
    // ResultSet -> Dto 매핑
    private Hottalk_ReportDto mapDto(ResultSet rs) throws SQLException {
        Hottalk_ReportDto dto = new Hottalk_ReportDto();
        dto.setId(rs.getInt("id"));
        dto.setPost_id(rs.getInt("post_id"));
        dto.setReason(rs.getString("reason"));
        dto.setReport_time(rs.getTimestamp("report_time"));
        return dto;
    }
}
