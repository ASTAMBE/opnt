package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class MultiSearchTopicModel {

    @SerializedName("TNAME")
    @Expose
    private String tNAME;
    @SerializedName("TOPICID")
    @Expose
    private String tOPICID;
    @SerializedName("KEYID")
    @Expose
    private String kEYID;
    @SerializedName("KEYWORDS")
    @Expose
    private String kEYWORDS;
    @SerializedName("QSRC")
    @Expose
    private String qSRC;
    @SerializedName("HCOUNT")
    @Expose
    private String hCOUNT;
    @SerializedName("LCOUNT")
    @Expose
    private String lCOUNT;
    @SerializedName("TCOUNT")
    @Expose
    private String tCOUNT;
    private String CART = "";

    public String getCART() {
        return CART;
    }

    public void setCART(String CART) {
        this.CART = CART;
    }

    public String getTNAME() {
        return tNAME;
    }

    public void setTNAME(String tNAME) {
        this.tNAME = tNAME;
    }

    public String getTOPICID() {
        return tOPICID;
    }

    public void setTOPICID(String tOPICID) {
        this.tOPICID = tOPICID;
    }

    public String getKEYID() {
        return kEYID;
    }

    public void setKEYID(String kEYID) {
        this.kEYID = kEYID;
    }

    public String getKEYWORDS() {
        return kEYWORDS;
    }

    public void setKEYWORDS(String kEYWORDS) {
        this.kEYWORDS = kEYWORDS;
    }

    public String getQSRC() {
        return qSRC;
    }

    public void setQSRC(String qSRC) {
        this.qSRC = qSRC;
    }

    public String getHCOUNT() {
        return hCOUNT;
    }

    public void setHCOUNT(String hCOUNT) {
        this.hCOUNT = hCOUNT;
    }

    public String getLCOUNT() {
        return lCOUNT;
    }

    public void setLCOUNT(String lCOUNT) {
        this.lCOUNT = lCOUNT;
    }

    public MultiSearchTopicModel(String tNAME, String tOPICID, String kEYID, String kEYWORDS, String qSRC, String hCOUNT, String lCOUNT, String tCOUNT, String CART) {
        this.tNAME = tNAME;
        this.tOPICID = tOPICID;
        this.kEYID = kEYID;
        this.kEYWORDS = kEYWORDS;
        this.qSRC = qSRC;
        this.hCOUNT = hCOUNT;
        this.lCOUNT = lCOUNT;
        this.tCOUNT = tCOUNT;
        this.CART = CART;
    }

    public String getTCOUNT() {
        return tCOUNT;
    }

    public void setTCOUNT(String tCOUNT) {
        this.tCOUNT = tCOUNT;
    }

}