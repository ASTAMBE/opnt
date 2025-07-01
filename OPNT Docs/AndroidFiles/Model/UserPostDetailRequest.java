package com.opinito.social.Model;

/**
 * Created by bhaskar on 12/19/17.
 */

public class UserPostDetailRequest {

    private String postid;
    private String userid;

    public UserPostDetailRequest(String postid, String userid) {
        this.postid = postid;
        this.userid = userid;
    }
}
