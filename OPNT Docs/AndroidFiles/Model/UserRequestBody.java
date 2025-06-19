package com.opinito.social.Model;

public class UserRequestBody {

    public static class UserThreadRequest {
        String searchterm , uuid;
        public UserThreadRequest(String uuid, String searchterm){
            this.uuid = uuid;
            this.searchterm = searchterm;
        }
    }
}
