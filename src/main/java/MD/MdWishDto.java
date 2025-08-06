package MD;

import java.sql.Timestamp;

public class MdWishDto {
    private int wishId;
    private int mdId;
    private String userid;
    private Timestamp createdAt;
    
    // 기본 생성자
    public MdWishDto() {}
    
    // 전체 파라미터 생성자
    public MdWishDto(int wishId, int mdId, String userid, Timestamp createdAt) {
        this.wishId = wishId;
        this.mdId = mdId;
        this.userid = userid;
        this.createdAt = createdAt;
    }
    
    // Getter와 Setter
    public int getWishId() {
        return wishId;
    }
    
    public void setWishId(int wishId) {
        this.wishId = wishId;
    }
    
    public int getMdId() {
        return mdId;
    }
    
    public void setMdId(int mdId) {
        this.mdId = mdId;
    }
    
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
} 