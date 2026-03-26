package com.opinito.social.Model;

public class GoogleSigninRequest {

    public String USERID = "";
    public String USERNAME = "";
    public String COUNTRY_CODE = "";
    public String token = "";
    public Boolean SELECTED = false;

    public GoogleSigninRequest(String USERID,String USERNAME,String COUNTRY_CODE, String token, Boolean SELECTED){
        this.USERID = USERID;
        this.USERNAME = USERNAME;
        this.COUNTRY_CODE = COUNTRY_CODE;
        this.token = token;
        this.SELECTED = SELECTED;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Boolean getSELECTED() {
        return SELECTED;
    }

    public void setSELECTED(Boolean SELECTED) {
        this.SELECTED = SELECTED;
    }

    public String getUSERID() {
        return USERID;
    }

    public void setUSERID(String USERID) {
        this.USERID = USERID;
    }

    public String getCOUNTRY_CODE() {
        return COUNTRY_CODE;
    }

    public void setCOUNTRY_CODE(String COUNTRY_CODE) {
        this.COUNTRY_CODE = COUNTRY_CODE;
    }

    public String getUSERNAME() {
        return USERNAME;
    }

    public void setUSERNAME(String USERNAME) {
        this.USERNAME = USERNAME;
    }
}
