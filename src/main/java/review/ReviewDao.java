package review;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import DB.DbConnect;

public class ReviewDao {
    DbConnect db = new DbConnect();

    // ✅ 1. 단일 지역(예: "역삼")의 평균 평점
    public double getAverageStars(String hg_id) {
        double avg = 0;
        String sql = "SELECT IFNULL(ROUND(AVG(stars), 1), 0) FROM review WHERE hg_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, hg_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                avg = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return avg;
    }

    // ✅ 2. 단일 지역(예: "역삼")의 리뷰 수
    public int getReviewCount(String hg_id) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM review WHERE hg_id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, hg_id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    // ✅ 3. hg_id LIKE '강남구%' 형태로 평균 구하기 (Prefix 방식)
    public double getAverageStarsByPrefix(String prefix) {
        double avg = 0;
        String sql = "SELECT IFNULL(ROUND(AVG(stars), 1), 0) FROM review WHERE hg_id LIKE ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, prefix + "%");
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                avg = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return avg;
    }

    // ✅ 4. hg_id LIKE '강남구%' 형태로 리뷰 수 구하기 (Prefix 방식)
    public int getReviewCountByPrefix(String prefix) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM review WHERE hg_id LIKE ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, prefix + "%");
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    // ✅ 5. 시군구 기준 (예: "강남구") 전체 동의 평균 (MAP으로 넘길 때 쓰기 좋음)
    public double getAverageStarsBySigungu(String sigungu) {
        double avg = 0;
        String sql = "SELECT IFNULL(ROUND(AVG(stars), 1), 0) FROM review WHERE hg_id IN (SELECT dong FROM place_info WHERE sigungu = ?)";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, sigungu);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                avg = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return avg;
    }

    // ✅ 6. 시군구 기준 전체 동의 리뷰 수
    public int getReviewCountBySigungu(String sigungu) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM review WHERE hg_id IN (SELECT dong FROM place_info WHERE sigungu = ?)";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, sigungu);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }
    public boolean insertReview(ReviewDto dto) {
        boolean success = false;
        String sql = "INSERT INTO review (userid, nickname, content, stars, hg_id, type, good, writeday, category_id, passwd) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 0, NOW(), ?, ?)";

        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, dto.getUserid());
            pstmt.setString(2, dto.getNickname());
            pstmt.setString(3, dto.getContent());
            pstmt.setDouble(4, dto.getStars());
            pstmt.setString(5, dto.getHg_id());
            pstmt.setString(6, dto.getType());
            pstmt.setInt(7, dto.getCategory_id());
            pstmt.setString(8, dto.getPasswd());

            int n = pstmt.executeUpdate();
            if (n > 0) success = true;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return success;
    }
    public boolean isAlreadyExist(String userid, String hg_id, int category_id) {
        boolean result = false;
        Connection conn = db.getConnection();
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String sql = "SELECT COUNT(*) FROM review WHERE userid=? AND hg_id=? AND category_id=?";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            pstmt.setString(2, hg_id);
            pstmt.setInt(3, category_id);
            rs = pstmt.executeQuery();
            if(rs.next() && rs.getInt(1) > 0) {
                result = true;
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        return result;
    }
   //평점 리스트 뽑기
    public List<ReviewDto> getReviews(String hg_id, boolean isSigungu) {
        List<ReviewDto> list = new ArrayList<>();
        String sql = isSigungu
            ? "SELECT * FROM review WHERE hg_id IN (SELECT dong FROM place_info WHERE sigungu = ?) ORDER BY writeday DESC"
            : "SELECT * FROM review WHERE hg_id = ? ORDER BY writeday DESC";

        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, hg_id);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                ReviewDto dto = new ReviewDto();
                dto.setNum(rs.getInt("num"));
                dto.setUserid(rs.getString("userid"));
                dto.setNickname(rs.getString("nickname"));
                dto.setContent(rs.getString("content"));
                dto.setStars(rs.getDouble("stars"));
                dto.setHg_id(rs.getString("hg_id"));
                dto.setCategory_id(rs.getInt("category_id"));
                dto.setPasswd(rs.getString("passwd"));
                dto.setWriteday(rs.getTimestamp("writeday"));
                dto.setGood(rs.getInt("good"));
                dto.setType(rs.getString("type"));
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    
}
