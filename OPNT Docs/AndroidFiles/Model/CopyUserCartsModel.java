package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class CopyUserCartsModel {

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

        @SerializedName("uuidTo")
        @Expose
        private String uuidTo;
        @SerializedName("TIDTO")
        @Expose
        private String tIDTO;
        @SerializedName("postID")
        @Expose
        private String postID;

        public String getUuidTo() {
            return uuidTo;
        }

        public void setUuidTo(String uuidTo) {
            this.uuidTo = uuidTo;
        }

        public String getTIDTO() {
            return tIDTO;
        }

        public void setTIDTO(String tIDTO) {
            this.tIDTO = tIDTO;
        }

        public String getPostID() {
            return postID;
        }

        public void setPostID(String postID) {
            this.postID = postID;
        }

    }

}
