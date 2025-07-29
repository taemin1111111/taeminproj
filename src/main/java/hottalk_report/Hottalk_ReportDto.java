package hottalk_report;

import java.sql.Timestamp;

public class Hottalk_ReportDto {
    private int id;
    private int post_id;
    private String reason;
    private String content;
    private Timestamp report_time;
    private String user_id;
    
    // 기본 생성자
    public Hottalk_ReportDto() {}
    
    // 전체 매개변수 생성자
    public Hottalk_ReportDto(int id, int post_id, String reason, String content, Timestamp report_time) {
        this.id = id;
        this.post_id = post_id;
        this.reason = reason;
        this.content = content;
        this.report_time = report_time;
    }
    
    // content 포함 생성자 (신고 추가용)
    public Hottalk_ReportDto(int post_id, String user_id, String reason, String content) {
        this.post_id = post_id;
        this.user_id = user_id;
        this.reason = reason;
        this.content = content;
    }
    
    // Getter와 Setter 메서드들
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getPost_id() {
        return post_id;
    }
    
    public void setPost_id(int post_id) {
        this.post_id = post_id;
    }
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public Timestamp getReport_time() {
        return report_time;
    }
    
    public void setReport_time(Timestamp report_time) {
        this.report_time = report_time;
    }

    public String getUser_id() {
        return user_id;
    }
    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }
}
