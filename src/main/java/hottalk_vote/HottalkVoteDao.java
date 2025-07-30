package hottalk_vote;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class HottalkVoteDao {
    DbConnect db = new DbConnect();

    // 투표 추가
    public boolean insertVote(HottalkVoteDto dto) {
        String sql = "INSERT INTO hottalk_vote (post_id, userid, vote_type, created_at) VALUES (?, ?, ?, NOW())";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getPost_id());
            pstmt.setString(2, dto.getUserid());
            pstmt.setString(3, dto.getVote_type());
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 특정 사용자의 특정 게시글 투표 조회
    public HottalkVoteDto getVoteByUserAndPost(int post_id, String userid) {
        String sql = "SELECT * FROM hottalk_vote WHERE post_id = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, post_id);
            pstmt.setString(2, userid);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapDto(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 투표 변경 (좋아요 → 싫어요 또는 그 반대)
    public boolean updateVote(int post_id, String userid, String newVoteType) {
        String sql = "UPDATE hottalk_vote SET vote_type = ?, created_at = NOW() WHERE post_id = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newVoteType);
            pstmt.setInt(2, post_id);
            pstmt.setString(3, userid);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 투표 삭제 (투표 취소)
    public boolean deleteVote(int post_id, String userid) {
        String sql = "DELETE FROM hottalk_vote WHERE post_id = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, post_id);
            pstmt.setString(2, userid);
            int n = pstmt.executeUpdate();
            return n > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 게시글별 좋아요 수 조회
    public int getLikeCountByPost(int post_id) {
        String sql = "SELECT COUNT(*) FROM hottalk_vote WHERE post_id = ? AND vote_type = 'like'";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, post_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 게시글별 싫어요 수 조회
    public int getDislikeCountByPost(int post_id) {
        String sql = "SELECT COUNT(*) FROM hottalk_vote WHERE post_id = ? AND vote_type = 'dislike'";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, post_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 게시글의 모든 투표 조회
    public List<HottalkVoteDto> getVotesByPost(int post_id) {
        List<HottalkVoteDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_vote WHERE post_id = ? ORDER BY created_at DESC";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, post_id);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(mapDto(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 사용자가 특정 게시글에 투표했는지 확인
    public boolean hasUserVoted(int post_id, String userid) {
        String sql = "SELECT COUNT(*) FROM hottalk_vote WHERE post_id = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, post_id);
            pstmt.setString(2, userid);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ResultSet -> Dto 매핑
    private HottalkVoteDto mapDto(ResultSet rs) throws SQLException {
        HottalkVoteDto dto = new HottalkVoteDto();
        dto.setId(rs.getInt("id"));
        dto.setPost_id(rs.getInt("post_id"));
        dto.setUserid(rs.getString("userid"));
        dto.setVote_type(rs.getString("vote_type"));
        dto.setCreated_at(rs.getTimestamp("created_at"));
        return dto;
    }
} 