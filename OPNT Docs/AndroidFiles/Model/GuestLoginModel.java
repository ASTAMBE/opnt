package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class GuestLoginModel {

    @SerializedName("USERID")
    @Expose
    private String uSERID;
    @SerializedName("COUNTRY_CODE")
    @Expose
    private String cOUNTRYCODE;
    @SerializedName("USER_TYPE")
    @Expose
    private String uSERTYPE;
    @SerializedName("CARTORNOT")
    @Expose
    private String cARTORNOT;

    public String getUSERID() {
        return uSERID;
    }

    public void setUSERID(String uSERID) {
        this.uSERID = uSERID;
    }

    public String getCOUNTRYCODE() {
        return cOUNTRYCODE;
    }

    public void setCOUNTRYCODE(String cOUNTRYCODE) {
        this.cOUNTRYCODE = cOUNTRYCODE;
    }

    public String getUSERTYPE() {
        return uSERTYPE;
    }

    public void setUSERTYPE(String uSERTYPE) {
        this.uSERTYPE = uSERTYPE;
    }

    public String getCARTORNOT() {
        return cARTORNOT;
    }

    public void setCARTORNOT(String cARTORNOT) {
        this.cARTORNOT = cARTORNOT;
    }

}