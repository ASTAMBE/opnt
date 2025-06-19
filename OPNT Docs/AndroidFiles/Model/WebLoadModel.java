package com.opinito.social.Model;

import java.io.Serializable;

/**
 * Created by chanti on 9/30/2017.
 */

public class WebLoadModel implements Serializable {
    public String title = "";
    public String lead_image_url;
    public String url = "";
    public String excerpt = "";
    public long POST_ID =0;
    public String remaining_Description = "";

    public WebLoadModel(String title, String lead_image_url, String url, String excerpt, long POST_ID,String remainingDescription){
        this.title = title;
        this.lead_image_url = lead_image_url;
        this.url = url;
        this.excerpt = excerpt;
        this.POST_ID = POST_ID;
        this.remaining_Description = remainingDescription;
    }

    public String getRemaining_Description() {
        return remaining_Description;
    }

    public void setRemaining_Description(String remaining_Description) {
        this.remaining_Description = remaining_Description;
    }

    public long getPOST_ID() {
        return POST_ID;
    }

    public void setPOST_ID(long POST_ID) {
        this.POST_ID = POST_ID;
    }

    public String getExcerpt() {
        return excerpt;
    }

    public void setExcerpt(String excerpt) {
        this.excerpt = excerpt;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getLead_image_url() {
        return lead_image_url;
    }

    public void setLead_image_url(String lead_image_url) {
        this.lead_image_url = lead_image_url;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getTitle() {
        return title;
    }
}
