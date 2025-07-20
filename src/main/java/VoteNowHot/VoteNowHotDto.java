package VoteNowHot;

import java.util.Date;

public class VoteNowHotDto {
    private int id;
    private int placeId;
    private String voterId;
    private int congestion;
    private int genderRatio;
    private int waitTime;
    private Date votedAt;

    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public int getPlaceId() {
        return placeId;
    }
    public void setPlaceId(int placeId) {
        this.placeId = placeId;
    }
    public String getVoterId() {
        return voterId;
    }
    public void setVoterId(String voterId) {
        this.voterId = voterId;
    }
    public int getCongestion() {
        return congestion;
    }
    public void setCongestion(int congestion) {
        this.congestion = congestion;
    }
    public int getGenderRatio() {
        return genderRatio;
    }
    public void setGenderRatio(int genderRatio) {
        this.genderRatio = genderRatio;
    }
    public int getWaitTime() {
        return waitTime;
    }
    public void setWaitTime(int waitTime) {
        this.waitTime = waitTime;
    }
    public Date getVotedAt() {
        return votedAt;
    }
    public void setVotedAt(Date votedAt) {
        this.votedAt = votedAt;
    }
}
