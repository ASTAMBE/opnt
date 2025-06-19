package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class AllNWCountModel {

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

        @SerializedName("ANTI_POST_COUNT")
        @Expose
        private String antiPostCount;
        @SerializedName("NW_POST_COUNT")
        @Expose
        private String nwPostCount;

        public String getAntiPOSTCOUNT() {
            return antiPostCount;
        }

        public void setAntiPostCount(String antiPostCount) {
            this.antiPostCount = antiPostCount;
        }

        public String getNWPOSTCOUNT() {
            return nwPostCount;
        }

        public void setNWPOSTCOUNT(String nWPOSTCOUNT) {
            this.nwPostCount = nWPOSTCOUNT;
        }

    }

}
