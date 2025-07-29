package hottalk_report;

import java.sql.Timestamp;

public class Hottalk_ReportDto {
    private int id;
    private int post_id;
    private String reason;
    private Timestamp report_time;
    
    // 기본 생성자
    public Hottalk_ReportDto() {}
    
    // 전체 매개변수 생성자
    public Hottalk_ReportDto(int id, int post_id, String reason, Timestamp report_time) {
        this.id = id;
        this.post_id = post_id;
        this.reason = reason;
        this.report_time = report_time;
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
    
    public Timestamp getReport_time() {
        return report_time;
    }
    
    public void setReport_time(Timestamp report_time) {
        this.report_time = report_time;
    }
}
