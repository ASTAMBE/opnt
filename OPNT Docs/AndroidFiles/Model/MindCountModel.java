package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class MindCountModel {
    @SerializedName("count")
    @Expose
    private String count;
    @SerializedName("topicname")
    @Expose
    private Object topicname;
    @SerializedName("code")
    @Expose
    private Object code;

    public String getCount() {
        return count;
    }

    public void setCount(String count) {
        this.count = count;
    }

    public Object getTopicName() {
        return topicname;
    }

    public void setTopicName(Object topicname) {
        this.topicname = topicname;
    }

    public Object getCode() {
        return code;
    }

    public void setCode(Object code) {
        this.code = code;
    }
}
