package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by 502687702 on 7/12/2017.
 */

public class ProfileModel {

    @SerializedName("status")
    @Expose
    private String status;

    @SerializedName("data")
    @Expose
    private List<Data> data;

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
        @SerializedName("PC_DELTA")
        @Expose
        private String pCDELTA;
        @SerializedName("NETSIZE")
        @Expose
        private String nETSIZE;
        @SerializedName("POST_COUNT")
        @Expose
        private String pOSTCOUNT;
        @SerializedName("COMMENT_COUNT")
        @Expose
        private String commentCount;
        @SerializedName("CHF")
        @Expose
        private String chatEnabledFlag;

        public String getBookmarkCount() {
            return BookmarkCount;
        }

        public void setBookmarkCount(String bookmarkCount) {
            BookmarkCount = bookmarkCount;
        }

        @SerializedName("BKMK_COUNT")
        @Expose
        private String BookmarkCount;


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

        public String getPCDELTA() {
            return pCDELTA;
        }

        public void setPCDELTA(String pCDELTA) {
            this.pCDELTA = pCDELTA;
        }

        public String getNETSIZE() {
            return nETSIZE;
        }

        public void setNETSIZE(String nETSIZE) {
            this.nETSIZE = nETSIZE;
        }

        public String getPOSTCOUNT() {
            return pOSTCOUNT;
        }

        public void setPOSTCOUNT(String pOSTCOUNT) {
            this.pOSTCOUNT = pOSTCOUNT;
        }

        public String getCommentCount() {
            return commentCount;
        }

        public void setCommentCount(String commentCount) {
            this.commentCount = commentCount;
        }

        public String getChatEnabledFlag() {
            return chatEnabledFlag;
        }

        public void setChatEnabledFlag(String chatEnabledFlag) {
            this.chatEnabledFlag = chatEnabledFlag;
        }
    }
}