package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/**
 * Created by bhaskar on 4/19/18.
 */


public class GuestLoginResponse {

    @SerializedName("USERNAME")
    @Expose
    private String uSERNAME;
    @SerializedName("USER_UUID")
    @Expose
    private String uSERUUID;

    public String getUSERNAME() {
        return uSERNAME;
    }

    public void setUSERNAME(String uSERNAME) {
        this.uSERNAME = uSERNAME;
    }

    public String getUSERUUID() {
        return uSERUUID;
    }

    public void setUSERUUID(String uSERUUID) {
        this.uSERUUID = uSERUUID;
    }
}

