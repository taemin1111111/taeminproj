package review;

import java.sql.Timestamp;

public class ReviewDto {
    private int num;             // 후기 번호 (PK)
    private String userid;       // 사용자 식별자 (IP or 로그인 ID)
    private String nickname;     // 표시용 닉네임
    private String content;      // 후기 내용
    private double stars;        // 별점 (0.5 ~ 5.0)
    private String hg_id;        // 지역 or 휴게소 ID
    private String type;         // 업종 세부 설명 (예: 조용한 분위기)
    private int good;            // 추천 수
    private Timestamp writeday; // 작성일
    private int category_id;     // 카테고리 ID (1~5: 클럽, 포차 등)
    private String passwd;       // 비밀번호 (삭제용)

    // Getter & Setter
    public int getNum() {
        return num;
    }

    public void setNum(int num) {
        this.num = num;
    }

    public String getUserid() {
        return userid;
    }

  

	public void setUserid(String userid) {
        this.userid = userid;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public double getStars() {
        return stars;
    }

    public void setStars(double stars) {
        this.stars = stars;
    }

    public String getHg_id() {
        return hg_id;
    }

    public void setHg_id(String hg_id) {
        this.hg_id = hg_id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getGood() {
        return good;
    }

    public void setGood(int good) {
        this.good = good;
    }

    public Timestamp getWriteday() {
        return writeday;
    }

    public void setWriteday(Timestamp writeday) {
        this.writeday = writeday;
    }

    public int getCategory_id() {
        return category_id;
    }

    public void setCategory_id(int category_id) {
        this.category_id = category_id;
    }

    public String getPasswd() {
        return passwd;
    }

    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }
}
