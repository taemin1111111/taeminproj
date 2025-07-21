package VoteNowHot;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
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
}
