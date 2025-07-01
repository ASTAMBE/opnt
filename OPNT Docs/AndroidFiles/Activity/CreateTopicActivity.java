package com.opinito.social.Activity;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;
import com.google.gson.JsonObject;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.ListFragment;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.Customize;
import com.opinito.social.databinding.CreateTopicBinding;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class CreateTopicActivity extends AppCompatActivity implements View.OnClickListener {
    private String keyWordDescription, keyWord;
    private int keyWordTopicId;
    private boolean love = false, hate = false;
    private CreateTopicBinding binding;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = CreateTopicBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
                "Create Topic", null);
        init();
    }

    private void init() {
        binding.saveTopic.setOnClickListener(this);
        binding.createLove.setOnClickListener(this);
        binding.createHate.setOnClickListener(this);
        keyWord = getIntent().getStringExtra(Constants.KEYWORD);
        keyWordDescription = getIntent().getStringExtra(Constants.KEYWORD_DESCRIPTION);
        keyWordTopicId = Integer.parseInt(getIntent().getStringExtra(Constants.KEYWORD_TOPIC_ID));
        if (!TextUtils.isEmpty(keyWord) && !TextUtils.isEmpty(keyWordDescription)) {
            binding.createTopicName.setText(keyWord);
            binding.createTopicText.setText(keyWordDescription);
            ColorChange.getDrawable(keyWord);
        }
    }

    private void createUserKeyWord(final String userKeyword) {
        showProgress();
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        try {
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("topicid", String.valueOf(new Preference(this).getIntPref(Constants.TOPICCARTID)));
            jsonObject.addProperty("userid", new Preference(this).getPref(Constants.USERID));
            jsonObject.addProperty("userKW", userKeyword);
            jsonObject.addProperty("usercart", getSelectedOpinion());
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<ResponseBody> call = retrofitNetworkInterface.createKeyword(header,jsonObject);
            call.enqueue(new Callback<ResponseBody>() {
                @Override
                public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                    hideProgress();
                    if (response.code() == 200) {
                        FeedFragment.load = false;
                        ActivityFragment.refresh = true;
                        ListFragment.firstLoad = true;
                        FeedFragment.firstLoad = true;
                        ProfileFragment.load = false;
                        new Preference(CreateTopicActivity.this).saveIntPref(Constants.TOPICID, keyWordTopicId);
                        new Preference(CreateTopicActivity.this).saveIntPref(Constants.TOPICCARTID, keyWordTopicId);
                        finish();
                        new Preference(CreateTopicActivity.this).saveBooleanPref(Constants.IS_FROM_CREATE_TOPIC, true);
                    } else
                        Toast.makeText(CreateTopicActivity.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onFailure(Call<ResponseBody> call, Throwable t) {
                    hideProgress();
                    Toast.makeText(CreateTopicActivity.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(CreateTopicActivity.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
            hideProgress();
            e.printStackTrace();
        }
    }

    private void showProgress() {
        try {
            binding.progressBar.setVisibility(View.VISIBLE);
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void hideProgress() {
        try {
            binding.progressBar.setVisibility(View.GONE);
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private boolean isUserSelectedOpinion() {
        return hate || love;
    }

    private String getSelectedOpinion() {
        String selectedOpinion = null;
        if (hate) {
            selectedOpinion = "H";
        } else if (love) {
            selectedOpinion = "L";
        }
        return selectedOpinion;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.save_topic:
                if (isUserSelectedOpinion()) {
                    createUserKeyWord(keyWordDescription);
                } else {
                    Toast.makeText(CreateTopicActivity.this, R.string.create_topic_alert_text, Toast.LENGTH_SHORT).show();
                }
                break;

            case R.id.create_hate:
                if (!hate) {
                    binding.createLove.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colourGrey));
                    binding.createHate.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colorPrimary));
                    hate = true;
                    love = false;
                } else {
                    hate = false;
                    love = false;
                    binding.createLove.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colourGrey));
                    binding.createHate.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colourGrey));
                }
                break;

            case R.id.create_love:
                if (!love) {
                    binding.createLove.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colorPrimary));
                    binding.createHate.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colourGrey));
                    love = true;
                    hate = false;
                } else {
                    love = false;
                    binding.createLove.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colourGrey));
                    binding.createHate.setColorFilter(ContextCompat.getColor(CreateTopicActivity.this, R.color.colourGrey));
                }
                break;
        }
    }
}
