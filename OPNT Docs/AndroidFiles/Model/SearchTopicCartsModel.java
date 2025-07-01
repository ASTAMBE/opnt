package com.opinito.social.Model;

public class SearchTopicCartsModel {
    private int KEYID = 0;
    private String KEYWORDS = "";
    private String QSRC = "";
    private String HCOUNT = "";
    private String LCOUNT = "";
    private String TCOUNT = "";
    private String CART = "";

    public SearchTopicCartsModel(int KEYID, String KEYWORDS, String QSRC, String HCOUNT, String LCOUNT, String TCOUNT) {
        this.KEYID = KEYID;
        this.KEYWORDS = KEYWORDS;
        this.QSRC = QSRC;
        this.HCOUNT = HCOUNT;
        this.LCOUNT = LCOUNT;
        this.TCOUNT = TCOUNT;

    }

    public int getKEYID() {
        return KEYID;
    }

    public void setKEYID(int KEYID) {
        this.KEYID = KEYID;
    }

    public String getKEYWORDS() {
        return KEYWORDS;
    }

    public void setKEYWORDS(String KEYWORDS) {
        this.KEYWORDS = KEYWORDS;
    }

    public String getQSRC() {
        return QSRC;
    }

    public void setQSRC(String QSRC) {
        this.QSRC = QSRC;
    }

    public String getHCOUNT() {
        return HCOUNT;
    }

    public void setHCOUNT(String HCOUNT) {
        this.HCOUNT = HCOUNT;
    }

    public String getLCOUNT() {
        return LCOUNT;
    }

    public void setLCOUNT(String LCOUNT) {
        this.LCOUNT = LCOUNT;
    }

    public String getTCOUNT() {
        return TCOUNT;
    }

    public void setTCOUNT(String TCOUNT) {
        this.TCOUNT = TCOUNT;
    }

    public String getCART() {
        return CART;
    }

    public void setCART(String CART) {
        this.CART = CART;
    }
}
