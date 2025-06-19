package com.opinito.social.Activity;

import static androidx.core.content.ContentProviderCompat.requireContext;

import android.animation.ObjectAnimator;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.google.gson.JsonObject;
import com.opinito.social.Adapter.NetworkDetailsAdapter;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.NetworkDetailsModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.TimeUtils;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.UserpostsBinding;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class CommonInterests extends AppCompatActivity implements View.OnClickListener {
    NetworkDetailsAdapter mAdapter;
    NetworkDetailsAdapter hateAdapter;
    ArrayList<NetworkDetailsModel> networkDetailsModelArrayList = new ArrayList<>();
    private UserpostsBinding binding;
    private final String TOPICID = "topicid";
    private final String USERNAME = "username";
    private final String PROFILEIMAGE = "profileimage";
    private String userName = "";


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = UserpostsBinding.inflate(getLayoutInflater());
        View view = binding.getRoot();
        setContentView(view);
        Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()), getString(R.string.common_interests), null);
        init();
    }

    private void init() {
        userName = getIntent().getStringExtra(USERNAME);
        if (userName.equals(new Preference(this).getPref(Constants.USERNAME)))
            binding.chatWithUserTv.setVisibility(View.GONE);
        if (userName != null) {
            binding.statusText.setText(String.valueOf(userName.charAt(0)));
            binding.username.setText(userName);
            GradientDrawable background = (GradientDrawable) binding.statusChangeLayoutParentPost.getBackground();
            background.setColor(new ColorChange(this).colorChange((String.valueOf(userName.toLowerCase().charAt(0)))));
            try {
                Glide.with(this)
                        .load(getIntent().getStringExtra(PROFILEIMAGE))
                        .transform(new CircleCrop(),
                                new RoundedCorners(5))
                        .into(binding.statusImage);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (UserUtils.isGuestUser(this))
            binding.chatWithUserTv.setVisibility(View.GONE);
        binding.chatWithUserTv.setOnClickListener(this);
        mAdapter = new NetworkDetailsAdapter(networkDetailsModelArrayList, this, getString(R.string.love));
        binding.networkdetailsRecyclerView.setAdapter(mAdapter);
        hateAdapter = new NetworkDetailsAdapter(networkDetailsModelArrayList, this, getString(R.string.hate));
        binding.networkdetailsRecyclerViewHate.setAdapter(hateAdapter);
        DisplayNetworkDetail();
    }

    public void DisplayNetworkDetail() {
        networkDetailsModelArrayList.clear();
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("uc1", getIntent().getExtras().getString(USERNAME));
        jsonObject.addProperty("uc2", new Preference(getApplicationContext()).getPref(Constants.USERID));
        jsonObject.addProperty("topicid", String.valueOf(new Preference(getApplicationContext()).getIntPref(TOPICID)));
        try {
            Call<List<NetworkDetailsModel>> call = retrofitNetworkInterface.getNetworkDetails(jsonObject);
            call.enqueue(new Callback<List<NetworkDetailsModel>>() {
                @Override
                public void onResponse(Call<List<NetworkDetailsModel>> call, Response<List<NetworkDetailsModel>> response) {
                    if (response.body() != null) {
                        if (response.body().size() > 0) {
                            bindViewsWithData(response.body().get(0));
                            for (int i = 0; i < response.body().size(); i++) {
                                NetworkDetailsModel networkDetailsModel = new NetworkDetailsModel(
                                        response.body().get(i).getTOPIC(),
                                        response.body().get(i).getCART(),
                                        response.body().get(i).getKEYWORDS(),
                                        response.body().get(i).getMATCH_PERCENT(),
                                        response.body().get(i).getMDTM(),
                                        response.body().get(i).getCHF());
                                if (networkDetailsModel.getCART().equals(getString(R.string.hate))) {
                                    binding.networkdetailsRecyclerViewHate.setVisibility(View.VISIBLE);
                                    binding.hateIv.setVisibility(View.VISIBLE);
                                }
                                if (networkDetailsModel.getCART().equals(getString(R.string.love))) {
                                    binding.networkdetailsRecyclerView.setVisibility(View.VISIBLE);
                                    binding.loveIv.setVisibility(View.VISIBLE);
                                }
                                if (new Preference(CommonInterests.this).getBooleanPref(Constants.ISCHATENABLED)) {
                                    if (!userName.equals(new Preference(CommonInterests.this).getPref(Constants.USERNAME))){
                                        if (networkDetailsModel.getCHF().equals(getString(R.string.flay_Y))) {
                                            binding.chatWithUserTv.setVisibility(View.VISIBLE);
                                            binding.disabledChatTv.setVisibility(View.GONE);
                                        } else {
                                            binding.disabledChatTv.setVisibility(View.VISIBLE);
                                            binding.chatWithUserTv.setVisibility(View.GONE);
                                        }
                                    }
                                }
                                networkDetailsModelArrayList.add(networkDetailsModel);
                            }
                        }
                        mAdapter.notifyDataSetChanged();
                        hateAdapter.notifyDataSetChanged();
                    } else{}
//                        Toast.makeText(CommonInterests.this, R.string.something_went_wrong, Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onFailure(Call<List<NetworkDetailsModel>> call, Throwable t) {
                    Toast.makeText(CommonInterests.this, R.string.internal_error_occured, Toast.LENGTH_SHORT).show();
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void bindViewsWithData(NetworkDetailsModel networkDetailsModel) {
        int progress = Integer.parseInt(networkDetailsModel.getMATCH_PERCENT());
        ObjectAnimator.ofInt(binding.horizontalProgressBar, "progress", 0, progress).setDuration(800).start();
        binding.horizontalProgressBar.setProgress(progress);
        binding.match.setText((String.format(getString(R.string.opinion_match), progress)));
        binding.matchSince.setText(new TimeUtils().convertdate(networkDetailsModel.getMDTM()));
    }

    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.chat_with_user_tv) {
            if (UserUtils.isGuestUser(this)) {
                UserUtils.showConfirmation(this);
            } else {
                try {
                    Intent chatIntent = new Intent(this, ChatMessagesActivity.class);
                    chatIntent.putExtra(Constants.PROFILEIMAGE, getIntent().getStringExtra(PROFILEIMAGE));
                    chatIntent.putExtra(Constants.USERNAME, userName);
                    startActivity(chatIntent);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
