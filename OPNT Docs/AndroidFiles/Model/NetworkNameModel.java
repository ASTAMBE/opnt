package com.opinito.social.Model;

import java.io.Serializable;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class NetworkNameModel implements Serializable {
    String USERID = "";
    int TOPICID = 0;
    double NET_STRENGTH = 0;
    String USERNAME = "";
    String IN_NW_SINCE = "";
    String DP_URL = "";

    public String getDP_URL() {
        return DP_URL;
    }

    public void setDP_URL(String DP_URL) {
        this.DP_URL = DP_URL;
    }

    public String getIN_NW_SINCE() {
        return IN_NW_SINCE;
    }

    public void setIN_NW_SINCE(String IN_NW_SINCE) {
        this.IN_NW_SINCE = IN_NW_SINCE;
    }

    public String getUSERNAME() {
        return USERNAME;
    }

    public void setUSERNAME(String USERNAME) {
        this.USERNAME = USERNAME;
    }

    public double getNET_STRENGTH() {
        return NET_STRENGTH;
    }

    public void setNET_STRENGTH(double NET_STRENGTH) {
        this.NET_STRENGTH = NET_STRENGTH;
    }

    public String getUSERID() {
        return USERID;
    }

    public void setUSERID(String USERID) {
        this.USERID = USERID;
    }

    public int getTOPICID() {
        return TOPICID;
    }

    public void setTOPICID(int TOPICID) {
        this.TOPICID = TOPICID;
    }
}
