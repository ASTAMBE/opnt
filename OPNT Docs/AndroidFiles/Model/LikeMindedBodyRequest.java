package com.opinito.social.Model;

public class LikeMindedBodyRequest {
    private String topic_id;
    private String uuid;

    public LikeMindedBodyRequest(String topic_Id, String uuid){
        this.topic_id = topic_Id;
        this.uuid = uuid;
    }

}
