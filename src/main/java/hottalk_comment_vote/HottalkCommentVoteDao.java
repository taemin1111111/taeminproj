package hottalk_comment_vote;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class HottalkCommentVoteDao {
    DbConnect db = new DbConnect();

    // 투표 추가
    public boolean insertVote(HottalkCommentVoteDto dto) {
        String sql = "INSERT INTO hottalk_comment_vote (comment_id, user_id, ip_address, vote_type, created_at) VALUES (?, ?, ?, ?, NOW())";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getComment_id());
            pstmt.setString(2, dto.getUser_id());
            pstmt.setString(3, dto.getIp_address());
            pstmt.setString(4, dto.getVote_type());
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 특정 사용자의 특정 댓글 투표 조회 (로그인 사용자)
    public HottalkCommentVoteDto getVoteByUserAndComment(int comment_id, String user_id) {
        String sql = "SELECT * FROM hottalk_comment_vote WHERE comment_id = ? AND user_id = ? AND user_id IS NOT NULL";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            pstmt.setString(2, user_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapDto(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 특정 IP의 특정 댓글 투표 조회 (비로그인 사용자)
    public HottalkCommentVoteDto getVoteByIpAndComment(int comment_id, String ip_address) {
        String sql = "SELECT * FROM hottalk_comment_vote WHERE comment_id = ? AND ip_address = ? AND ip_address IS NOT NULL";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            pstmt.setString(2, ip_address);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapDto(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 투표 변경 (좋아요 → 싫어요 또는 그 반대) - 로그인 사용자
    public boolean updateVoteByUser(int comment_id, String user_id, String newVoteType) {
        String sql = "UPDATE hottalk_comment_vote SET vote_type = ?, created_at = NOW() WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newVoteType);
            pstmt.setInt(2, comment_id);
            pstmt.setString(3, user_id);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 투표 변경 (좋아요 → 싫어요 또는 그 반대) - 비로그인 사용자
    public boolean updateVoteByIp(int comment_id, String ip_address, String newVoteType) {
        String sql = "UPDATE hottalk_comment_vote SET vote_type = ?, created_at = NOW() WHERE comment_id = ? AND ip_address = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newVoteType);
            pstmt.setInt(2, comment_id);
            pstmt.setString(3, ip_address);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 투표 삭제 (투표 취소) - 로그인 사용자
    public boolean deleteVoteByUser(int comment_id, String user_id) {
        String sql = "DELETE FROM hottalk_comment_vote WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            pstmt.setString(2, user_id);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 투표 삭제 (투표 취소) - 비로그인 사용자
    public boolean deleteVoteByIp(int comment_id, String ip_address) {
        String sql = "DELETE FROM hottalk_comment_vote WHERE comment_id = ? AND ip_address = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            pstmt.setString(2, ip_address);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 댓글별 좋아요 수 조회
    public int getLikeCountByComment(int comment_id) {
        String sql = "SELECT COUNT(*) FROM hottalk_comment_vote WHERE comment_id = ? AND vote_type = 'like'";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 댓글별 싫어요 수 조회
    public int getDislikeCountByComment(int comment_id) {
        String sql = "SELECT COUNT(*) FROM hottalk_comment_vote WHERE comment_id = ? AND vote_type = 'dislike'";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 댓글별 모든 투표 조회
    public List<HottalkCommentVoteDto> getVotesByComment(int comment_id) {
        List<HottalkCommentVoteDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_comment_vote WHERE comment_id = ? ORDER BY created_at DESC";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(mapDto(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 사용자가 댓글에 투표했는지 확인 - 로그인 사용자
    public boolean hasUserVotedComment(int comment_id, String user_id) {
        String sql = "SELECT COUNT(*) FROM hottalk_comment_vote WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            pstmt.setString(2, user_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // IP가 댓글에 투표했는지 확인 - 비로그인 사용자
    public boolean hasIpVotedComment(int comment_id, String ip_address) {
        String sql = "SELECT COUNT(*) FROM hottalk_comment_vote WHERE comment_id = ? AND ip_address = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment_id);
            pstmt.setString(2, ip_address);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ResultSet을 DTO로 매핑
    private HottalkCommentVoteDto mapDto(ResultSet rs) throws SQLException {
        HottalkCommentVoteDto dto = new HottalkCommentVoteDto();
        dto.setId(rs.getInt("id"));
        dto.setComment_id(rs.getInt("comment_id"));
        dto.setUser_id(rs.getString("user_id"));
        dto.setIp_address(rs.getString("ip_address"));
        dto.setVote_type(rs.getString("vote_type"));
        dto.setCreated_at(rs.getTimestamp("created_at"));
        return dto;
    }
} 