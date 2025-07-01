package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class LoveHatePostCountModel {

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

        @SerializedName("USERNAME")
        @Expose
        private String uSERNAME;
        @SerializedName("POST_ACTION_DTM")
        @Expose
        private String pOSTACTIONDTM;
        @SerializedName("DP_URL")
        @Expose
        private Object dPURL;
        @SerializedName("CHF")
        @Expose
        private String CHF;

        public String getUSERNAME() {
            return uSERNAME;
        }

        public void setUSERNAME(String uSERNAME) {
            this.uSERNAME = uSERNAME;
        }

        public String getPOSTACTIONDTM() {
            return pOSTACTIONDTM;
        }

        public void setPOSTACTIONDTM(String pOSTACTIONDTM) {
            this.pOSTACTIONDTM = pOSTACTIONDTM;
        }

        public Object getdPURL() {
            return dPURL;
        }

        public void setdPURL(Object dPURL) {
            this.dPURL = dPURL;
        }

        public String getCHF() {
            return CHF;
        }

        public void setCHF(String CHF) {
            this.CHF = CHF;
        }
    }
}
