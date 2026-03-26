package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class ConvertGuestUserModel {

    @SerializedName("message")
    @Expose
    private String message;
    @SerializedName("data")
    @Expose
    private Data data;
    public Boolean SELECTED = false;

    public Boolean getSELECTED() {
        return SELECTED;
    }

    public void setSELECTED(Boolean SELECTED) {
        this.SELECTED = SELECTED;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    public class Data {

        @SerializedName("USERNAME")
        @Expose
        private String uSERNAME;
        @SerializedName("USERID")
        @Expose
        private String uSERID;
        @SerializedName("USER_UUID")
        @Expose
        private String uSERUUID;
        @SerializedName("USER_TYPE")
        @Expose
        private String uSERTYPE;
        @SerializedName("COUNTRY_CODE")
        @Expose
        private String cOUNTRYCODE;

        public String getUSERNAME() {
            return uSERNAME;
        }

        public void setUSERNAME(String uSERNAME) {
            this.uSERNAME = uSERNAME;
        }

        public String getUSERID() {
            return uSERID;
        }

        public void setUSERID(String uSERID) {
            this.uSERID = uSERID;
        }

        public String getUSERUUID() {
            return uSERUUID;
        }

        public void setUSERUUID(String uSERUUID) {
            this.uSERUUID = uSERUUID;
        }

        public String getUSERTYPE() {
            return uSERTYPE;
        }

        public void setUSERTYPE(String uSERTYPE) {
            this.uSERTYPE = uSERTYPE;
        }

        public String getCOUNTRYCODE() {
            return cOUNTRYCODE;
        }

        public void setCOUNTRYCODE(String cOUNTRYCODE) {
            this.cOUNTRYCODE = cOUNTRYCODE;
        }

    }
}
