package wishList;

import java.sql.Timestamp;

public class WishListDto {
    private int id;             // 찜 고유 번호
    private String userid;      // 유저 ID (member.userid 참조)
    private int place_id;       // 핫플레이스 ID (hotplace_info.id 참조)
    private Timestamp wish_date; // 찜한 날짜

    // 생성자
    public WishListDto() {}

    public WishListDto(int id, String userid, int place_id, Timestamp wish_date) {
        this.id = id;
        this.userid = userid;
        this.place_id = place_id;
        this.wish_date = wish_date;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public int getPlace_id() {
        return place_id;
    }

    public void setPlace_id(int place_id) {
        this.place_id = place_id;
    }

    public Timestamp getWish_date() {
        return wish_date;
    }

    public void setWish_date(Timestamp wish_date) {
        this.wish_date = wish_date;
    }
}
