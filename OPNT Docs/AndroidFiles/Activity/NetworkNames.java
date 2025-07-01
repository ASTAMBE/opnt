package com.opinito.social.Activity;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.View;
import android.view.animation.AnimationUtils;
import android.view.animation.LayoutAnimationController;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.opinito.social.Adapter.NetworkNamesAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.RecyclerItemClickListener;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.NetworkNameModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.Customize;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class NetworkNames extends AppCompatActivity {
    RecyclerView recyclerView;
    NetworkNamesAdapter mAdapter;
    ArrayList<NetworkNameModel> networkNameModelArrayList;
    private final String TOPICNAME = "topicname";
    private final String TOPICID = "topicid";
    private final String USERNAME = "username";
    private final String PROFILEIMAGE = "profileimage";
    private int count = 0;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.networknames);
        Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
                String.format("%s %s", getIntent().getStringExtra(TOPICNAME), getString(R.string.title_network)), null);
        networkNameModelArrayList = new ArrayList<>();
        recyclerView = findViewById(R.id.network_recycler_view);
        RecyclerView.LayoutManager mLayoutManager = new LinearLayoutManager(getApplicationContext());
        recyclerView.setLayoutManager(mLayoutManager);
        mAdapter = new NetworkNamesAdapter(networkNameModelArrayList, getApplicationContext());
        recyclerView.setAdapter(mAdapter);

        recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(getApplicationContext(), new RecyclerItemClickListener.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                Intent intent = new Intent(getApplicationContext(), CommonInterests.class);
                intent.putExtra(TOPICID, networkNameModelArrayList.get(position).getTOPICID());
                intent.putExtra(USERNAME, networkNameModelArrayList.get(position).getUSERNAME());
                intent.putExtra(PROFILEIMAGE, networkNameModelArrayList.get(position).getDP_URL());
                startActivity(intent);
            }
        }));
        displayNetwork();
    }

    private void displayNetwork() {
        networkNameModelArrayList.clear();
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
        jsonObject.addProperty("topicid", getIntent().getExtras().getString(TOPICID));
        jsonObject.addProperty("fromIndex", Constants.from);
        jsonObject.addProperty("toIndex", "100");
        Map<String, String> header = new HashMap<>();
        header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
        header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
        try {
            Call<List<NetworkNameModel>> call = retrofitNetworkInterface.networkNamesByUsername(header ,jsonObject);
            call.enqueue(new Callback<List<NetworkNameModel>>() {
                @Override
                public void onResponse(Call<List<NetworkNameModel>> call, Response<List<NetworkNameModel>> response) {
                    if (response.body() != null)
                        if (response.body().size() > 0) {
                            networkNameModelArrayList.addAll(response.body());
                            String deviceName = new Preference(getApplicationContext()).getPref("DeviceName");
                            String googleDeviceName =  new Preference(getApplicationContext()).getPref(Constants.USERNAME);
                            for (int i = 0; i < response.body().size(); i++)
                            {
                                if(networkNameModelArrayList.get(i).getUSERNAME().equalsIgnoreCase(deviceName) ||
                                        networkNameModelArrayList.get(i).getUSERNAME().equalsIgnoreCase(googleDeviceName))
                                {
                                   count = i;

                                }
                            }

                            networkNameModelArrayList.remove(count);
                        }
                    else
                            Toast.makeText(NetworkNames.this, R.string.something_went_wrong, Toast.LENGTH_SHORT).show();
                    final LayoutAnimationController controller =
                            AnimationUtils.loadLayoutAnimation(NetworkNames.this, R.anim.layout_animation_left_to_right);
                    recyclerView.setLayoutAnimation(controller);
                    mAdapter.notifyDataSetChanged();
                    recyclerView.scheduleLayoutAnimation();
                }

                @Override
                public void onFailure(Call<List<NetworkNameModel>> call, Throwable t) {
                    Toast.makeText(NetworkNames.this, R.string.internal_error_occured, Toast.LENGTH_SHORT).show();
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
