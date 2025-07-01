package com.opinito.social.Model;

import java.util.List;

public class PopupGetInitialKWS {

    private String status;
    private List<data> data;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<PopupGetInitialKWS.data> getData() {
        return data;
    }

    public void setData(List<PopupGetInitialKWS.data> data) {
        this.data = data;
    }

    public class data {
        private String KEYWORDS;
        private String KEYID;
        private String ROW_ID;

        public String getPOSTID() {
            return POSTID;
        }

        public void setPOSTID(String POSTID) {
            this.POSTID = POSTID;
        }

        private String POSTID;
        private String CART = "";

        public String getKEYWORDS() {
            return KEYWORDS;
        }

        public void setKEYWORDS(String KEYWORDS) {
            this.KEYWORDS = KEYWORDS;
        }

        public String getKEYID() {
            return KEYID;
        }

        public void setKEYID(String KEYID) {
            this.KEYID = KEYID;
        }

        public String getROW_ID() {
            return ROW_ID;
        }

        public void setROW_ID(String ROW_ID) {
            this.ROW_ID = ROW_ID;
        }

        public String getCART() {
            return CART;
        }

        public void setCART(String CART) {
            this.CART = CART;
        }
    }
}
