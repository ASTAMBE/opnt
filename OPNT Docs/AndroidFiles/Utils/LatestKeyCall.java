package com.opinito.social.Utils;

import android.content.Context;
import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.google.gson.JsonObject;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.LatestKeywordDataClass;
import com.opinito.social.Model.ListLatestKeyword;
import com.opinito.social.RetrofitClient;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Created by Abhay on 15/June/2021.
 */
public class LatestKeyCall {


    public LiveData<List<ListLatestKeyword>> getLatestKeyWord(Context context) {
        MutableLiveData<List<ListLatestKeyword>> list = new MutableLiveData<>();
        Log.d("taggy", "call in latest");
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("userid", new Preference(context).getPref(Constants.USERID));
        Map<String, String> header = new HashMap<>();
        header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
        header.put("Token", new Preference(context).getPref(Constants.token));
        Log.d("taggy", "xkey--" + BuildConfig.APP_ID + "token--" + header.get("Token") + "--user id--" + jsonObject.get("userid"));
        Call<LatestKeywordDataClass> call = retrofitNetworkInterface.getLatestKeyword(header, jsonObject);
        call.enqueue(new Callback<LatestKeywordDataClass>() {
            @Override
            public void onResponse(Call<LatestKeywordDataClass> call, Response<LatestKeywordDataClass> response) {
                if (response.isSuccessful()) {

                    list.setValue(response.body().getData());
//                    Log.d("taggy", response.body().getData().get(0).getKEYWORDS());

                }


            }

            @Override
            public void onFailure(Call<LatestKeywordDataClass> call, Throwable t) {
//                list.setValue(null);
                Log.d("taggy", "on fail" + t.getCause());


            }
        });
        return list;

    }

}
