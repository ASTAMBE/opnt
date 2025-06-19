package com.opinito.social.Model;

public class DeleteUserModel {
    public DeleteUserModel(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String status= "";
}
