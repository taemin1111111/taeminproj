package hottalk_vote;

import java.sql.Timestamp;

public class HottalkVoteDto {
    private int id;                 // 투표 번호 (PK)
    private int post_id;            // 게시글 ID
    private String userid;          // 사용자 ID
    private String vote_type;       // 투표 타입 ("like" 또는 "dislike")
    private Timestamp created_at;   // 투표 시간

    // 기본 생성자
    public HottalkVoteDto() {}

    // 매개변수 생성자
    public HottalkVoteDto(int post_id, String userid, String vote_type) {
        this.post_id = post_id;
        this.userid = userid;
        this.vote_type = vote_type;
    }

    // Getter & Setter
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

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public String getVote_type() {
        return vote_type;
    }

    public void setVote_type(String vote_type) {
        this.vote_type = vote_type;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
} 