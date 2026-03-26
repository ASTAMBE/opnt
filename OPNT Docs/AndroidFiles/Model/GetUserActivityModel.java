package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;

public class GetUserActivityModel {

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

        @SerializedName("username")
        @Expose
        private String username;
        @SerializedName("pcount_7day")
        @Expose
        private String pcount7day;
        @SerializedName("pcount_year")
        @Expose
        private String pcountYear;
        @SerializedName("ccount_7day")
        @Expose
        private String ccount7day;
        @SerializedName("ccount_year")
        @Expose
        private String ccountYear;
        @SerializedName("ko_count")
        @Expose
        private String koCount;
        @SerializedName("reported_count7")
        @Expose
        private String reportedCount7;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPcount7day() {
            return pcount7day;
        }

        public void setPcount7day(String pcount7day) {
            this.pcount7day = pcount7day;
        }

        public String getPcountYear() {
            return pcountYear;
        }

        public void setPcountYear(String pcountYear) {
            this.pcountYear = pcountYear;
        }

        public String getCcount7day() {
            return ccount7day;
        }

        public void setCcount7day(String ccount7day) {
            this.ccount7day = ccount7day;
        }

        public String getCcountYear() {
            return ccountYear;
        }

        public void setCcountYear(String ccountYear) {
            this.ccountYear = ccountYear;
        }

        public String getKoCount() {
            return koCount;
        }

        public void setKoCount(String koCount) {
            this.koCount = koCount;
        }

        public String getReportedCount7() {
            return reportedCount7;
        }

        public void setReportedCount7(String reportedCount7) {
            this.reportedCount7 = reportedCount7;
        }

    }
}
