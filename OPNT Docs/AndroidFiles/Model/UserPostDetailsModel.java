package com.opinito.social.Model;

import java.io.Serializable;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class UserPostDetailsModel implements Serializable {

    String POST_ID = "";
    String USERNAME = "";
    int TOPICID = 0;
    String DP_URL = "";
    String POST_DATETIME= "";
    String POST_CONTENT = "";
    private Object MEDIA_CONTENT = null;
    private Object MEDIA_FLAG = null;
    int LCOUNT = 0;
    int HCOUNT = 0;
    int POST_COMMENT_COUNT = 0;

    public UserPostDetailsModel(String POST_ID, String USERNAME, Object MEDIA_CONTENT, Object MEDIA_FLAG, int TOPICID,
                                String POST_DATETIME, String POST_CONTENT, int LCOUNT, int HCOUNT, int POST_COMMENT_COUNT, String DP_URL){
        this.POST_ID = POST_ID;
        this.USERNAME = USERNAME;
        this.TOPICID = TOPICID;
        this.POST_DATETIME = POST_DATETIME;
        this.POST_CONTENT = POST_CONTENT;
        this.MEDIA_CONTENT = MEDIA_CONTENT;
        this.MEDIA_FLAG = MEDIA_FLAG;
        this.LCOUNT = LCOUNT;
        this.HCOUNT = HCOUNT;
        this.POST_COMMENT_COUNT = POST_COMMENT_COUNT;
        this.DP_URL = DP_URL;
    }

    public int getPOST_COMMENT_COUNT() {
        return POST_COMMENT_COUNT;
    }

    public void setPOST_COMMENT_COUNT(int POST_COMMENT_COUNT) {
        this.POST_COMMENT_COUNT = POST_COMMENT_COUNT;
    }

    public int getHCOUNT() {
        return HCOUNT;
    }

    public void setHCOUNT(int HCOUNT) {
        this.HCOUNT = HCOUNT;
    }

    public int getLCOUNT() {
        return LCOUNT;
    }

    public void setLCOUNT(int LCOUNT) {
        this.LCOUNT = LCOUNT;
    }

    public String getPOST_CONTENT() {
        return POST_CONTENT;
    }

    public void setPOST_CONTENT(String POST_CONTENT) {
        this.POST_CONTENT = POST_CONTENT;
    }

    public String getPOST_DATETIME() {
        return POST_DATETIME;
    }

    public void setPOST_DATETIME(String POST_DATETIME) {
        this.POST_DATETIME = POST_DATETIME;
    }

    public int getTOPICID() {
        return TOPICID;
    }

    public void setTOPICID(int TOPICID) {
        this.TOPICID = TOPICID;
    }

    public String getUSERNAME() {
        return USERNAME;
    }

    public void setUSERNAME(String USERNAME) {
        this.USERNAME = USERNAME;
    }

    public String getPOST_ID() {
        return POST_ID;
    }

    public void setPOST_ID(String POST_ID) {
        this.POST_ID = POST_ID;
    }

    public String getDP_URL() {
        return DP_URL;
    }

    public void setDP_URL(String DP_URL) {
        this.DP_URL = DP_URL;
    }

    public Object getMEDIA_CONTENT() {
        return MEDIA_CONTENT;
    }

    public void setMEDIA_CONTENT(Object MEDIA_CONTENT) {
        this.MEDIA_CONTENT = MEDIA_CONTENT;
    }

    public Object getMEDIA_FLAG() {
        return MEDIA_FLAG;
    }

    public void setMEDIA_FLAG(Object MEDIA_FLAG) {
        this.MEDIA_FLAG = MEDIA_FLAG;
    }
}
