package Map;

public class MapDto {
    private int id;             // 고유 ID
    private String area;        // 대분류 지역 (예: 서울, 부산)
    private String region;      // 소지역 (예: 홍대, 강남)
    private double lat;         // 위도
    private double lng;         // 경도

    // Getter & Setter
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }

    public String getArea() {
        return area;
    }
    public void setArea(String area) {
        this.area = area;
    }

    public String getRegion() {
        return region;
    }
    public void setRegion(String region) {
        this.region = region;
    }

    public double getLat() {
        return lat;
    }
    public void setLat(double lat) {
        this.lat = lat;
    }

    public double getLng() {
        return lng;
    }
    public void setLng(double lng) {
        this.lng = lng;
    }
}
