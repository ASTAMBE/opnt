package com.opinito.social;

import com.opinito.social.Model.PostCellModel;
import com.opinito.social.Utils.EmbeddedContent;

public class PostModelClass {

    public static PostCellModel getPostCellModel(String postContent) {
        PostCellModel postModel = new PostCellModel();
        String title = null;
        if (postContent != null) {
            title = postContent.split("http")[0];
        }
        if (title != null)
            postModel.setPostTitle(title);
        String url = new EmbeddedContent().getUrlForPreview(postContent);
        if (url != null)
            postModel.setUrlForPreview(url);
        String remaningDescription = getRemainingDescription(postContent, url, title);
        if (remaningDescription != null)
            postModel.setRemainingDescription(remaningDescription);
        return postModel;
    }

    public static String getRemainingDescription(String postContent, String urlPreview, String postTitle) {
        String remainingDescription = "";
        if (postTitle != null) {
            if (postTitle.length() > 0 && urlPreview.length() > 0) {
                if (postTitle.length() == postContent.length()) {
                    remainingDescription = postContent.substring(postTitle.length());
                } else {
                    remainingDescription = postContent.substring(postTitle.length() + urlPreview.length());
                }
            } else if (postTitle.isEmpty() && urlPreview.length() > 0) {
                remainingDescription = postContent.substring(urlPreview.length());
            } else if (new EmbeddedContent().getEmbeddedContentList(postContent).isEmpty()) {
                remainingDescription = postContent;
            } else if (postTitle != null && postTitle != null && postTitle.length() > 0 && postTitle.length() > 0) {
                remainingDescription = postContent.substring(postTitle.length() + urlPreview.length());
            }
        }
        return remainingDescription;
    }

}
