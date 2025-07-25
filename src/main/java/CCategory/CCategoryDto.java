package CCategory;

public class CCategoryDto {
    private int id;         // 카테고리 고유 ID
    private String name;    // 카테고리 이름

    public CCategoryDto() {}

    public CCategoryDto(int id, String name) {
        this.id = id;
        this.name = name;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
