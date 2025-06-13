package Member;

import java.sql.*;
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
            pstmt.setString(5, dto.getPhone());
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

}
