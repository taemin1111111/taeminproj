package hpost;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class HpostDao {
    DbConnect db = new DbConnect();

    // 전체 글 목록 조회 (페이징)
    public List<HpostDto> getAllPosts(int start, int perPage) {
        List<HpostDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_post ORDER BY created_at DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, start);
            pstmt.setInt(2, perPage);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                HpostDto dto = mapDto(rs);
                list.add(dto);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 카테고리별 글 목록 조회 (페이징)
    public List<HpostDto> getPostsByCategory(int category_id, int start, int perPage) {
        List<HpostDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_post WHERE category_id = ? ORDER BY created_at DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, category_id);
            pstmt.setInt(2, start);
            pstmt.setInt(3, perPage);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                HpostDto dto = mapDto(rs);
                list.add(dto);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 글 상세 조회
    public HpostDto getPostById(int id) {
        HpostDto dto = null;
        String sql = "SELECT * FROM hottalk_post WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) dto = mapDto(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return dto;
    }

    // 글 작성
    public int insertPost(HpostDto dto) {
        int generatedId = -1;
        String sql = "INSERT INTO hottalk_post (category_id, userid, userip, nickname, passwd, title, content, photo1, photo2, photo3, views, likes, dislikes, reports, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, 0, NOW())";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, dto.getCategory_id());
            pstmt.setString(2, dto.getUserid());
            pstmt.setString(3, dto.getUserip());
            pstmt.setString(4, dto.getNickname());
            pstmt.setString(5, dto.getPasswd());
            pstmt.setString(6, dto.getTitle());
            pstmt.setString(7, dto.getContent());
            pstmt.setString(8, dto.getPhoto1());
            pstmt.setString(9, dto.getPhoto2());
            pstmt.setString(10, dto.getPhoto3());
            int n = pstmt.executeUpdate();
            if (n > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedId = rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return generatedId;
    }

    // 글 수정
    public boolean updatePost(HpostDto dto) {
        boolean success = false;
        String sql = "UPDATE hottalk_post SET title = ?, content = ?, photo1 = ?, photo2 = ?, photo3 = ? WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getPhoto1());
            pstmt.setString(4, dto.getPhoto2());
            pstmt.setString(5, dto.getPhoto3());
            pstmt.setInt(6, dto.getId());
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }

    // 글 삭제
    public boolean deletePost(int id) {
        boolean success = false;
        String sql = "DELETE FROM hottalk_post WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }

    // 조회수 증가
    public boolean increaseViews(int id) {
        boolean success = false;
        String sql = "UPDATE hottalk_post SET views = views + 1 WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }

    // 좋아요 증가
    public boolean increaseLikes(int id) {
        boolean success = false;
        String sql = "UPDATE hottalk_post SET likes = likes + 1 WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }

    // 싫어요 증가
    public boolean increaseDislikes(int id) {
        boolean success = false;
        String sql = "UPDATE hottalk_post SET dislikes = dislikes + 1 WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }

    // 좋아요 감소
    public boolean decreaseLikes(int id) {
        boolean success = false;
        String sql = "UPDATE hottalk_post SET likes = GREATEST(likes - 1, 0) WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }

    // 싫어요 감소
    public boolean decreaseDislikes(int id) {
        boolean success = false;
        String sql = "UPDATE hottalk_post SET dislikes = GREATEST(dislikes - 1, 0) WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }



    // 신고수 증가
    public boolean increaseReports(int id) {
        boolean success = false;
        String sql = "UPDATE hottalk_post SET reports = reports + 1 WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
    }

    // 전체 글 개수 조회
    public int getTotalCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM hottalk_post";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return count;
    }

    // 카테고리별 글 개수 조회
    public int getTotalCountByCategory(int category_id) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM hottalk_post WHERE category_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, category_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return count;
    }

    // 카테고리별 인기글 목록 조회 (페이징) - 조회수 20%, 좋아요 50%, 댓글 30%
    public List<HpostDto> getPopularPostsByCategory(int category_id, int start, int perPage) {
        List<HpostDto> list = new ArrayList<>();
        String sql = "SELECT p.*, " +
                    "COALESCE(c.comment_count, 0) as comment_count, " +
                    "(p.views * 0.2 + p.likes * 0.5 + COALESCE(c.comment_count, 0) * 0.3) as popularity_score " +
                    "FROM hottalk_post p " +
                    "LEFT JOIN (SELECT post_id, COUNT(*) as comment_count FROM hottalk_comment GROUP BY post_id) c ON p.id = c.post_id " +
                    "WHERE p.category_id = ? " +
                    "ORDER BY popularity_score DESC, p.created_at DESC " +
                    "LIMIT ?, ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, category_id);
            pstmt.setInt(2, start);
            pstmt.setInt(3, perPage);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                HpostDto dto = mapDto(rs);
                list.add(dto);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 해당 id가 최신순(내림차순)으로 몇 번째 글인지 반환
    public int getRowNumberById(int id, int category_id) {
        int rowNum = 1;
        String sql = "SELECT COUNT(*) FROM hottalk_post WHERE category_id = ? AND id > ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, category_id);
            pstmt.setInt(2, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                rowNum = rs.getInt(1) + 1;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return rowNum;
    }

    // 사용자별 게시글 조회 (최신순)
    public List<HpostDto> getPostsByUserid(String userid, int limit) {
        List<HpostDto> list = new ArrayList<>();
        String sql = "SELECT * FROM hottalk_post WHERE userid = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            pstmt.setInt(2, limit);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                HpostDto dto = mapDto(rs);
                list.add(dto);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // 사용자별 게시글 개수 조회
    public int getPostCountByUserid(String userid) {
        String sql = "SELECT COUNT(*) FROM hottalk_post WHERE userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // 회원 탈퇴용: 사용자의 모든 게시글 삭제
    public boolean deleteAllPostsByUserid(String userid, Connection conn) {
        String sql = "DELETE FROM hottalk_post WHERE userid = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ResultSet -> Dto 매핑
    private HpostDto mapDto(ResultSet rs) throws SQLException {
        HpostDto dto = new HpostDto();
        dto.setId(rs.getInt("id"));
        dto.setCategory_id(rs.getInt("category_id"));
        dto.setUserid(rs.getString("userid"));
        dto.setUserip(rs.getString("userip"));
        dto.setNickname(rs.getString("nickname"));
        dto.setPasswd(rs.getString("passwd"));
        dto.setTitle(rs.getString("title"));
        dto.setContent(rs.getString("content"));
        dto.setPhoto1(rs.getString("photo1"));
        dto.setPhoto2(rs.getString("photo2"));
        dto.setPhoto3(rs.getString("photo3"));
        dto.setViews(rs.getInt("views"));
        dto.setLikes(rs.getInt("likes"));
        dto.setDislikes(rs.getInt("dislikes"));
        dto.setReports(rs.getInt("reports"));
        dto.setCreated_at(rs.getTimestamp("created_at"));
        return dto;
    }

    // 특정 게시글의 댓글 수 조회
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
}
