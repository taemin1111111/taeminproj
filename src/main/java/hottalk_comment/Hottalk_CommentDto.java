package hottalk_comment;

import java.sql.Timestamp;

public class Hottalk_CommentDto {
    private int id;
    private int post_id;
    private String nickname;
    private String passwd;
    private String content;
    private String ip_address;
    private String id_address;
    private int likes;
    private int dislikes;
    private Timestamp created_at;

    public Hottalk_CommentDto() {}

    // Getter/Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPost_id() { return post_id; }
    public void setPost_id(int post_id) { this.post_id = post_id; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getPasswd() { return passwd; }
    public void setPasswd(String passwd) { this.passwd = passwd; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getIp_address() { return ip_address; }
    public void setIp_address(String ip_address) { this.ip_address = ip_address; }

    public String getId_address() { return id_address; }
    public void setId_address(String id_address) { this.id_address = id_address; }



    public int getLikes() { return likes; }
    public void setLikes(int likes) { this.likes = likes; }

    public int getDislikes() { return dislikes; }
    public void setDislikes(int dislikes) { this.dislikes = dislikes; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }
} 