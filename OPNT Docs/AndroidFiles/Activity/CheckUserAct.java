package com.opinito.social.Activity;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.SearchView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.opinito.social.Adapter.ReportedUserAdapter;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.BaseResponse;
import com.opinito.social.Model.GetUserActivityModel;
import com.opinito.social.Model.UserKOContent;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.Customize;
import com.opinito.social.databinding.ActivityCheckUserBinding;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class CheckUserAct extends AppCompatActivity implements View.OnClickListener {

    private ActivityCheckUserBinding binding;
    private String searchedUsername = "";
    private List<UserKOContent.Data> userKoContentList = new ArrayList<>();
    private ReportedUserAdapter userAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityCheckUserBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
                getString(R.string.check_user_activity), null);
        init();
    }

    private void init() {
        binding.searchUsername.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                clearViews();
                CheckUserAct.this.searchedUsername = query.trim();
                getuseractivity();
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                if (newText.trim().isEmpty())
                    clearViews();
                return false;
            }
        });
        binding.kickedOutCount.setOnClickListener(this);
        userAdapter = new ReportedUserAdapter(userKoContentList, CheckUserAct.this);
        binding.koRecyclerContentView.setAdapter(userAdapter);
        binding.suspendUser.setOnClickListener(this);
    }

    private void clearViews(){
        userKoContentList.clear();
        userAdapter.notifyDataSetChanged();
        binding.suspendUser.setVisibility(View.GONE);
        binding.lookedForUsername.setText("");
        binding.kickedOutCount.setText("");
        binding.reportedCount.setText("");
        binding.commentCountYear.setText("");
        binding.commentCountDays.setText("");
        binding.postCountYear.setText("");
        binding.postCountDays.setText("");
    }

    private void getuseractivity() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject getUserRequest = new JsonObject();
            getUserRequest.addProperty(Constants.USERNAME, searchedUsername);
            Call<GetUserActivityModel> call = retrofitNetworkInterface.getUserActivity(getUserRequest);
            call.enqueue(new Callback<GetUserActivityModel>() {
                @Override
                public void onResponse(Call<GetUserActivityModel> call, Response<GetUserActivityModel> response) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                bindWithViews(response.body());
                            } else {
                                Toast.makeText(CheckUserAct.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                            }
                        }
                    }
                }

                @Override
                public void onFailure(Call<GetUserActivityModel> call, Throwable t) {
                    Toast.makeText(CheckUserAct.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e){
            Toast.makeText(CheckUserAct.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
        }
    }

    private void bindWithViews(GetUserActivityModel getUserActivityModel){
        binding.suspendUser.setVisibility(View.VISIBLE);
        binding.lookedForUsername.setText(String.format(getString(R.string.you_looked_for),
                getUserActivityModel.getData().get(0).getUsername()));
        binding.postCountDays.setText(String.format(getString(R.string.post_count_days),
                getUserActivityModel.getData().get(0).getPcount7day()));
        binding.postCountYear.setText(String.format(getString(R.string.post_count_year),
                getUserActivityModel.getData().get(0).getPcountYear()));
        binding.commentCountDays.setText(String.format(getString(R.string.comment_count_days),
                getUserActivityModel.getData().get(0).getCcount7day()));
        binding.commentCountYear.setText(String.format(getString(R.string.comment_count_year),
                getUserActivityModel.getData().get(0).getCcountYear()));
        binding.kickedOutCount.setText(String.format(getString(R.string.kicked_out_count),
                getUserActivityModel.getData().get(0).getKoCount()));
        binding.reportedCount.setText(String.format(getString(R.string.reported_count),
                getUserActivityModel.getData().get(0).getReportedCount7()));
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.kicked_out_count:
                getReportContent();
                break;

            case R.id.suspend_user:
                showConfirmation();
                break;
        }
    }

    private void getReportContent() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject getReportContentRequest = new JsonObject();
            getReportContentRequest.addProperty(Constants.USERNAME, searchedUsername);
            Call<UserKOContent> call = retrofitNetworkInterface.getKOContent(getReportContentRequest);
            call.enqueue(new Callback<UserKOContent>() {
                @Override
                public void onResponse(Call<UserKOContent> call, Response<UserKOContent> response) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                userKoContentList.clear();
                                userKoContentList.addAll(response.body().getData());
                                userAdapter.notifyDataSetChanged();
                            }
                        }
                    }
                }

                @Override
                public void onFailure(Call<UserKOContent> call, Throwable t) {
                    Toast.makeText(CheckUserAct.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e){
            Toast.makeText(CheckUserAct.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
        }
    }

    private void suspendUser() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject suspendUSerRequest = new JsonObject();
            suspendUSerRequest.addProperty(Constants.USERNAME, searchedUsername);
            Call<BaseResponse> call = retrofitNetworkInterface.suspendUser(suspendUSerRequest);
            call.enqueue(new Callback<BaseResponse>() {
                @Override
                public void onResponse(Call<BaseResponse> call, Response<BaseResponse> response) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                Toast.makeText(CheckUserAct.this, R.string.user_suspended, Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(CheckUserAct.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                            }
                        }
                    }
                }

                @Override
                public void onFailure(Call<BaseResponse> call, Throwable t) {
                    Toast.makeText(CheckUserAct.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e){
            Toast.makeText(CheckUserAct.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
        }
    }

    public void showConfirmation() {
        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(this, R.style.MyCustomDialogTheme);
        LayoutInflater inflater = this.getLayoutInflater();
        final View dialogView = inflater.inflate(R.layout.confirm_dialog, null);
        dialogBuilder.setView(dialogView);
        final TextView dialogText = dialogView.findViewById(R.id.top_tv);
        dialogText.setText(getString(R.string.sure_to_suspend));
        final Button btnYes = dialogView.findViewById(R.id.btnyes);
        final Button btnCancel = dialogView.findViewById(R.id.btncancel);
        final AlertDialog alertDialog = dialogBuilder.create();
        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                suspendUser();
                alertDialog.dismiss();
            }
        });

        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                alertDialog.dismiss();
            }
        });
        alertDialog.setCanceledOnTouchOutside(false);
        alertDialog.show();
    }
}
