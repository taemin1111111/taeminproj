package hpost;

import java.sql.Timestamp;

public class HpostDto {
    private int id;
    private int category_id;
    private String userid;
    private String userip;
    private String title;
    private String content;
    private String photo1;
    private String photo2;
    private String photo3;
    private int views;
    private int likes;
    private int dislikes;
    private Timestamp created_at;
    private String nickname;
    private String passwd;
    private int reports;

    public HpostDto() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCategory_id() { return category_id; }
    public void setCategory_id(int category_id) { this.category_id = category_id; }

    public String getUserid() { return userid; }
    public void setUserid(String userid) { this.userid = userid; }

    public String getUserip() { return userip; }
    public void setUserip(String userip) { this.userip = userip; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getPhoto1() { return photo1; }
    public void setPhoto1(String photo1) { this.photo1 = photo1; }

    public String getPhoto2() { return photo2; }
    public void setPhoto2(String photo2) { this.photo2 = photo2; }

    public String getPhoto3() { return photo3; }
    public void setPhoto3(String photo3) { this.photo3 = photo3; }

    public int getViews() { return views; }
    public void setViews(int views) { this.views = views; }

    public int getLikes() { return likes; }
    public void setLikes(int likes) { this.likes = likes; }

    public int getDislikes() { return dislikes; }
    public void setDislikes(int dislikes) { this.dislikes = dislikes; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public String getPasswd() { return passwd; }
    public void setPasswd(String passwd) { this.passwd = passwd; }
    public int getReports() { return reports; }
    public void setReports(int reports) { this.reports = reports; }
}
