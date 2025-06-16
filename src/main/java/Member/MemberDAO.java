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

}
