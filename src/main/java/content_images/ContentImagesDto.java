package content_images;

import java.sql.Timestamp;

public class ContentImagesDto {
    private int id;
    private int hotplaceId;
    private String imagePath;
    private int imageOrder;
    private Timestamp createdAt;
    
    // 기본 생성자
    public ContentImagesDto() {}
    
    // 전체 매개변수 생성자
    public ContentImagesDto(int id, int hotplaceId, String imagePath, int imageOrder, Timestamp createdAt) {
        this.id = id;
        this.hotplaceId = hotplaceId;
        this.imagePath = imagePath;
        this.imageOrder = imageOrder;
        this.createdAt = createdAt;
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
    
    public String getImagePath() {
        return imagePath;
    }
    
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
    
    public int getImageOrder() {
        return imageOrder;
    }
    
    public void setImageOrder(int imageOrder) {
        this.imageOrder = imageOrder;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
