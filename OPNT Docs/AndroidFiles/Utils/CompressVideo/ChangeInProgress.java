package com.opinito.social.Utils.CompressVideo;

public class ChangeInProgress {
    private float change;
    private boolean completed;

    public ChangeInProgress(float change, boolean completed) {
        this.change = change;
        this.completed = completed;
    }

    public boolean isCompleted() {
        return completed;
    }

    public float getChange() {
        return change;
    }
}
