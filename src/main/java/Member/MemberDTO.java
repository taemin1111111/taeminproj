package Member;

import java.sql.Timestamp;
import java.util.Date;

public class MemberDTO {

    private String userid;
    private String passwd;
    private String name;
    private String nickname;
    private String phone;
    private String email;
    private String gender;
    private Date birth;
    private String provider;
    private String status;
    private Timestamp regdate;
    private Timestamp update_date;

    // 기본 생성자
    public MemberDTO() {}

    // getter & setter
    public String getUserid() {
        return userid;
    }
    public void setUserid(String userid) {
        this.userid = userid;
    }
    public String getPasswd() {
        return passwd;
    }
    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getNickname() {
        return nickname;
    }
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getGender() {
        return gender;
    }
    public void setGender(String gender) {
        this.gender = gender;
    }
    public Date getBirth() {
        return birth;
    }
    public void setBirth(Date birth) {
        this.birth = birth;
    }
    public String getProvider() {
        return provider;
    }
    public void setProvider(String provider) {
        this.provider = provider;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public Timestamp getRegdate() {
        return regdate;
    }
    public void setRegdate(Timestamp regdate) {
        this.regdate = regdate;
    }
    public Timestamp getUpdate_date() {
        return update_date;
    }
    public void setUpdate_date(Timestamp update_date) {
        this.update_date = update_date;
    }
}
