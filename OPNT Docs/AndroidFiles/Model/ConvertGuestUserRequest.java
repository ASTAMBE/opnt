package com.opinito.social.Model;

public class ConvertGuestUserRequest {

    String guestuuid, newUName, userid, username, dp_url, convert_type;

    public ConvertGuestUserRequest(String guestuuid, String newUName, String userid, String username, String dp_url, String convert_type) {
        this.guestuuid = guestuuid;
        this.newUName = newUName;
        this.userid = userid;
        this.username = username;
        this.dp_url = dp_url;
        this.convert_type = convert_type;
    }
}
