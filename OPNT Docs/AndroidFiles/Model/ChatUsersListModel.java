package com.opinito.social.Model;

public class ChatUsersListModel {
    String username;
    String lastSeenDTM;
    String profileUrl;

    public ChatUsersListModel(String username, String lastSeenDTM, String profileUrl) {
        this.username = username;
        this.lastSeenDTM = lastSeenDTM;
        this.profileUrl = profileUrl;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getLastSeenDTM() {
        return lastSeenDTM;
    }

    public void setLastSeenDTM(String lastSeenDTM) {
        this.lastSeenDTM = lastSeenDTM;
    }

    public String getProfileUrl() {
        return profileUrl;
    }

    public void setProfileUrl(String profileUrl) {
        this.profileUrl = profileUrl;
    }
}
