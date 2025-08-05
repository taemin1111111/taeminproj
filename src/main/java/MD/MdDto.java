package MD;

import java.sql.Timestamp;

public class MdDto {
    private int mdId;
    private int placeId;  // hotplace_info.id를 참조
    private String mdName;
    private String contact;
    private String description;
    private String photo;
    private Timestamp createdAt;
    private boolean isVisible;
    
    // 기본 생성자
    public MdDto() {}
    
    // 전체 생성자
    public MdDto(int mdId, int placeId, String mdName, String contact, 
                 String description, String photo, Timestamp createdAt, boolean isVisible) {
        this.mdId = mdId;
        this.placeId = placeId;
        this.mdName = mdName;
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
    
    public int getPlaceId() {
        return placeId;
    }
    
    public void setPlaceId(int placeId) {
        this.placeId = placeId;
    }
    
    public String getMdName() {
        return mdName;
    }
    
    public void setMdName(String mdName) {
        this.mdName = mdName;
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
                ", placeId=" + placeId +
                ", mdName='" + mdName + '\'' +
                ", contact='" + contact + '\'' +
                ", description='" + description + '\'' +
                ", photo='" + photo + '\'' +
                ", createdAt=" + createdAt +
                ", isVisible=" + isVisible +
                '}';
    }
} 