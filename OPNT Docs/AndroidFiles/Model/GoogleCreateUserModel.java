package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class GoogleCreateUserModel
{

    @SerializedName("status")
    @Expose
    private String status;
    @SerializedName("token")
    @Expose
    private String token;
    @SerializedName("data")
    @Expose
    private List<Datum> data = null;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public List<Datum> getData() {
        return data;
    }

    public void setData(List<Datum> data) {
        this.data = data;
    }

    public class Datum {

        @SerializedName("USERID")
        @Expose
        private String uSERID;
        @SerializedName("USERNAME")
        @Expose
        private String uSERNAME;
        @SerializedName("COUNTRY_CODE")
        @Expose
        private String cOUNTRYCODE;

        public String getUSERID() {
            return uSERID;
        }

        public void setUSERID(String uSERID) {
            this.uSERID = uSERID;
        }

        public String getUSERNAME() {
            return uSERNAME;
        }

        public void setUSERNAME(String uSERNAME) {
            this.uSERNAME = uSERNAME;
        }

        public String getCOUNTRYCODE() {
            return cOUNTRYCODE;
        }

        public void setCOUNTRYCODE(String cOUNTRYCODE) {
            this.cOUNTRYCODE = cOUNTRYCODE;
        }

    }

}