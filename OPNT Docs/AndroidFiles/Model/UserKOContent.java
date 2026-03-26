package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class UserKOContent {

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

        @SerializedName("ID")
        @Expose
        private String iD;
        @SerializedName("DTM")
        @Expose
        private String dTM;
        @SerializedName("CONTENT")
        @Expose
        private String cONTENT;
        @SerializedName("CTYPE")
        @Expose
        private String cTYPE;

        public String getID() {
            return iD;
        }

        public void setID(String iD) {
            this.iD = iD;
        }

        public String getDTM() {
            return dTM;
        }

        public void setDTM(String dTM) {
            this.dTM = dTM;
        }

        public String getCONTENT() {
            return cONTENT;
        }

        public void setCONTENT(String cONTENT) {
            this.cONTENT = cONTENT;
        }

        public String getCTYPE() {
            return cTYPE;
        }

        public void setCTYPE(String cTYPE) {
            this.cTYPE = cTYPE;
        }

    }
}
