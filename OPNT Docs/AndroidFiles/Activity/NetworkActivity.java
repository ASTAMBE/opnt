package com.opinito.social.Activity;

import static com.facebook.FacebookSdk.getApplicationContext;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.JsonObject;
import com.opinito.social.Adapter.ProfileAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.ProfileModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.ActivityAllConversationsBinding;
import com.opinito.social.databinding.ActivityNetworkBinding;
import com.opinito.social.databinding.FragmentActivityBinding;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class NetworkActivity extends AppCompatActivity {
    private ArrayList<ProfileModel.Data> profileModelArrayList = new ArrayList<>();
    private ActivityNetworkBinding binding;
    private ProfileAdapter mAdapter;
    public static Boolean refresh = true;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityNetworkBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        init();
        Log.d("tetingak", "onBindViewHolder: 1");


    }

    private void init() {

        mAdapter = new ProfileAdapter(profileModelArrayList, this);
        binding.username.setText(new Preference(this).getPref(Constants.USERNAME));
        binding.countryCode.setText(new Preference(this).getPref(Constants.COUNTRYCODE));
        binding.flagIvActivity.setImageDrawable(getResources().getDrawable(Customize.getCountryFlagRes(
                new Preference(NetworkActivity.this).getPref(Constants.COUNTRYCODE), Objects.requireNonNull(NetworkActivity.this)
        )));
        if (!new Preference(NetworkActivity.this).getPref(Constants.PROFILEIMAGE).isEmpty()) {
            binding.profileImageText.setVisibility(View.GONE);
        } else binding.profileImageText.setVisibility(View.VISIBLE);

            binding.profileImageText.setText(
                    String.valueOf(new Preference(this).getPref(Constants.USERNAME).toUpperCase().charAt(0)));
            GradientDrawable background = (GradientDrawable) binding.profileImage.getBackground();
            background.setColor(new ColorChange(NetworkActivity.this).colorChange(
                    String.valueOf(new Preference(NetworkActivity.this).getPref(Constants.USERNAME).toLowerCase().charAt(0))));
            Glide.with(Objects.requireNonNull(NetworkActivity.this))
                    .load(new Preference(NetworkActivity.this).getPref(Constants.PROFILEIMAGE))
                    .apply(RequestOptions.circleCropTransform())
                    .into(binding.profileImage);

        binding.profileRecyclerView.setAdapter(mAdapter);
        Log.d("tetingak", "onBindViewHolder: 2");
//        binding.addMoreInterest.setOnClickListener(this::onClick);
//        binding.allConversationsTv.setOnClickListener(this::onClick);
        displayTopics();
    }

    public void displayTopics() {


            binding.countryCode.setText(new Preference(NetworkActivity.this).getPref(Constants.COUNTRYCODE));
            binding.flagIvActivity.setImageDrawable(getResources().getDrawable(Customize.getCountryFlagRes(
                    new Preference(NetworkActivity.this).getPref(Constants.COUNTRYCODE), Objects.requireNonNull(NetworkActivity.this)
            )));
            binding.progressBar.setVisibility(View.VISIBLE);

        Log.d("tetingak", "onBindViewHolder: 3");
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("userid", new Preference(NetworkActivity.this).getPref(Constants.USERID));
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<ProfileModel> call = retrofitNetworkInterface.MyActivity(header,jsonObject);
            call.enqueue(new Callback<ProfileModel>() {
                @Override
                public void onResponse(@NotNull Call<ProfileModel> call, @NotNull Response<ProfileModel> response) {
                    try {
                        binding.progressBar.setVisibility(View.GONE);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body().getData().size() > 0){
                                if (response.body().getData().get(0).getChatEnabledFlag().equals(getString(R.string.flay_Y))) {

                                    binding.arrowAllConversation.setVisibility(View.VISIBLE);
                                    new Preference(NetworkActivity.this).saveBooleanPref(Constants.ISCHATENABLED, true);
                                }
                                else {
                                    new Preference(NetworkActivity.this).saveBooleanPref(Constants.ISCHATENABLED, false);
                                    binding.arrowAllConversation.setVisibility(View.GONE);
                                }
                            }
                            ProfileFragment.refresh = true;
                            profileModelArrayList.clear();
                            profileModelArrayList.addAll(response.body().getData());
                            ArrayList<ProfileModel.Data> profileModelArrayList1 = new ArrayList<>();

                            for(int i=0;i<profileModelArrayList.size();i++)
                            {
                                Log.d("arrayliscover", "onResponse: "+new Preference(NetworkActivity.this).getIntPref(Constants.TOPICCARTID));
                                if (new Preference(NetworkActivity.this).getIntPref(Constants.TOPICCARTID)==Integer.parseInt(profileModelArrayList.get(i).getTOPICID())){
                                    profileModelArrayList1.add(profileModelArrayList.get(i));
                                }

                            }
                            profileModelArrayList.clear();
                            profileModelArrayList.addAll(profileModelArrayList1);
                            if(profileModelArrayList.size()<=0){
                                binding.nodataavailable.setVisibility(View.VISIBLE);
                             }

                            mAdapter.notifyDataSetChanged();
                        }
                    }
                    else{
                        Toast.makeText(getApplicationContext(), getString(R.string.something_went_wrong), Toast.LENGTH_LONG).show();

                    }
                }

                @Override
                public void onFailure(@NotNull Call<ProfileModel> call, @NotNull Throwable t) {
                    try {
                        binding.progressBar.setVisibility(View.GONE);
                        Toast.makeText(NetworkActivity.this, R.string.internal_error_occured, Toast.LENGTH_SHORT).show();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

    }
//    @Override
//    public void onClick(View v) {
//        switch (v.getId()) {
//            case R.id.add_more_interest:
//                ((DashBoard) NetworkActivity.this).Tabselection(1);
//                break;
//
//            case R.id.all_conversations_tv:
//                if (UserUtils.isGuestUser(getActivity())) {
//                    UserUtils.showConfirmation(getActivity());
//                } else {
//                    Intent intent = new Intent(getActivity(), AllConversationsActivity.class);
//                    startActivity(intent);
//                }
//                break;
//        }
//    }
}