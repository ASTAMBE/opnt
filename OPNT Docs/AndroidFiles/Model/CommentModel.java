package com.opinito.social.Model;

import java.io.Serializable;
import java.util.List;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

/**
 * Created by Ashish on 30/4/2020.
 */

public class CommentModel implements Serializable{
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
    public class Data implements Serializable {

        @SerializedName("TOPICID")
        @Expose
        private String tOPICID;
        @SerializedName("CAUSE_POST_ID")
        @Expose
        private String cAUSEPOSTID;
        @SerializedName("COMMENT_ID")
        @Expose
        private String cOMMENTID;
        @SerializedName("COMMENT_BY_USERID")
        @Expose
        private String cOMMENTBYUSERID;
        @SerializedName("COMMENT_BY_UNAME")
        @Expose
        private String cOMMENTBYUNAME;
        @SerializedName("DP_URL")
        @Expose
        private Object dPURL;
        @SerializedName("COMMENT_CONTENT")
        @Expose
        private String cOMMENTCONTENT;
        @SerializedName("COMMENT_DTM")
        @Expose
        private String cOMMENTDTM;
        @SerializedName("EMBEDDED_CONTENT")
        @Expose
        private String eMBEDDEDCONTENT;
        @SerializedName("EMBEDDED_FLAG")
        @Expose
        private String eMBEDDEDFLAG;
        @SerializedName("PARENT_COMMENT_ID")
        @Expose
        private String pARENTCOMMENTID;
        @SerializedName("PARENT_COMMENT_UNAME")
        @Expose
        private String pARENTCOMMENTUNAME;
        @SerializedName("PARENT_COMMENT_DTM")
        @Expose
        private String pARENTCOMMENTDTM;
        @SerializedName("PARENT_COMMENT_CONTENT")
        @Expose
        private String pARENTCOMMENTCONTENT;
        @SerializedName("PARENT_MEDIA_CONTENT")
        @Expose
        private String pARENTMEDIACONTENT;
        @SerializedName("PARENT_COMMENT_BYUID")
        @Expose
        private String pARENTCOMMENTBYUID;
        @SerializedName("COMMENT_TYPE")
        @Expose
        private String cOMMENTTYPE;
        @SerializedName("MEDIA_CONTENT")
        @Expose
        private String mEDIACONTENT;
        @SerializedName("MEDIA_FLAG")
        @Expose
        private String mEDIAFLAG;

        public String getTOPICID() {
            return tOPICID;
        }

        public void setTOPICID(String tOPICID) {
            this.tOPICID = tOPICID;
        }

        public String getCAUSEPOSTID() {
            return cAUSEPOSTID;
        }

        public void setCAUSEPOSTID(String cAUSEPOSTID) {
            this.cAUSEPOSTID = cAUSEPOSTID;
        }

        public String getCOMMENTID() {
            return cOMMENTID;
        }

        public void setCOMMENTID(String cOMMENTID) {
            this.cOMMENTID = cOMMENTID;
        }

        public String getCOMMENTBYUSERID() {
            return cOMMENTBYUSERID;
        }

        public void setCOMMENTBYUSERID(String cOMMENTBYUSERID) {
            this.cOMMENTBYUSERID = cOMMENTBYUSERID;
        }

        public String getCOMMENTBYUNAME() {
            return cOMMENTBYUNAME;
        }

        public void setCOMMENTBYUNAME(String cOMMENTBYUNAME) {
            this.cOMMENTBYUNAME = cOMMENTBYUNAME;
        }

        public Object getDPURL() {
            return dPURL;
        }

        public void setDPURL(Object dPURL) {
            this.dPURL = dPURL;
        }

        public String getCOMMENTCONTENT() {
            return cOMMENTCONTENT;
        }

        public void setCOMMENTCONTENT(String cOMMENTCONTENT) {
            this.cOMMENTCONTENT = cOMMENTCONTENT;
        }

        public String getCOMMENTDTM() {
            return cOMMENTDTM;
        }

        public void setCOMMENTDTM(String cOMMENTDTM) {
            this.cOMMENTDTM = cOMMENTDTM;
        }

        public String getEMBEDDEDCONTENT() {
            return eMBEDDEDCONTENT;
        }

        public void setEMBEDDEDCONTENT(String eMBEDDEDCONTENT) {
            this.eMBEDDEDCONTENT = eMBEDDEDCONTENT;
        }

        public String getEMBEDDEDFLAG() {
            return eMBEDDEDFLAG;
        }

        public void setEMBEDDEDFLAG(String eMBEDDEDFLAG) {
            this.eMBEDDEDFLAG = eMBEDDEDFLAG;
        }

        public String getPARENTCOMMENTID() {
            return pARENTCOMMENTID;
        }

        public void setPARENTCOMMENTID(String pARENTCOMMENTID) {
            this.pARENTCOMMENTID = pARENTCOMMENTID;
        }

        public String getPARENTCOMMENTUNAME() {
            return pARENTCOMMENTUNAME;
        }

        public void setPARENTCOMMENTUNAME(String pARENTCOMMENTUNAME) {
            this.pARENTCOMMENTUNAME = pARENTCOMMENTUNAME;
        }

        public String getPARENTCOMMENTDTM() {
            return pARENTCOMMENTDTM;
        }

        public void setPARENTCOMMENTDTM(String pARENTCOMMENTDTM) {
            this.pARENTCOMMENTDTM = pARENTCOMMENTDTM;
        }

        public String getPARENTCOMMENTCONTENT() {
            return pARENTCOMMENTCONTENT;
        }

        public void setPARENTCOMMENTCONTENT(String pARENTCOMMENTCONTENT) {
            this.pARENTCOMMENTCONTENT = pARENTCOMMENTCONTENT;
        }

        public String getPARENTMEDIACONTENT() {
            return pARENTMEDIACONTENT;
        }

        public void setPARENTMEDIACONTENT(String pARENTMEDIACONTENT) {
            this.pARENTMEDIACONTENT = pARENTMEDIACONTENT;
        }

        public String getPARENTCOMMENTBYUID() {
            return pARENTCOMMENTBYUID;
        }

        public void setPARENTCOMMENTBYUID(String pARENTCOMMENTBYUID) {
            this.pARENTCOMMENTBYUID = pARENTCOMMENTBYUID;
        }

        public String getCOMMENTTYPE() {
            return cOMMENTTYPE;
        }

        public void setCOMMENTTYPE(String cOMMENTTYPE) {
            this.cOMMENTTYPE = cOMMENTTYPE;
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

    }
}
