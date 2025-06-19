package com.opinito.social.Model;

/**
 * Created by 502687702 on 8/3/2017.
 */

public class TopicSaveModel {
    int keyId;
    String cart;

    public TopicSaveModel(int keyId,String cart){
        this.keyId = keyId;
        this.cart = cart;
    }

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public String getCart() {
        return cart;
    }

    public void setCart(String cart) {
        this.cart = cart;
    }
}
