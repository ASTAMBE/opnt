package com.opinito.social.Model;

import java.io.Serializable;

/**
 * Created by bhaskar on 12/16/17.
 */

public class PostCellModel implements Serializable {
    private String postTitle;
    private String urlForPreview;
    private String remainingDescription;

    private String sharePostPreviewImageURL = "";

    public String getPostMainTitle() {
        return postMainTitle;
    }

    public void setPostMainTitle(String postMainTitle) {
        this.postMainTitle = postMainTitle;
    }

    private String postMainTitle = "";

    public String getPostTitle() {
        return postTitle;
    }

    public void setPostTitle(String postTitle) {
        this.postTitle = postTitle;
    }

    public String getUrlForPreview() {
        return urlForPreview;
    }

    public void setUrlForPreview(String urlForPreview) {
        this.urlForPreview = urlForPreview;
    }

    public String getSharePostPreviewImageURL() {
        return sharePostPreviewImageURL;
    }

    public void setSharePostPreviewImageURL(String sharePostPreviewImageURL) {
        this.sharePostPreviewImageURL = sharePostPreviewImageURL;
    }

    public String getRemainingDescription() {
        return remainingDescription;
    }

    public void setRemainingDescription(String remainingDescription) {
        this.remainingDescription = remainingDescription;
    }
}
