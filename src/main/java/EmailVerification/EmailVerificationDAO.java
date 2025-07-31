package EmailVerification;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import DB.DbConnect;

public class EmailVerificationDAO {
    
    private final DbConnect db = new DbConnect();

    // 인증번호 저장
    public boolean insertVerification(EmailVerificationDTO dto) {
        String sql = "INSERT INTO email_verification (email, verification_code, expires_at, ip_address) VALUES (?, ?, ?, ?)";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dto.getEmail());
            pstmt.setString(2, dto.getVerificationCode());
            pstmt.setTimestamp(3, Timestamp.valueOf(dto.getExpiresAt()));
            pstmt.setString(4, dto.getIpAddress());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 이메일로 최신 인증번호 조회
    public EmailVerificationDTO getLatestVerificationByEmail(String email) {
        String sql = "SELECT * FROM email_verification WHERE email = ? ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToDto(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 인증번호 확인
    public boolean verifyCode(String email, String code) {
        String sql = "SELECT * FROM email_verification WHERE email = ? AND verification_code = ? AND expires_at > NOW() AND is_verified = FALSE ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            pstmt.setString(2, code);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // 인증 성공 시 is_verified를 TRUE로 업데이트
                    updateVerificationStatus(rs.getInt("id"));
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 인증 상태 업데이트
    private boolean updateVerificationStatus(int id) {
        String sql = "UPDATE email_verification SET is_verified = TRUE WHERE id = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 이메일 인증 완료 여부 확인
    public boolean isEmailVerified(String email) {
        String sql = "SELECT COUNT(*) FROM email_verification WHERE email = ? AND is_verified = TRUE";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 최근 1분 내 인증번호 발송 여부 확인 (중복 요청 방지)
    public boolean hasRecentVerification(String email) {
        String sql = "SELECT COUNT(*) FROM email_verification WHERE email = ? AND created_at > DATE_SUB(NOW(), INTERVAL 1 MINUTE)";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 만료된 인증번호 정리 (선택적)
    public int cleanupExpiredVerifications() {
        String sql = "DELETE FROM email_verification WHERE expires_at < NOW()";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ResultSet을 DTO로 매핑
    private EmailVerificationDTO mapRowToDto(ResultSet rs) throws SQLException {
        EmailVerificationDTO dto = new EmailVerificationDTO();
        dto.setId(rs.getInt("id"));
        dto.setEmail(rs.getString("email"));
        dto.setVerificationCode(rs.getString("verification_code"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            dto.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp expiresAt = rs.getTimestamp("expires_at");
        if (expiresAt != null) {
            dto.setExpiresAt(expiresAt.toLocalDateTime());
        }
        
        dto.setVerified(rs.getBoolean("is_verified"));
        dto.setIpAddress(rs.getString("ip_address"));
        
        return dto;
    }
} 