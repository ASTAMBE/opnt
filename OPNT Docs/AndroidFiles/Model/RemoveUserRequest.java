package com.opinito.social.Model;

public class RemoveUserRequest {
    String postid, userid , topicid, postuserid;

    public RemoveUserRequest(String postid, String userid, String topicid, String postuserid) {
        this.postid = postid;
        this.userid = userid;
        this.topicid = topicid;
        this.postuserid = postuserid;
    }
}
