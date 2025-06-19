package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class CommentCountModel {
    @SerializedName("status")
    @Expose
    private String status;
    @SerializedName("data")
    @Expose
    private Data data;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    public class Data {

        @SerializedName("countALL")
        @Expose
        private String countALL;
        @SerializedName("countNW")
        @Expose
        private String countNW;
        @SerializedName("countANTI")
        @Expose
        private String countANTI;

        public String getCountALL() {
            return countALL;
        }

        public void setCountALL(String countALL) {
            this.countALL = countALL;
        }

        public String getCountNW() {
            return countNW;
        }

        public void setCountNW(String countNW) {
            this.countNW = countNW;
        }

        public String getCountANTI() {
            return countANTI;
        }

        public void setCountANTI(String countANTI) {
            this.countANTI = countANTI;
        }
    }
}
