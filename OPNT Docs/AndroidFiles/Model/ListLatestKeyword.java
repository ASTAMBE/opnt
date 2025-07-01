
package com.opinito.social.Model;

import com.google.gson.annotations.SerializedName;


/**
 * Created by Abhay on 11/June/2021.
 */
@SuppressWarnings("unused")
public class ListLatestKeyword {

    @SerializedName("CART")
    private String mCART;
    @SerializedName("DATE")
    private String mDATE;
    @SerializedName("KEYWORDS")
    private String mKEYWORDS;
    @SerializedName("KEYID")
    private String mTAG1KEYID;
    @SerializedName("TOPIC")
    private String mTOPIC;

    public ListLatestKeyword(String mCART, String mDATE, String mKEYWORDS, String mTAG1KEYID, String mTOPIC, String mTOPICID) {
        this.mCART = mCART;
        this.mDATE = mDATE;
        this.mKEYWORDS = mKEYWORDS;
        this.mTAG1KEYID = mTAG1KEYID;
        this.mTOPIC = mTOPIC;
        this.mTOPICID = mTOPICID;
    }

    @SerializedName("TOPICID")
    private String mTOPICID;

    public String getCART() {
        return mCART;
    }

    public void setCART(String cART) {
        mCART = cART;
    }

    public String getDATE() {
        return mDATE;
    }

    public void setDATE(String dATE) {
        mDATE = dATE;
    }

    public String getKEYWORDS() {
        return mKEYWORDS;
    }

    public void setKEYWORDS(String kEYWORDS) {
        mKEYWORDS = kEYWORDS;
    }

    public String getTAG1KEYID() {
        return mTAG1KEYID;
    }

    public void setTAG1KEYID(String tAG1KEYID) {
        mTAG1KEYID = tAG1KEYID;
    }

    public String getTOPIC() {
        return mTOPIC;
    }

    public void setTOPIC(String tOPIC) {
        mTOPIC = tOPIC;
    }

    public String getTOPICID() {
        return mTOPICID;
    }

    public void setTOPICID(String tOPICID) {
        mTOPICID = tOPICID;
    }

}
