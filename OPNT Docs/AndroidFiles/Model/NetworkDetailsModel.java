package com.opinito.social.Model;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class NetworkDetailsModel {
    public String TOPIC = "";
    public String CART = "";
    public String KEYWORDS = "";
    public String MATCH_PERCENT = "";
    public String MDTM = "";
    public String CHF = "";

    public NetworkDetailsModel(String TOPIC, String CART, String KEYWORDS, String MATCH_PERCENT, String MDTM, String CHF) {
        this.TOPIC = TOPIC;
        this.CART = CART;
        this.KEYWORDS = KEYWORDS;
        this.MATCH_PERCENT = MATCH_PERCENT;
        this.MDTM = MDTM;
        this.CHF = CHF;
    }

    public String getKEYWORDS() {
        return KEYWORDS;
    }

    public void setKEYWORDS(String KEYWORDS) {
        this.KEYWORDS = KEYWORDS;
    }

    public String getTOPIC() {
        return TOPIC;
    }

    public void setTOPIC(String TOPIC) {
        this.TOPIC = TOPIC;
    }

    public String getCART() {
        return CART;
    }

    public void setCART(String CART) {
        this.CART = CART;
    }


    public String getMATCH_PERCENT() {
        return MATCH_PERCENT;
    }

    public void setMATCH_PERCENT(String MATCH_PERCENT) {
        this.MATCH_PERCENT = MATCH_PERCENT;
    }

    public String getMDTM() {
        return MDTM;
    }

    public void setMDTM(String MDTM) {
        this.MDTM = MDTM;
    }

    public String getCHF() {
        return CHF;
    }

    public void setCHF(String CHF) {
        this.CHF = CHF;
    }
}
