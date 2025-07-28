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
    public boolean insertPost(HpostDto dto) {
        boolean success = false;
        String sql = "INSERT INTO hottalk_post (category_id, userid, title, content, photo1, photo2, photo3, views, likes, dislikes, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0, 0, NOW())";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getCategory_id());
            pstmt.setString(2, dto.getUserid());
            pstmt.setString(3, dto.getTitle());
            pstmt.setString(4, dto.getContent());
            pstmt.setString(5, dto.getPhoto1());
            pstmt.setString(6, dto.getPhoto2());
            pstmt.setString(7, dto.getPhoto3());
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) { e.printStackTrace(); }
        return success;
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

    // ResultSet -> Dto 매핑
    private HpostDto mapDto(ResultSet rs) throws SQLException {
        HpostDto dto = new HpostDto();
        dto.setId(rs.getInt("id"));
        dto.setCategory_id(rs.getInt("category_id"));
        dto.setUserid(rs.getString("userid"));
        dto.setTitle(rs.getString("title"));
        dto.setContent(rs.getString("content"));
        dto.setPhoto1(rs.getString("photo1"));
        dto.setPhoto2(rs.getString("photo2"));
        dto.setPhoto3(rs.getString("photo3"));
        dto.setViews(rs.getInt("views"));
        dto.setLikes(rs.getInt("likes"));
        dto.setDislikes(rs.getInt("dislikes"));
        dto.setCreated_at(rs.getTimestamp("created_at"));
        return dto;
    }
}
