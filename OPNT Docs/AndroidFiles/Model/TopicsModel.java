package com.opinito.social.Model;

/**
 * Created by 502687702 on 7/6/2017.
 */

public class TopicsModel {
    int TOPICID = 0;
    String TOPIC = "";
    String CODE= "";

    public TopicsModel(int TOPICID,String TOPIC,String CODE){
        this.TOPIC = TOPIC;
        this.TOPICID = TOPICID;
        this.CODE = CODE;
    }

    public int getTOPICID() {
        return TOPICID;
    }

    public void setCODE(String CODE) {
        this.CODE = CODE;
    }

    public String getCODE() {
        return CODE;
    }

    public void setTOPIC(String TOPIC) {
        this.TOPIC = TOPIC;
    }

    public String getTOPIC() {
        return TOPIC;
    }

    public void setTOPICID(int TOPICID) {
        this.TOPICID = TOPICID;
    }
}
