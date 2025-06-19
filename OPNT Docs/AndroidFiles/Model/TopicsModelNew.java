package com.opinito.social.Model;

public class TopicsModelNew {

    int CTOPIC = 0;
    String TOPIC = "";
    String CODE = "";

    public TopicsModelNew(int CTOPIC, String TOPIC, String CODE) {
        this.TOPIC = TOPIC;
        this.CTOPIC = CTOPIC;
        this.CODE = CODE;
    }

    public int getTOPICID() {
        return CTOPIC;
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

    public void setTOPICID(int CTOPIC) {
        this.CTOPIC = CTOPIC;
    }
}
