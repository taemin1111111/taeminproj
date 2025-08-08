package ClubGenre;

import java.sql.Timestamp;

public class ClubGenreDto {
    private int genreId;
    private String genreName;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isActive;
    
    // 기본 생성자
    public ClubGenreDto() {}
    
    // 생성자
    public ClubGenreDto(int genreId, String genreName) {
        this.genreId = genreId;
        this.genreName = genreName;
    }
    
    // Getter와 Setter
    public int getGenreId() {
        return genreId;
    }
    
    public void setGenreId(int genreId) {
        this.genreId = genreId;
    }
    
    public String getGenreName() {
        return genreName;
    }
    
    public void setGenreName(String genreName) {
        this.genreName = genreName;
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
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    @Override
    public String toString() {
        return "ClubGenreDto{" +
                "genreId=" + genreId +
                ", genreName='" + genreName + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                ", isActive=" + isActive +
                '}';
    }
}
