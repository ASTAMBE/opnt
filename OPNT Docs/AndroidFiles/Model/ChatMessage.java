package com.opinito.social.Model;

public class ChatMessage {

    private String messageText;
    private String messageBy;
    private String sentAtDTM;

    public ChatMessage(String messageText, String messageBy, String sentAtDTM) {
        this.messageText = messageText;
        this.messageBy = messageBy;
        this.sentAtDTM = sentAtDTM;
    }

    public String getMessageText() {
        return messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public String getMessageBy() {
        return messageBy;
    }

    public void setMessageBy(String messageBy) {
        this.messageBy = messageBy;
    }

    public String getSentAtDTM() {
        return sentAtDTM;
    }

    public void setSentAtDTM(String sentAtDTM) {
        this.sentAtDTM = sentAtDTM;
    }
}
