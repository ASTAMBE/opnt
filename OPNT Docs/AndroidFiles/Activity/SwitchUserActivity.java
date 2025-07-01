package com.opinito.social.Activity;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.opinito.social.Adapter.FbUserListAdapter;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.RecyclerItemClickListener;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.FbUserModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.ActivitySwitchUserBinding;
import java.util.ArrayList;
import java.util.List;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class SwitchUserActivity extends AppCompatActivity implements View.OnClickListener {

    private ActivitySwitchUserBinding binding;
    private FbUserListAdapter commonAdapter;
    private ArrayList<FbUserModel> userModelArrayList = new ArrayList<>();
    private String select_userid = "";
    private String select_countrycode = "";
    private String select_username = "";
    private String select_token = "";
    int selectedItemPosition = RecyclerView.NO_POSITION;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySwitchUserBinding.inflate(getLayoutInflater());
        View view = binding.getRoot();
        setContentView(view);
        Customize.customSupportBar(this, getSupportActionBar(), getString(R.string.switch_profile), null);
        init();
    }

    private void init() {

        binding.connectedUsername.setText(String.format(getString(R.string.logged_in_with),
                new Preference(this).getPref(Constants.USERNAME)));
        if (new Preference(this).getPref(Constants.PROVIDERTYPE).equals("com.google"))
            binding.connectedWithTv.setText(String.format(getString(R.string.connected_with), "Google"));
        else
            binding.connectedWithTv.setText(String.format(getString(R.string.connected_with), "Facebook"));
        binding.cancel.setOnClickListener(this);
        binding.signin.setOnClickListener(this);

        commonAdapter = new FbUserListAdapter(userModelArrayList, this,
                new Preference(this).getPref(Constants.PROFILEIMAGE));
        RecyclerView.LayoutManager mLayoutManager = new LinearLayoutManager(getApplicationContext());
        binding.fbusersRecyclerView.setLayoutManager(mLayoutManager);
        binding.fbusersRecyclerView.setItemAnimator(new DefaultItemAnimator());
        binding.fbusersRecyclerView.setAdapter(commonAdapter);

        binding.fbusersRecyclerView.addOnItemTouchListener(new RecyclerItemClickListener(this,
                new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        if (selectedItemPosition == position) {
                            selectedItemPosition = RecyclerView.NO_POSITION;
                            select_userid = "";
                        } else {
                            selectedItemPosition = position;
                            select_userid = userModelArrayList.get(position).getUSERID();
                            select_countrycode = userModelArrayList.get(position).getCOUNTRY_CODE();
                            select_username = userModelArrayList.get(position).getUSERNAME();
                            select_token = userModelArrayList.get(position).getToken();
                        }
                    }
                }));
        getUsersList();
    }

    private void getUsersList() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("username", new Preference(this).getPref(Constants.USERNAME));
            jsonObject.addProperty("logintype", new Preference(this).getPref(Constants.PROVIDERTYPE));
            Call<List<FbUserModel>> call = retrofitNetworkInterface.usernamelist(jsonObject);
            call.enqueue(new Callback<List<FbUserModel>>() {
                @Override
                public void onResponse(Call<List<FbUserModel>> call, Response<List<FbUserModel>> response) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            for (FbUserModel fbUserModel : response.body()) {
                                FbUserModel userModel = new
                                        FbUserModel(
                                        fbUserModel.getUSERID(),
                                        fbUserModel.getUSERNAME(),
                                        fbUserModel.getCOUNTRY_CODE(),
                                        fbUserModel.getToken(),
                                        false   );
                                userModelArrayList.add(userModel);
                            }
                            commonAdapter.notifyDataSetChanged();
                        }
                    }
                }

                @Override
                public void onFailure(Call<List<FbUserModel>> call, Throwable t) {
                    Toast.makeText(getApplicationContext(), getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(getApplicationContext(), e.getMessage(), Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.signin:
                if (new Preference(this).getPref(Constants.PROVIDERTYPE).equals("com.google"))
                    logIn();
                else
                    signIN();
                break;

            case R.id.create_profile_tv:
            case R.id.cancel:
                cancel();
                break;
        }
    }

    void cancel() {
        new Preference(this).savePref(Constants.USERNAME, "");
        new Preference(this).savePref(Constants.PROVIDERTYPE, "");
        new Preference(this).savePref(Constants.PROFILEIMAGE, "");
        new Preference(this).saveIntPref(Constants.TOPICID, 0);
        new Preference(this).saveIntPref(Constants.TOPICCARTID, 0);
        UserUtils.logOutUser(this);
        Intent intent = new Intent(SwitchUserActivity.this, Login.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
    }

    void signIN() {
        if (select_userid.equalsIgnoreCase("")) {
            Toast.makeText(this, R.string.select_profile, Toast.LENGTH_SHORT).show();
        } else {
            new Preference(getApplicationContext()).savePref(Constants.PREV_USER,new Preference(getApplicationContext()).getPref(Constants.USERID));

            UserUtils.clearPreferences(this);
            FeedFragment.load = false;
            ActivityFragment.refresh = true;
            ProfileFragment.reload = true;
            ProfileFragment.load = false;
            new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
            new Preference(getApplicationContext()).savePref(Constants.USERID, select_userid);
            new Preference(getApplicationContext()).savePref(Constants.USERNAME, select_username);
            new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE, select_countrycode);
            new Preference(getApplicationContext()).savePref(Constants.token, select_token);
            new Preference(this).saveIntPref(Constants.TOPICID, 0);
            new Preference(this).saveIntPref(Constants.TOPICCARTID, 0);
            Intent intent = new Intent(SwitchUserActivity.this, DashBoard.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            finish();
        }
    }

    void logIn() {
        if (select_userid.equalsIgnoreCase("")) {
            Toast.makeText(this, R.string.select_profile, Toast.LENGTH_SHORT).show();
        } else {
            new Preference(getApplicationContext()).savePref(Constants.PREV_USER,new Preference(getApplicationContext()).getPref(Constants.USERNAME));

            UserUtils.clearPreferences(this);
            FeedFragment.load = false;
            ActivityFragment.refresh = true;
            ProfileFragment.reload = true;
            ProfileFragment.load = false;
            new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
            new Preference(getApplicationContext()).savePref(Constants.USERID, select_userid);
            new Preference(getApplicationContext()).savePref(Constants.USERNAME, select_username);
            new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE, select_countrycode);
            new Preference(getApplicationContext()).savePref(Constants.token, select_token);
            new Preference(this).saveIntPref(Constants.TOPICID, 0);
            new Preference(this).saveIntPref(Constants.TOPICCARTID, 0);
            Intent intent = new Intent(SwitchUserActivity.this, DashBoard.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            finish();
        }
    }
}
