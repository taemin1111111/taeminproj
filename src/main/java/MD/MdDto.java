package MD;

import java.sql.Timestamp;

public class MdDto {
    private int mdId;
    private String mdName;
    private String clubName;
    private String region;
    private String contact;
    private String description;
    private String photo;
    private Timestamp createdAt;
    private boolean isVisible;
    
    // 기본 생성자
    public MdDto() {}
    
    // 전체 생성자
    public MdDto(int mdId, String mdName, String clubName, String region, String contact, 
                 String description, String photo, Timestamp createdAt, boolean isVisible) {
        this.mdId = mdId;
        this.mdName = mdName;
        this.clubName = clubName;
        this.region = region;
        this.contact = contact;
        this.description = description;
        this.photo = photo;
        this.createdAt = createdAt;
        this.isVisible = isVisible;
    }
    
    // Getter와 Setter 메서드들
    public int getMdId() {
        return mdId;
    }
    
    public void setMdId(int mdId) {
        this.mdId = mdId;
    }
    
    public String getMdName() {
        return mdName;
    }
    
    public void setMdName(String mdName) {
        this.mdName = mdName;
    }
    
    public String getClubName() {
        return clubName;
    }
    
    public void setClubName(String clubName) {
        this.clubName = clubName;
    }
    
    public String getRegion() {
        return region;
    }
    
    public void setRegion(String region) {
        this.region = region;
    }
    
    public String getContact() {
        return contact;
    }
    
    public void setContact(String contact) {
        this.contact = contact;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getPhoto() {
        return photo;
    }
    
    public void setPhoto(String photo) {
        this.photo = photo;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public boolean isVisible() {
        return isVisible;
    }
    
    public void setVisible(boolean isVisible) {
        this.isVisible = isVisible;
    }
    
    @Override
    public String toString() {
        return "MdDto{" +
                "mdId=" + mdId +
                ", mdName='" + mdName + '\'' +
                ", clubName='" + clubName + '\'' +
                ", region='" + region + '\'' +
                ", contact='" + contact + '\'' +
                ", description='" + description + '\'' +
                ", photo='" + photo + '\'' +
                ", createdAt=" + createdAt +
                ", isVisible=" + isVisible +
                '}';
    }
} 