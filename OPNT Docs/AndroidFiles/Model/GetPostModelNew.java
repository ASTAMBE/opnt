package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class GetPostModelNew {

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
        @SerializedName("TOPICID")
        @Expose
        private String tOPICID;
        @SerializedName("POST_DATETIME")
        @Expose
        private String pOSTDATETIME;
        @SerializedName("POST_BY_USERID")
        @Expose
        private String pOSTBYUSERID;
        @SerializedName("USERNAME")
        @Expose
        private String uSERNAME;
        @SerializedName("POST_CONTENT")
        @Expose
        private String pOSTCONTENT;
        @SerializedName("MEDIA_CONTENT")
        @Expose
        private String mEDIACONTENT;
        @SerializedName("MEDIA_FLAG")
        @Expose
        private String mEDIAFLAG;
        @SerializedName("DP_URL")
        @Expose
        private Object dPURL;
        @SerializedName("TOTAL_NS")
        @Expose
        private String tOTALNS;
        @SerializedName("LCOUNT")
        @Expose
        private String lCOUNT;
        @SerializedName("HCOUNT")
        @Expose
        private String hCOUNT;
        @SerializedName("POST_ACTION_TYPE")
        @Expose
        private Object pOSTACTIONTYPE;
        @SerializedName("UU_ACTION")
        @Expose
        private String uUACTION;
        @SerializedName("POST_COMMENT_COUNT")
        @Expose
        private String pOSTCOMMENTCOUNT;
        @SerializedName("BOOKMARK_FLAG")
        @Expose
        private String bookmark;

        public String getBookmark() {
            return bookmark;
        }

        public void setBookmark(String bookmark) {
            this.bookmark = bookmark;
        }

        public String getPOSTID() {
            return pOSTID;
        }

        public void setPOSTID(String pOSTID) {
            this.pOSTID = pOSTID;
        }

        public String getTOPICID() {
            return tOPICID;
        }

        public void setTOPICID(String tOPICID) {
            this.tOPICID = tOPICID;
        }

        public String getPOSTDATETIME() {
            return pOSTDATETIME;
        }

        public void setPOSTDATETIME(String pOSTDATETIME) {
            this.pOSTDATETIME = pOSTDATETIME;
        }

        public String getPOSTBYUSERID() {
            return pOSTBYUSERID;
        }

        public void setPOSTBYUSERID(String pOSTBYUSERID) {
            this.pOSTBYUSERID = pOSTBYUSERID;
        }

        public String getUSERNAME() {
            return uSERNAME;
        }

        public void setUSERNAME(String uSERNAME) {
            this.uSERNAME = uSERNAME;
        }

        public String getPOSTCONTENT() {
            return pOSTCONTENT;
        }

        public void setPOSTCONTENT(String pOSTCONTENT) {
            this.pOSTCONTENT = pOSTCONTENT;
        }

        public String getMEDIACONTENT() {
            return mEDIACONTENT;
        }

        public void setMEDIACONTENT(String mEDIACONTENT) {
            this.mEDIACONTENT = mEDIACONTENT;
        }

        public String getMEDIAFLAG() {
            return mEDIAFLAG;
        }

        public void setMEDIAFLAG(String mEDIAFLAG) {
            this.mEDIAFLAG = mEDIAFLAG;
        }

        public Object getDPURL() {
            return dPURL;
        }

        public void setDPURL(Object dPURL) {
            this.dPURL = dPURL;
        }

        public String getTOTALNS() {
            return tOTALNS;
        }

        public void setTOTALNS(String tOTALNS) {
            this.tOTALNS = tOTALNS;
        }

        public String getLCOUNT() {
            return lCOUNT;
        }

        public void setLCOUNT(String lCOUNT) {
            this.lCOUNT = lCOUNT;
        }

        public String getHCOUNT() {
            return hCOUNT;
        }

        public void setHCOUNT(String hCOUNT) {
            this.hCOUNT = hCOUNT;
        }

        public Object getPOSTACTIONTYPE() {
            return pOSTACTIONTYPE;
        }

        public void setPOSTACTIONTYPE(Object pOSTACTIONTYPE) {
            this.pOSTACTIONTYPE = pOSTACTIONTYPE;
        }

        public String getUUACTION() {
            return uUACTION;
        }

        public void setUUACTION(String uUACTION) {
            this.uUACTION = uUACTION;
        }

        public String getPOSTCOMMENTCOUNT() {
            return pOSTCOMMENTCOUNT;
        }

        public void setPOSTCOMMENTCOUNT(String pOSTCOMMENTCOUNT) {
            this.pOSTCOMMENTCOUNT = pOSTCOMMENTCOUNT;
        }
    }
}
