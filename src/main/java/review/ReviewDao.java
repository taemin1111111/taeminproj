package review;

import java.sql.*;
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
}
