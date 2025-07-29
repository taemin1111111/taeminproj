package hottalk_comment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class Hottalk_CommentDao {
    DbConnect db = new DbConnect();

    // 댓글 추가
    public boolean insertComment(Hottalk_CommentDto dto) {
        String sql = "INSERT INTO hottalk_comment (post_id, nickname, passwd, content, ip_address, likes, dislikes, created_at) VALUES (?, ?, ?, ?, ?, 0, 0, NOW())";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getPost_id());
            pstmt.setString(2, dto.getNickname());
            pstmt.setString(3, dto.getPasswd());
            pstmt.setString(4, dto.getContent());
            pstmt.setString(5, dto.getIp_address());
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 특정 글의 댓글 목록 조회
    public List<Hottalk_CommentDto> getCommentsByPostId(int postId) {
        List<Hottalk_CommentDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_comment WHERE post_id = ? ORDER BY created_at ASC";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(mapDto(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 특정 글의 댓글 개수 조회
    public int getCommentCountByPostId(int postId) {
        String sql = "SELECT COUNT(*) FROM hottalk_comment WHERE post_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // 댓글 삭제
    public boolean deleteComment(int id) {
        String sql = "DELETE FROM hottalk_comment WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 좋아요 증가
    public boolean increaseLikes(int id) {
        String sql = "UPDATE hottalk_comment SET likes = likes + 1 WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // 싫어요 증가
    public boolean increaseDislikes(int id) {
        String sql = "UPDATE hottalk_comment SET dislikes = dislikes + 1 WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ResultSet -> Dto 매핑
    private Hottalk_CommentDto mapDto(ResultSet rs) throws SQLException {
        Hottalk_CommentDto dto = new Hottalk_CommentDto();
        dto.setId(rs.getInt("id"));
        dto.setPost_id(rs.getInt("post_id"));
        dto.setNickname(rs.getString("nickname"));
        dto.setPasswd(rs.getString("passwd"));
        dto.setContent(rs.getString("content"));
        dto.setIp_address(rs.getString("ip_address"));
        dto.setLikes(rs.getInt("likes"));
        dto.setDislikes(rs.getInt("dislikes"));
        dto.setCreated_at(rs.getTimestamp("created_at"));
        return dto;
    }
} 