package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class SearchPostsModel {
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

        @SerializedName("POST_ID")
        @Expose
        private String pOSTID;
        @SerializedName("POST_BY_UID")
        @Expose
        private String pOSTBYUID;
        @SerializedName("POST_BY_UNAME")
        @Expose
        private String pOSTBYUNAME;
        @SerializedName("POST_DTM")
        @Expose
        private String pOSTDTM;
        @SerializedName("POST_CONTENT")
        @Expose
        private String pOSTCONTENT;

        public String getPOSTID() {
            return pOSTID;
        }

        public void setPOSTID(String pOSTID) {
            this.pOSTID = pOSTID;
        }

        public String getPOSTBYUID() {
            return pOSTBYUID;
        }

        public void setPOSTBYUID(String pOSTBYUID) {
            this.pOSTBYUID = pOSTBYUID;
        }

        public String getPOSTBYUNAME() {
            return pOSTBYUNAME;
        }

        public void setPOSTBYUNAME(String pOSTBYUNAME) {
            this.pOSTBYUNAME = pOSTBYUNAME;
        }

        public String getPOSTDTM() {
            return pOSTDTM;
        }

        public void setPOSTDTM(String pOSTDTM) {
            this.pOSTDTM = pOSTDTM;
        }

        public String getPOSTCONTENT() {
            return pOSTCONTENT;
        }

        public void setPOSTCONTENT(String pOSTCONTENT) {
            this.pOSTCONTENT = pOSTCONTENT;
        }

    }
}
