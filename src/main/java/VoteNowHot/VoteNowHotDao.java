package VoteNowHot;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import DB.DbConnect;

public class VoteNowHotDao {
    DbConnect db = new DbConnect();

    public void insertVote(VoteNowHotDto dto) throws SQLException {
        String sql1 = "INSERT INTO vote_nowhot (place_id, voter_id, congestion, gender_ratio, wait_time, voted_at) VALUES (?, ?, ?, ?, ?, ?)";
        String sql2 = "INSERT INTO vote_nowhot_log (place_id, voter_id, congestion, gender_ratio, wait_time, voted_at) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt1 = conn.prepareStatement(sql1);
             PreparedStatement pstmt2 = conn.prepareStatement(sql2)) {
            
            // 첫 번째 테이블 (vote_nowhot)에 insert
            pstmt1.setInt(1, dto.getPlaceId());
            pstmt1.setString(2, dto.getVoterId());
            pstmt1.setInt(3, dto.getCongestion());
            pstmt1.setInt(4, dto.getGenderRatio());
            pstmt1.setInt(5, dto.getWaitTime());
            pstmt1.setTimestamp(6, new java.sql.Timestamp(dto.getVotedAt().getTime()));
            pstmt1.executeUpdate();

            // 두 번째 테이블 (vote_nowhot_log)에 insert
            pstmt2.setInt(1, dto.getPlaceId());
            pstmt2.setString(2, dto.getVoterId());
            pstmt2.setInt(3, dto.getCongestion());
            pstmt2.setInt(4, dto.getGenderRatio());
            pstmt2.setInt(5, dto.getWaitTime());
            pstmt2.setTimestamp(6, new java.sql.Timestamp(dto.getVotedAt().getTime()));
            pstmt2.executeUpdate();
        }
    }

    // 중복 투표 여부 확인 (오늘 같은 가게에 이미 투표했는지)
    public boolean isAlreadyVotedToday(String voterId, int placeId) {
        String sql = "SELECT COUNT(*) FROM vote_nowhot WHERE voter_id = ? AND place_id = ? AND DATE(voted_at) = CURDATE()";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, voterId);
            pstmt.setInt(2, placeId);
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 오늘 해당 voterId가 투표한 서로 다른 가게 수
    public int getTodayVotePlaceCount(String voterId) {
        String sql = "SELECT COUNT(DISTINCT place_id) FROM vote_nowhot WHERE voter_id = ? AND DATE(voted_at) = CURDATE()";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, voterId);
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 특정 장소의 투표 트렌드 조회 (가장 많이 투표된 옵션들)
    public Map<String, String> getVoteTrends(int placeId) {
        Map<String, String> trends = new HashMap<>();
        
        try (Connection conn = db.getConnection()) {
            
            // 1. 혼잡도 트렌드 조회
            String sql1 = "SELECT congestion, COUNT(*) as cnt FROM vote_nowhot_log WHERE place_id = ? GROUP BY congestion ORDER BY cnt DESC LIMIT 1";
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setInt(1, placeId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        trends.put("congestion", String.valueOf(rs.getInt("congestion")));
                    } else {
                        trends.put("congestion", "0"); // 데이터 없음
                    }
                }
            }
            
            // 2. 성비 트렌드 조회
            String sql2 = "SELECT gender_ratio, COUNT(*) as cnt FROM vote_nowhot_log WHERE place_id = ? GROUP BY gender_ratio ORDER BY cnt DESC LIMIT 1";
            try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                pstmt.setInt(1, placeId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        trends.put("genderRatio", String.valueOf(rs.getInt("gender_ratio")));
                    } else {
                        trends.put("genderRatio", "0"); // 데이터 없음
                    }
                }
            }
            
            // 3. 대기시간 트렌드 조회
            String sql3 = "SELECT wait_time, COUNT(*) as cnt FROM vote_nowhot_log WHERE place_id = ? GROUP BY wait_time ORDER BY cnt DESC LIMIT 1";
            try (PreparedStatement pstmt = conn.prepareStatement(sql3)) {
                pstmt.setInt(1, placeId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        trends.put("waitTime", String.valueOf(rs.getInt("wait_time")));
                    } else {
                        trends.put("waitTime", "0"); // 데이터 없음
                    }
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 기본값 설정
            trends.put("congestion", "0");
            trends.put("genderRatio", "0");
            trends.put("waitTime", "0");
        }
        
        return trends;
    }
}
