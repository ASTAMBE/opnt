package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class ProfileInterestsModel {
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

        @SerializedName("TOPICID")
        @Expose
        private String tOPICID;
        @SerializedName("TOPIC")
        @Expose
        private String tOPIC;
        @SerializedName("CODE")
        @Expose
        private String cODE;
        @SerializedName("SLCT")
        @Expose
        private String sLCT;

        public String getTOPICID() {
            return tOPICID;
        }

        public void setTOPICID(String tOPICID) {
            this.tOPICID = tOPICID;
        }

        public String getTOPIC() {
            return tOPIC;
        }

        public void setTOPIC(String tOPIC) {
            this.tOPIC = tOPIC;
        }

        public String getCODE() {
            return cODE;
        }

        public void setCODE(String cODE) {
            this.cODE = cODE;
        }

        public String getSLCT() {
            return sLCT;
        }

        public void setSLCT(String sLCT) {
            this.sLCT = sLCT;
        }

    }
}
