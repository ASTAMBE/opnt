package com.opinito.social.Utils;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.gson.JsonObject;
import com.opinito.social.Adapter.AdapterLatestKeyWord;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.ListLatestKeyword;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;

/**
 * Created by Abhay on 15/June/2021.
 */
public class BottomSheetDialog extends DialogFragment implements AdapterLatestKeyWord.OnClickedListener {
    RecyclerView recyclerView;
    AdapterLatestKeyWord adapterLatestKeyWord;
    ArrayList<ListLatestKeyword> arrayList;
    ArrayList<ListLatestKeyword> postList;
    HashSet<String> list;
    ArrayList<String> list2;
    ProgressBar progressBar;
    private BottomSheetBehavior mBehavior;
    Button skipBtn, saveBtn;
    Boolean count = false;

    public BottomSheetDialog(ArrayList<ListLatestKeyword> arrayList) {
        this.arrayList = arrayList;
    }


    @NonNull
    @NotNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        //the color is a direct color int and not a color resource
        View v = View.inflate(getContext(), R.layout.latest_keywords_ui, null);

        postList = new ArrayList<>();
        recyclerView = v.findViewById(R.id.rvlatestKW);
        skipBtn = v.findViewById(R.id.latest_keywords_skip_Btn);
        saveBtn = v.findViewById(R.id.latest_keywords_save_Btn);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        list = new HashSet<>();
        progressBar = v.findViewById(R.id.progress_bar_latest_Keyword);

        for (int i = 0; i < arrayList.size(); i++) {
            list.add(arrayList.get(i).getTOPIC());

        }
        list2 = new ArrayList<>();
        list2.addAll(list);
        if (list2 == null) {
            progressBar.setVisibility(View.GONE);
        }
        adapterLatestKeyWord = new AdapterLatestKeyWord(getContext(), list2, arrayList, getActivity(), this);
        adapterLatestKeyWord.setOnClickedListener(this::Clicked);
        recyclerView.setAdapter(adapterLatestKeyWord);
        progressBar.setVisibility(View.GONE);


        dialog.setContentView(v);
//        mBehavior = BottomSheetBehavior.from((View) v.getParent());
        skipBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
//                mBehavior.setState(BottomSheetBehavior.STATE_HIDDEN);
                dismiss();
            }
        });
        saveBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                for (int i = 0; i < postList.size(); i++) {
                    Log.d("taggy", "data-->" + postList.get(i).getCART() + " size is" + postList.size() + " key is" + postList.get(i).getTAG1KEYID());
                }
                if (postList.size() > 0) {
                    SaveLatestKeywordsCards();
                } else
                    Toast.makeText(getActivity(), "Please select atleast one item", Toast.LENGTH_SHORT).show();

            }
        });

        return dialog;
    }


    private void SaveLatestKeywordsCards() {
        ProgressDialog dialog = ProgressDialog.show(getContext(), "",
                "Saving. Please wait...", true);

        JSONArray jsonArray = new JSONArray();
        for (int i = 0; i < postList.size(); i++) {
            if (postList.get(i).getCART().equalsIgnoreCase("L") ||
                    postList.get(i).getCART().equalsIgnoreCase("H")) {
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("CART", postList.get(i).getCART());
                    jsonObject.put("KEYID", postList.get(i).getTAG1KEYID());
                    jsonObject.put("TOPICID", postList.get(i).getTOPICID());
                    jsonArray.put(jsonObject);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        try {
            String selectedTopicId = String.valueOf(jsonArray.getJSONObject(0).get("TOPICID"));
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject saveSearchCart = new JsonObject();
            saveSearchCart.addProperty("userid", new Preference(getActivity()).getPref(Constants.USERID));
            //saveSearchCart.addProperty("topicid", String.valueOf(new Preference(getActivity()).getIntPref(Constants.TOPICCARTID)));
            saveSearchCart.addProperty("topicid", selectedTopicId);
            saveSearchCart.addProperty("topiccarts", jsonArray.toString());
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<ResponseBody> call = retrofitNetworkInterface.addSearchTopicToCart(header, saveSearchCart);
            call.enqueue(new Callback<ResponseBody>() {
                @Override
                public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            dialog.dismiss();
                            dismiss();
                            new Preference(getActivity()).saveIntPref(Constants.TOPICID, Integer.parseInt(selectedTopicId));
//                            mBehavior.setState(BottomSheetBehavior.STATE_HIDDEN);
                            Toast.makeText(getActivity(), "Saved Successfully", Toast.LENGTH_SHORT).show();

                        }
                    } else {
                        Toast.makeText(getContext(), getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                            dialog.dismiss();
                        dismiss();

                    }
                }

                @Override
                public void onFailure(Call<ResponseBody> call, Throwable t) {
                    progressBar.setVisibility(View.GONE);
                    dialog.dismiss();
                    Toast.makeText(getContext(), getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    @Override
    public void onStart() {
        super.onStart();
//        mBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
    }


    @Override
    public void onCreate(@Nullable @org.jetbrains.annotations.Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public static int getScreenHeight() {
        return Resources.getSystem().getDisplayMetrics().heightPixels;
    }


    @Override
    public void Clicked(String cart, String keyid, String topicid, int manipulate) {



        Log.d("taggy", "cart-->" + cart + " key id-->" + keyid + " manip-->" + manipulate);
        if (manipulate == 0) {

            for (int i = 0; i < postList.size(); i++) {
                if (postList.get(i).getTAG1KEYID().equals(keyid)) {
                    postList.remove(i);
                }
            }
        } else if (manipulate == 1) {
            for (int i = 0; i < postList.size(); i++) {
                if (postList.get(i).getTAG1KEYID().equals(keyid)) {
                    postList.remove(i);
                }
            }
            if (!cart.equals(""))
                postList.add(new ListLatestKeyword(cart, "", "", keyid, "", topicid));
        } else if (manipulate == 2) {
            for (int i = 0; i < postList.size(); i++) {
                if (postList.get(i).getTAG1KEYID().equals(keyid)) {
                    postList.remove(i);
                }
            }
        } else if (manipulate == 3) {
            for (int i = 0; i < postList.size(); i++) {
                if (postList.get(i).getTAG1KEYID().equals(keyid)) {
                    postList.remove(i);
                }
            }
            if (!cart.equals(""))
                postList.add(new ListLatestKeyword(cart, "", "", keyid, "", topicid));
        }
        if (postList.size() > 0) {
            saveBtn.setBackgroundTintList(ColorStateList.valueOf(getResources().getColor(R.color.yellow)));
        }
        else {
            saveBtn.setBackgroundTintList(ColorStateList.valueOf(getResources().getColor(R.color.light_grey)));
        }
    }

}
