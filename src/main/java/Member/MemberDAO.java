package Member;

import java.sql.*;
import java.util.Date;
import DB.DbConnect;

public class MemberDAO {

    DbConnect db = new DbConnect();

    // 회원가입 INSERT
    public boolean insertMember(MemberDTO dto) {
        boolean success = false;
        String sql = "INSERT INTO member (userid, passwd, name, nickname, phone, email, gender, birth, provider, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'A')";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, dto.getUserid());
            pstmt.setString(2, dto.getPasswd());
            pstmt.setString(3, dto.getName());
            pstmt.setString(4, dto.getNickname());
            pstmt.setString(5, dto.getPhone() == null ? null : dto.getPhone());
            pstmt.setString(6, dto.getEmail());
            pstmt.setString(7, dto.getGender());
            pstmt.setDate(8, dto.getBirth() == null ? null : new java.sql.Date(dto.getBirth().getTime()));
            pstmt.setString(9, dto.getProvider());

            int n = pstmt.executeUpdate();
            if (n > 0) success = true;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return success;
    }

    // 아이디 중복확인
    public boolean isDuplicateId(String userid) {
        boolean duplicate = false;
        String sql = "SELECT COUNT(*) FROM member WHERE userid=?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userid);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0)
                duplicate = true;
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return duplicate;
    }

    // 닉네임 중복확인
    public boolean isDuplicateNickname(String nickname) {
        boolean duplicate = false;
        String sql = "SELECT COUNT(*) FROM member WHERE nickname=?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nickname);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0)
                duplicate = true;
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return duplicate;
    }

    // 이메일 중복확인
    public boolean isDuplicateEmail(String email) {
        boolean duplicate = false;
        String sql = "SELECT COUNT(*) FROM member WHERE email=?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0)
                duplicate = true;
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return duplicate;
    }

    // ✅ 회원 정보 가져오기 (닉네임 조회용)
    public MemberDTO getMember(String userid) {
        MemberDTO dto = null;
        String sql = "SELECT * FROM member WHERE userid=?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userid);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new MemberDTO();
                dto.setUserid(rs.getString("userid"));
                dto.setPasswd(rs.getString("passwd"));
                dto.setName(rs.getString("name"));
                dto.setNickname(rs.getString("nickname"));
                dto.setPhone(rs.getString("phone"));
                dto.setEmail(rs.getString("email"));
                dto.setGender(rs.getString("gender"));
                dto.setBirth(rs.getDate("birth"));
                dto.setProvider(rs.getString("provider"));
                dto.setStatus(rs.getString("status"));
                dto.setRegdate(rs.getTimestamp("regdate"));
                dto.setUpdate_date(rs.getTimestamp("update_date"));
            }
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dto;
    }

    // Connection 객체 반환 (트랜잭션용)
    public Connection getConnection() throws SQLException {
        return db.getConnection();
    }

    // 회원 삭제
    public boolean deleteMember(String userid, Connection conn) {
        boolean success = false;
        String sql = "DELETE FROM member WHERE userid=?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userid);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return success;
    }

    // 닉네임만 업데이트
    public boolean updateNickname(String userid, String nickname) {
        boolean success = false;
        String sql = "UPDATE member SET nickname = ?, update_date = NOW() WHERE userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nickname);
            pstmt.setString(2, userid);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return success;
    }

    // 닉네임과 비밀번호 업데이트
    public boolean updateProfile(String userid, String nickname, String newPassword) {
        boolean success = false;
        String sql = "UPDATE member SET nickname = ?, passwd = ?, update_date = NOW() WHERE userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nickname);
            pstmt.setString(2, newPassword);
            pstmt.setString(3, userid);
            int n = pstmt.executeUpdate();
            if (n > 0) success = true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return success;
    }

    // ✅ 전체 회원 목록 가져오기 (관리자용)
    public java.util.List<MemberDTO> getAllMembers() {
        java.util.List<MemberDTO> memberList = new java.util.ArrayList<>();
        String sql = "SELECT * FROM member ORDER BY regdate DESC";
        
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                MemberDTO dto = new MemberDTO();
                dto.setUserid(rs.getString("userid"));
                dto.setPasswd(rs.getString("passwd"));
                dto.setName(rs.getString("name"));
                dto.setNickname(rs.getString("nickname"));
                dto.setPhone(rs.getString("phone"));
                dto.setEmail(rs.getString("email"));
                dto.setGender(rs.getString("gender"));
                dto.setBirth(rs.getDate("birth"));
                dto.setProvider(rs.getString("provider"));
                dto.setStatus(rs.getString("status"));
                dto.setRegdate(rs.getTimestamp("regdate"));
                dto.setUpdate_date(rs.getTimestamp("update_date"));
                memberList.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return memberList;
    }

    // ✅ 회원 삭제 (관리자용)
    public boolean deleteMember(String userid) {
        Connection conn = null;
        try {
            conn = db.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 1. wishlist 테이블에서 해당 회원 데이터 삭제
            String deleteWishlistSql = "DELETE FROM wishlist WHERE userid = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteWishlistSql)) {
                pstmt.setString(1, userid);
                pstmt.executeUpdate();
            }
            
            // 2. hottalk_vote 테이블에서 해당 회원 데이터 삭제
            try {
                String deleteVoteSql = "DELETE FROM hottalk_vote WHERE userid = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteVoteSql)) {
                    pstmt.setString(1, userid);
                    pstmt.executeUpdate();
                }
            } catch (SQLException e) {
                // 테이블이나 컬럼이 존재하지 않는 경우 무시
            }
            
            // 3. hottalk_comment_vote 테이블에서 해당 회원 데이터 삭제
            try {
                String deleteCommentVoteSql = "DELETE FROM hottalk_comment_vote WHERE userid = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteCommentVoteSql)) {
                    pstmt.setString(1, userid);
                    pstmt.executeUpdate();
                }
            } catch (SQLException e) {
                // 테이블이나 컬럼이 존재하지 않는 경우 무시
            }
            
            // 4. hottalk_comment 테이블에서 해당 회원 데이터 삭제
            try {
                String deleteCommentSql = "DELETE FROM hottalk_comment WHERE userid = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteCommentSql)) {
                    pstmt.setString(1, userid);
                    pstmt.executeUpdate();
                }
            } catch (SQLException e) {
                // 테이블이나 컬럼이 존재하지 않는 경우 무시
            }
            
            // 5. hpost 테이블에서 해당 회원 데이터 삭제
            try {
                String deleteHpostSql = "DELETE FROM hpost WHERE userid = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteHpostSql)) {
                    pstmt.setString(1, userid);
                    pstmt.executeUpdate();
                }
            } catch (SQLException e) {
                // 테이블이나 컬럼이 존재하지 않는 경우 무시
            }
            
            // 6. review 테이블에서 해당 회원 데이터 삭제
            try {
                String deleteReviewSql = "DELETE FROM review WHERE userid = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteReviewSql)) {
                    pstmt.setString(1, userid);
                    pstmt.executeUpdate();
                }
            } catch (SQLException e) {
                // 테이블이나 컬럼이 존재하지 않는 경우 무시
            }
            
            // 7. md_wish 테이블에서 해당 회원 데이터 삭제
            try {
                String deleteMdWishSql = "DELETE FROM md_wish WHERE userid = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteMdWishSql)) {
                    pstmt.setString(1, userid);
                    pstmt.executeUpdate();
                }
            } catch (SQLException e) {
                // 테이블이나 컬럼이 존재하지 않는 경우 무시
            }
            
            // 8. member 테이블에서 회원 삭제
            String deleteMemberSql = "DELETE FROM member WHERE userid = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteMemberSql)) {
                pstmt.setString(1, userid);
                int result = pstmt.executeUpdate();
                
                if (result > 0) {
                    conn.commit(); // 트랜잭션 커밋
                    return true;
                } else {
                    conn.rollback(); // 트랜잭션 롤백
                    return false;
                }
            }
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // 오류 시 롤백
                } catch (SQLException rollbackEx) {
                    // 롤백 실패 시 무시
                }
            }
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // 오류 시 롤백
                } catch (SQLException rollbackEx) {
                    // 롤백 실패 시 무시
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // 자동커밋 복원
                    conn.close();
                } catch (SQLException e) {
                    // 연결 종료 실패 시 무시
                }
            }
        }
    }

    // 회원 상태 업데이트
    public boolean updateMemberStatus(String userid, String status) {
        String sql = "UPDATE member SET status = ?, update_date = NOW() WHERE userid = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            pstmt.setString(2, userid);
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

}
