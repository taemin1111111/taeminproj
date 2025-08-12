package content_info;

import java.sql.Timestamp;

public class ContentInfoDto {
    private int id;
    private int hotplaceId;
    private String contentText;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 기본 생성자
    public ContentInfoDto() {}
    
    // 전체 매개변수 생성자
    public ContentInfoDto(int id, int hotplaceId, String contentText, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.hotplaceId = hotplaceId;
        this.contentText = contentText;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getter와 Setter
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getHotplaceId() {
        return hotplaceId;
    }
    
    public void setHotplaceId(int hotplaceId) {
        this.hotplaceId = hotplaceId;
    }
    
    public String getContentText() {
        return contentText;
    }
    
    public void setContentText(String contentText) {
        this.contentText = contentText;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
