package com.opinito.social.Model;

import java.io.Serializable;

/**
 * Created by 502687702 on 7/6/2017.
 */

public class PostDetailsModel implements Serializable {
    private long POST_ID = 0;
    private int TOPICID = 0;
    private String POST_DATETIME = "";
    private String POST_BY_USERID = "";
    private String USERNAME = "";
    private Object MEDIA_CONTENT = null;
    private Object MEDIA_FLAG = null;
    private String DP_URL = "";
    private String TOTAL_NS = "";
    private String LCOUNT = "";
    private String HCOUNT = "";
    private String POST_ACTION_TYPE = "";
    private String UU_ACTION = "";
    private String POST_COMMENT_COUNT = "";
    private String POST_CONTENT = "";
    private PostCellModel postCellModel;
    private PreviewModel previewModel;

    public String getBOOKMARK_FLAG() {
        return BOOKMARK_FLAG;
    }

    public void setBOOKMARK_FLAG(String BOOKMARK_FLAG) {
        this.BOOKMARK_FLAG = BOOKMARK_FLAG;
    }

    private String BOOKMARK_FLAG = "";

    public PostDetailsModel(long POST_ID, int TOPICID, String POST_DATETIME, String POST_BY_USERID, String USERNAME,
                            Object MEDIA_CONTENT, Object MEDIA_FLAG, String DP_URL,
                            String TOTAL_NS, String LCOUNT, String HCOUNT, String POST_ACTION_TYPE, String UU_ACTION,
                            String POST_COMMENT_COUNT, String POST_CONTENT, String BOOKMARK_FLAG, PostCellModel postCellModel){
        this.POST_ID = POST_ID;
        this.TOPICID = TOPICID;
        this.POST_DATETIME = POST_DATETIME;
        this.POST_BY_USERID = POST_BY_USERID;
        this.USERNAME = USERNAME;
        this.MEDIA_CONTENT = MEDIA_CONTENT;
        this.MEDIA_FLAG = MEDIA_FLAG;
        this.DP_URL = DP_URL;
        this.TOTAL_NS = TOTAL_NS;
        this.LCOUNT = LCOUNT;
        this.HCOUNT = HCOUNT;
        this.POST_ACTION_TYPE = POST_ACTION_TYPE;
        this.UU_ACTION = UU_ACTION;
        this.POST_COMMENT_COUNT = POST_COMMENT_COUNT;
        this.POST_CONTENT =POST_CONTENT;
        this.BOOKMARK_FLAG = BOOKMARK_FLAG;
        this.postCellModel = postCellModel;
    }

    public String getDP_URL() {
        return DP_URL;
    }

    public void setDP_URL(String DP_URL) {
        this.DP_URL = DP_URL;
    }

    public PreviewModel getPreviewModel() {
        return previewModel;
    }

    public void setPreviewModel(PreviewModel previewModel) {
        this.previewModel = previewModel;
    }

    public String getPOST_CONTENT() {
        return POST_CONTENT;
    }

    public void setPOST_CONTENT(String POST_CONTENT) {
        this.POST_CONTENT = POST_CONTENT;
    }

    public String getPOST_COMMENT_COUNT() {
        return POST_COMMENT_COUNT;
    }

    public void setPOST_COMMENT_COUNT(String POST_COMMENT_COUNT) {
        this.POST_COMMENT_COUNT = POST_COMMENT_COUNT;
    }

    public String getUU_ACTION() {
        return UU_ACTION;
    }

    public void setUU_ACTION(String UU_ACTION) {
        this.UU_ACTION = UU_ACTION;
    }

    public String getPOST_ACTION_TYPE() {
        return POST_ACTION_TYPE;
    }

    public void setPOST_ACTION_TYPE(String POST_ACTION_TYPE) {
        this.POST_ACTION_TYPE = POST_ACTION_TYPE;
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

    public String getTOTAL_NS() {
        return TOTAL_NS;
    }

    public void setTOTAL_NS(String TOTAL_NS) {
        this.TOTAL_NS = TOTAL_NS;
    }

    public String getUSERNAME() {
        return USERNAME;
    }

    public void setUSERNAME(String USERNAME) {
        this.USERNAME = USERNAME;
    }

    public String getPOST_BY_USERID() {
        return POST_BY_USERID;
    }

    public void setPOST_BY_USERID(String POST_BY_USERID) {
        this.POST_BY_USERID = POST_BY_USERID;
    }

    public String getPOST_DATETIME() {
        return POST_DATETIME;
    }

    public void setPOST_DATETIME(String POST_DATETIME) {
        this.POST_DATETIME = POST_DATETIME;
    }

    public int getTOPICID() {
        return TOPICID;
    }

    public void setTOPICID(int TOPICID) {
        this.TOPICID = TOPICID;
    }

    public long getPOST_ID() {
        return POST_ID;
    }

    public void setPOST_ID(long POST_ID) {
        this.POST_ID = POST_ID;
    }


    public PostCellModel getPostCellModel() {
        return postCellModel;
    }

    public void setPostCellModel(PostCellModel postCellModel) {
        this.postCellModel = postCellModel;
    }


    public Object getMEDIA_FLAG() {
        return MEDIA_FLAG;
    }

    public void setMEDIA_FLAG(Object MEDIA_FLAG) {
        this.MEDIA_FLAG = MEDIA_FLAG;
    }

    public Object getMEDIA_CONTENT() {
        return MEDIA_CONTENT;
    }

    public void setMEDIA_CONTENT(Object MEDIA_CONTENT) {
        this.MEDIA_CONTENT = MEDIA_CONTENT;
    }
}
