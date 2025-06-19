package com.opinito.social.Model;

/**
 * Created by bhaskar on 12/19/17.
 */

public class PostDetailRequest {{}

    private String topicid;
    private String userid;
    private String from;
    private String to;

    public PostDetailRequest(String topicid, String userid, String from, String to) {
        this.topicid = topicid;
        this.userid = userid;
        this.from = from;
        this.to = to;
    }


}
