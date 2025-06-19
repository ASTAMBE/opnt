package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by chanti on 7/11/2017.
 */

public class TopicCartsModel {
    @SerializedName("status")
    @Expose
    private String status;
    @SerializedName("data")
    @Expose
    private List<Data> data = null;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<Data> getData() {
        return data;
    }

    public void setData(List<Data> data) {
        this.data = data;
    }

    public class Data {

        @SerializedName("USERID")
        @Expose
        private String uSERID;
        @SerializedName("TOPICID")
        @Expose
        private String tOPICID;
        @SerializedName("CART")
        @Expose
        private String cART;
        @SerializedName("KEYID")
        @Expose
        private String kEYID;
        @SerializedName("KEYWORDS")
        @Expose
        private String kEYWORDS;
        @SerializedName("SRC")
        @Expose
        private String sRC;
        @SerializedName("SORTER")
        @Expose
        private String sORTER;
        @SerializedName("COUNTRY_CODE")
        @Expose
        private String cOUNTRYCODE;
        @SerializedName("HCNT")
        @Expose
        private String hCNT;
        @SerializedName("LCNT")
        @Expose
        private String lCNT;

        public String getUSERID() {
            return uSERID;
        }

        public void setUSERID(String uSERID) {
            this.uSERID = uSERID;
        }

        public String getTOPICID() {
            return tOPICID;
        }

        public void setTOPICID(String tOPICID) {
            this.tOPICID = tOPICID;
        }

        public String getCART() {
            return cART;
        }

        public void setCART(String cART) {
            this.cART = cART;
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

        public String getSRC() {
            return sRC;
        }

        public void setSRC(String sRC) {
            this.sRC = sRC;
        }

        public String getSORTER() {
            return sORTER;
        }

        public void setSORTER(String sORTER) {
            this.sORTER = sORTER;
        }

        public String getCOUNTRYCODE() {
            return cOUNTRYCODE;
        }

        public void setCOUNTRYCODE(String cOUNTRYCODE) {
            this.cOUNTRYCODE = cOUNTRYCODE;
        }

        public String getHCNT() {
            return hCNT;
        }

        public void setHCNT(String hCNT) {
            this.hCNT = hCNT;
        }

        public String getLCNT() {
            return lCNT;
        }

        public void setLCNT(String lCNT) {
            this.lCNT = lCNT;
        }
    }
}
