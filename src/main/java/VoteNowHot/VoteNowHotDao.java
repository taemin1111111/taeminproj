package VoteNowHot;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import DB.DbConnect;

public class VoteNowHotDao {
    DbConnect db = new DbConnect();

    public void insertVote(VoteNowHotDto dto) throws SQLException {
        String sql = "INSERT INTO votenowhot (place_id, voter_id, congestion, gender_ratio, wait_time, voted_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getPlaceId());
            pstmt.setString(2, dto.getVoterId());
            pstmt.setInt(3, dto.getCongestion());
            pstmt.setInt(4, dto.getGenderRatio());
            pstmt.setInt(5, dto.getWaitTime());
            pstmt.setTimestamp(6, new java.sql.Timestamp(dto.getVotedAt().getTime()));
            pstmt.executeUpdate();
        }
    }
}
