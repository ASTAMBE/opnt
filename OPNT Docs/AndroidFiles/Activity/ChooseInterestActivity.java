package com.opinito.social.Activity;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.opinito.social.Adapter.TopicsGridAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.BaseResponse;
import com.opinito.social.Model.TopicsModel;
import com.opinito.social.Model.TopicsModelNew;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.databinding.ActivityChooseInterestBinding;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;

public class ChooseInterestActivity extends AppCompatActivity implements View.OnClickListener {

    private ActivityChooseInterestBinding chooseInterestBinding;
    private TopicsGridAdapter topicsGridAdapter;
    private List<String> selectedTopicList = new ArrayList<>();
    private List<TopicsModelNew> topicsModels = new ArrayList<>();
    private boolean backPressedSingle = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        chooseInterestBinding = ActivityChooseInterestBinding.inflate(getLayoutInflater());
        View view = chooseInterestBinding.getRoot();
        setContentView(view);
        getAllTopics();
        init();
    }

    private void init() {
//        chooseInterestBinding.navigateBackButton.setOnClickListener(this);
        chooseInterestBinding.nextButtonInterests.setOnClickListener(this);
        chooseInterestBinding.topicsGrid.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
//                int selectedIndex = topicsGridAdapter.selectedPositions.indexOf(position);
//                if (selectedIndex > -1) {
//                    topicsGridAdapter.selectedPositions.remove(selectedIndex);
//                    selectedTopicList.remove(String.valueOf(topicsModels.get(position).getTOPICID()));
//                    topicsGridAdapter.notifyDataSetChanged();
//                } else {
//                    topicsGridAdapter.selectedPositions.add(position);
//                    selectedTopicList.add(String.valueOf(topicsModels.get(position).getTOPICID()));
//                    topicsGridAdapter.notifyDataSetChanged();
//                }
            }
        });
    }

    private void getAllTopics() {
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        JsonObject topicsRequest = new JsonObject();
        topicsRequest.addProperty("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
        Map<String , String> header = new HashMap<>();
        header.put("x-api-key" , Constants.API_KEY);
        header.put("X-ACCESS-KEY" , BuildConfig.APP_ID);
        header.put("Token" , new Preference(getApplicationContext()).getPref(Constants.token));

        Call<List<TopicsModelNew>> call = retrofitNetworkInterface.getTopics( header ,topicsRequest );
        call.enqueue(new Callback<List<TopicsModelNew>>() {
            @Override
            public void onResponse(Call<List<TopicsModelNew>> call, Response<List<TopicsModelNew>> response) {
                if (response.body() != null) {
                    topicsModels.addAll(response.body());
                    List<String> topicNames = new ArrayList<>();
                    for (int i = 0; i < response.body().size(); i++)
                        topicNames.add(response.body().get(i).getTOPIC());
 //                   topicsGridAdapter = new TopicsGridAdapter(ChooseInterestActivity.this, topicNames);
  //                  chooseInterestBinding.topicsGrid.setAdapter(topicsGridAdapter);
                } else
                    Toast.makeText(ChooseInterestActivity.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onFailure(Call<List<TopicsModelNew>> call, Throwable t) {
                Toast.makeText(ChooseInterestActivity.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void saveUserInterests() {
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        JsonObject topicsRequest = new JsonObject();
        topicsRequest.addProperty("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            String selected = selectedTopicList.stream().collect(Collectors.joining(","));
            topicsRequest.addProperty("topicid", selected);
        }
        Map<String, String> header = new HashMap<>();
        header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
        header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
        Call<BaseResponse> call = retrofitNetworkInterface.saveUserInterests(header,topicsRequest);
        call.enqueue(new Callback<BaseResponse>() {
            @Override
            public void onResponse(Call<BaseResponse> call, Response<BaseResponse> response) {
                if (response.body() != null) {
                    if (response.body().getStatus().equals(getString(R.string.success_status))) {
                        ActivityFragment.refresh = true;
                        Intent intent = new Intent(ChooseInterestActivity.this, DashBoard.class);
                        startActivity(intent);
                        finish();
                    } else
                        Toast.makeText(ChooseInterestActivity.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<BaseResponse> call, Throwable t) {
                Toast.makeText(ChooseInterestActivity.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public void onBackPressed() {
        if (backPressedSingle) {
            Toast.makeText(this, R.string.back_to_exit, Toast.LENGTH_SHORT).show();
            backPressedSingle = false;
        } else {
            backPressedSingle = true;
            super.onBackPressed();
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.navigate_back_button:
                onBackPressed();
                break;

            case R.id.next_button_interests:
                if (selectedTopicList.size() > 0)
                    saveUserInterests();
                else
                    Toast.makeText(this, getString(R.string.select_topic), Toast.LENGTH_SHORT).show();
                break;
        }
    }
}
