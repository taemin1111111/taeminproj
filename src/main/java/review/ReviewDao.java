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
 // ReviewDao.java
    public List<ReviewDto> getReviews(String hg_id, boolean isSigungu, int category_id) {
        List<ReviewDto> list = new ArrayList<>();
        String sql = isSigungu
          ? "SELECT * FROM review WHERE hg_id IN (SELECT dong FROM place_info WHERE sigungu = ?) AND category_id = ? ORDER BY writeday DESC"
          : "SELECT * FROM review WHERE hg_id = ? AND category_id = ? ORDER BY writeday DESC";

        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, hg_id);
            pstmt.setInt(2, category_id);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                ReviewDto dto = new ReviewDto();
                // dto 필드 매핑 (기존 getReviews와 동일)
                dto.setNum(rs.getInt("num"));
                dto.setUserid(rs.getString("userid"));
                dto.setNickname(rs.getString("nickname"));
                dto.setContent(rs.getString("content"));
                dto.setStars(rs.getDouble("stars"));
                dto.setHg_id(rs.getString("hg_id"));
                dto.setCategory_id(rs.getInt("category_id"));
                dto.setGood(rs.getInt("good"));
                dto.setWriteday(rs.getTimestamp("writeday"));
                dto.setType(rs.getString("type"));
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean hasAlreadyRecommended(int reviewNum, String userid) {
        String sql = "SELECT COUNT(*) FROM rgood "
                   + "WHERE review_num = ? AND userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, reviewNum);
            pstmt.setString(2, userid);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return true;  // 이미 추천함
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;  // 추천 가능
    }

    /**
     * 추천수 +1, rgood 테이블에 추천 기록 저장 (트랜잭션 처리)
     */
    public boolean recommendReview(int reviewNum, String userid) {
        Connection conn = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        boolean success = false;

        try {
            conn = db.getConnection();
            conn.setAutoCommit(false);

            // 1) review 테이블의 good 컬럼 +1
            String sql1 = "UPDATE review SET good = good + 1 WHERE num = ?";
            pstmt1 = conn.prepareStatement(sql1);
            pstmt1.setInt(1, reviewNum);
            int n1 = pstmt1.executeUpdate();

            // 2) rgood 테이블에 추천 기록 저장
            String sql2 = "INSERT INTO rgood (review_num, userid, goodday) VALUES (?, ?, NOW())";
            pstmt2 = conn.prepareStatement(sql2);
            pstmt2.setInt(1, reviewNum);
            pstmt2.setString(2, userid);
            int n2 = pstmt2.executeUpdate();

            if (n1 > 0 && n2 > 0) {
                conn.commit();
                success = true;
            } else {
                conn.rollback();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
        } finally {
            try { if (pstmt1 != null) pstmt1.close(); } catch (SQLException ignored) {}
            try { if (pstmt2 != null) pstmt2.close(); } catch (SQLException ignored) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException ignored) {}
        }

        return success;
    }

    // 리뷰 번호로 ReviewDto 반환
    public ReviewDto getReviewByNum(int num) {
        String sql = "SELECT * FROM review WHERE num = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, num);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                ReviewDto dto = new ReviewDto();
                dto.setNum(rs.getInt("num"));
                dto.setUserid(rs.getString("userid"));
                dto.setNickname(rs.getString("nickname"));
                dto.setContent(rs.getString("content"));
                dto.setStars(rs.getDouble("stars"));
                dto.setHg_id(rs.getString("hg_id"));
                dto.setCategory_id(rs.getInt("category_id"));
                dto.setGood(rs.getInt("good"));
                dto.setWriteday(rs.getTimestamp("writeday"));
                dto.setType(rs.getString("type"));
                dto.setPasswd(rs.getString("passwd"));
                return dto;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
