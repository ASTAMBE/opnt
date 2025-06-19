
package com.opinito.social.Model;

import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by Abhay on 11/June/2021.
 */

public class LatestKeywordDataClass {

    @SerializedName("data")
    private List<ListLatestKeyword> mData;
    @SerializedName("status")
    private String mStatus;

    public List<ListLatestKeyword> getData() {
        return mData;
    }

    public void setData(List<ListLatestKeyword> data) {
        mData = data;
    }

    public String getStatus() {
        return mStatus;
    }

    public void setStatus(String status) {
        mStatus = status;
    }

}
