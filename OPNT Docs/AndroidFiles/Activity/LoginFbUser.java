package com.opinito.social.Activity;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.provider.Settings;
import android.text.Editable;
import android.text.Html;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.google.gson.JsonObject;
import com.opinito.social.Adapter.ConvertGuestUserAdapter;
import com.opinito.social.Adapter.FbUserListAdapter;
import com.opinito.social.Adapter.GogUserListAdapter;
import com.opinito.social.Async.CommonAsync;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.RecyclerItemClickListener;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.ConvertGuestUserModel;
import com.opinito.social.Model.ConvertGuestUserRequest;
import com.opinito.social.Model.GoogleCreateUserModel;
import com.opinito.social.Model.FbUserModel;
import com.opinito.social.Model.GoogleSigninRequest;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.SessionManager;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.UserUtils;

import org.json.JSONArray;
import org.json.JSONObject;
import org.w3c.dom.Text;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import java.util.Locale;


/**
 * Created by 502687702 on 9/7/2017.
 */

public class LoginFbUser extends AppCompatActivity implements View.OnClickListener {
    Button btn_signin;
    TextView cancelTv;
    EditText createProfile;
    //String countryCode = "IND";
    Spinner countrySpinner;
    ImageView profileImage;
    ArrayList<FbUserModel> fbUserModelArrayList = new ArrayList<>();
    ArrayList<GoogleSigninRequest> googleLoginModelArrayList = new ArrayList<>();
    ArrayList<ConvertGuestUserModel> convertGuestUserModelArrayList = new ArrayList<>();
    private LayoutInflater mInflater;
    RecyclerView recyclerView;
    FbUserListAdapter mAdapter;
    GogUserListAdapter gogUserListAdapter;
    ConvertGuestUserAdapter convertGuestUserAdapter;
    ConvertGuestUserRequest convertGuestUserRequest;
    String select_userid = "";
    String select_countrycode = "";
    String select_username = "";
    String select_token = "";
    private TextView orCreateTv;
    private RelativeLayout profileLayout;
    private TextView connectedWith;

    private RelativeLayout rootLayout;
    private int initialHeightDiff = -1;
    RelativeLayout connectionLayout;
    Button next;


    String fName = "", lName = "", googleEmail = "", googleUsername = "", googleUserId, profileUrl = "",
            providerType, userId = "", deviceName = "", userUUID = "", facebookUserName = "", getCountryCode = "", tcc = "";
    TextView tvCountry;
    ImageView ivCountryFlag;
    private SessionManager sessionManager;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_fbuser);
        Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()), getString(R.string.app_name), null);
        //countrySpinner = findViewById(R.id.country_spinner);
        connectionLayout = findViewById(R.id.connection);
        next = findViewById(R.id.signin);
        sessionManager = new SessionManager(this);

        rootLayout = findViewById(R.id.connection);

        // Add an OnGlobalLayoutListener to the root layout
        rootLayout.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {


                // Calculate the height difference between the layout and the visible area
                int heightDiff = rootLayout.getRootView().getHeight() - rootLayout.getHeight();
                if (initialHeightDiff == -1) {
                    initialHeightDiff = heightDiff;
                    return;
                }
                // If the height difference is greater than initialHeightDiff, the keyboard is open
                if (heightDiff > initialHeightDiff) {
                    // Scroll the layout up by the height difference
                    connectionLayout.setVisibility(View.GONE);
                    next.setVisibility(View.GONE);
                    rootLayout.scrollTo(0, heightDiff);
                } else {
                    // Keyboard is closed, reset the layout position
                    connectionLayout.setVisibility(View.VISIBLE);
                    next.setVisibility(View.VISIBLE);
                    rootLayout.scrollTo(0, 0);
                }
            }
        });


        createProfile = findViewById(R.id.createprofile);
        connectedWith = findViewById(R.id.connected_with_tv);
        orCreateTv = findViewById(R.id.create_profile_tv);
        profileImage = findViewById(R.id.new_user_image);
        tvCountry = findViewById(R.id.country_code);
        ivCountryFlag = findViewById(R.id.flag_iv_activity);
        //createSpinner();
        Intent intent = getIntent();
        providerType = intent.getStringExtra("providertype");
        userId = intent.getStringExtra("fb_userid");
        fName = intent.getStringExtra("fname");
        lName = intent.getStringExtra("lname");
        facebookUserName = intent.getStringExtra("fb_username");
        googleEmail = intent.getStringExtra("google_email");
        googleUsername = intent.getStringExtra("Google_username");
        googleUserId = intent.getStringExtra("Google_userid");
        getCountryCode = intent.getStringExtra("countryCode");

// DO NOT auto-fetch or call getGoogleUserApi here. It must be triggered manually after user chooses to create a new profile.
        Log.d("LOGIN_FLOW", "Country code = " + getCountryCode + " — Deferring getGoogleUserApi() until user triggers profile creation.");



        tvCountry.setText(getCountryCode);
//        ivCountryFlag.setImageDrawable(getResources().getDrawable(Customize.getCountryFlagRes(
//                getCountryCode,getApplicationContext())
//        ));
        deviceName = new Preference(getApplicationContext()).getPref(Constants.DEVICENAME);
        userUUID = new Preference(getApplicationContext()).getPref(Constants.UUID);
        new Preference(getApplicationContext()).savePref(Constants.PROVIDERTYPE, providerType);
        if (providerType.equals("com.google")) {
            connectedWith.setText(String.format(getString(R.string.connected_with), googleEmail));
            Uri uri = intent.getData();
            if (uri != null)
                profileUrl = uri.toString();
        } else {
            connectedWith.setText(String.format(getString(R.string.connected_with), facebookUserName));
            profileUrl = "https://graph.facebook.com/" + userId + "/picture?type=large";
        }
        if (!profileUrl.trim().isEmpty())
            Glide.with(this)
                    .load(profileUrl)
                    .transform(new CircleCrop(),
                            new RoundedCorners(5))
                    .into(profileImage);

        btn_signin = findViewById(R.id.signin);
        cancelTv = findViewById(R.id.cancel);

        cancelTv.setOnClickListener(this);
        btn_signin.setOnClickListener(this);

        profileLayout = findViewById(R.id.profileLayout);

        mInflater = LayoutInflater.from(getApplicationContext());

        recyclerView = findViewById(R.id.fbusers_recycler_view);

        RecyclerView.LayoutManager mLayoutManager = new LinearLayoutManager(getApplicationContext());
        recyclerView.setLayoutManager(mLayoutManager);
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        if (providerType.equals("com.google")) {
            gogUserListAdapter = new GogUserListAdapter(googleLoginModelArrayList, getApplicationContext(), profileUrl);
            recyclerView.setAdapter(gogUserListAdapter);
            gogUserListAdapter.notifyDataSetChanged();
        } else {
            mAdapter = new FbUserListAdapter(fbUserModelArrayList, getApplicationContext(), profileUrl);
            recyclerView.setAdapter(mAdapter);
            mAdapter.notifyDataSetChanged();
        }

        recyclerView.invalidate();
        if (!deviceName.isEmpty()) {
            convertGuestUserAdapter = new ConvertGuestUserAdapter(convertGuestUserModelArrayList, getApplicationContext(), profileUrl);
            recyclerView.setAdapter(convertGuestUserAdapter);
            convertGuestUserAdapter.notifyDataSetChanged();

            recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(getApplicationContext(), new RecyclerItemClickListener.OnItemClickListener() {
                @Override
                public void onItemClick(View view, int position) {
                    createProfile.setText("");
                    new Preference(LoginFbUser.this).saveIntPref(Constants.HOWTOUSE, 1);
                    //new Preference(LoginFbUser.this).savePref(Constants.REFFERERUSERID, "");
                    select_userid = convertGuestUserModelArrayList.get(position).getData().getUSERID();
                    select_countrycode = convertGuestUserModelArrayList.get(position).getData().getCOUNTRYCODE();
                    select_username = convertGuestUserModelArrayList.get(position).getData().getUSERNAME();
                }
            }));
        } else {
            if (!providerType.equals("com.google")) {
                recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(getApplicationContext(), new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        createProfile.setText("");
                        //new Preference(LoginFbUser.this).savePref(Constants.REFFERERUSERID, "");
                        new Preference(LoginFbUser.this).saveIntPref(Constants.HOWTOUSE, 1);
                        if (!fbUserModelArrayList.get(position).getSELECTED()) {
                            orCreateTv.setVisibility(View.GONE);
                            profileLayout.setVisibility(View.GONE);
                            select_userid = fbUserModelArrayList.get(position).getUSERID();
                            select_countrycode = fbUserModelArrayList.get(position).getCOUNTRY_CODE();
                            select_username = fbUserModelArrayList.get(position).getUSERNAME();
                            select_token = fbUserModelArrayList.get(position).getToken();
                        } else {
                            select_userid = "";
                            select_countrycode = "";
                            select_username = "";
                            select_token = "";
                            if (fbUserModelArrayList.size() < 5) {
                                orCreateTv.setVisibility(View.VISIBLE);
                                profileLayout.setVisibility(View.VISIBLE);
                            }
                        }
                    }
                }));
            } else {
                recyclerView.addOnItemTouchListener(new RecyclerItemClickListener(getApplicationContext(), new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        createProfile.setText("");
                        // new Preference(LoginFbUser.this).savePref(Constants.REFFERERUSERID, "");
                        new Preference(LoginFbUser.this).saveIntPref(Constants.HOWTOUSE, 1);
                        if (!googleLoginModelArrayList.get(position).getSELECTED()) {
                            orCreateTv.setVisibility(View.GONE);
                            profileLayout.setVisibility(View.GONE);
                            select_userid = googleLoginModelArrayList.get(position).getUSERID();
                            select_countrycode = googleLoginModelArrayList.get(position).getCOUNTRY_CODE();
                            select_username = googleLoginModelArrayList.get(position).getUSERNAME();
                            select_token = googleLoginModelArrayList.get(position).getToken();
                        } else {
                            select_userid = "";
                            select_countrycode = "";
                            select_username = "";
                            select_token = "";
                            if (googleLoginModelArrayList.size() < 5) {
                                orCreateTv.setVisibility(View.VISIBLE);
                                profileLayout.setVisibility(View.VISIBLE);
                            }
                        }
                    }
                }));
            }
        }
        createProfile.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                connectionLayout.setVisibility(View.GONE);
                next.setVisibility(View.GONE);
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().trim().isEmpty()) {
                    try {
                        gogUserListAdapter.clearSelections();
                    } catch (Exception e) {
                        mAdapter.clearSelections();
                    }
                    select_countrycode = "";
                    select_username = "";
                    select_userid = "";
                    select_token = "";
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                connectionLayout.setVisibility(View.VISIBLE);
                next.setVisibility(View.VISIBLE);
            }
        });
        fbUserModelArrayList.clear();
        googleLoginModelArrayList.clear();
        convertGuestUserModelArrayList.clear();

        if (!deviceName.isEmpty())
            convertGuestUser();
        else {
            if (providerType.equals("com.google"))
                loginwithGoogle();
            else
                loginwithFBUser();
        }
    }

//    private void createSpinner() {
//        List<String> countryCodes = new ArrayList<String>();
//        countryCodes.add(getString(R.string.ind));
//        countryCodes.add(getString(R.string.usa));
//        countryCodes.add(getString(R.string.global));
//        CustomArrayAdapter countryCodeAdapter = new CustomArrayAdapter(this, R.layout.spinner_item, countryCodes);
//        countryCodeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//        countrySpinner.setAdapter(countryCodeAdapter);
//        if (new Preference(LoginFbUser.this).getBooleanPref(Constants.ISDEEPLINK) &&
//                !new Preference(LoginFbUser.this).getPref(Constants.REFFERERUSERID).isEmpty()) {
//            String selectedCode = "";
//            for (int i = 0; i < countryCodes.size(); i++) {
//                if (countryCodes.get(i).equals(getString(R.string.global)))
//                    selectedCode = getString(R.string.GGG);
//                else
//                    selectedCode = countryCodes.get(i);
//                String deeplinkCountryCode = new Preference(LoginFbUser.this).getPref(Constants.DEEPLINKCOUNTRYCODE);
//                if (deeplinkCountryCode.trim().equals(selectedCode.trim())) {
//                    countrySpinner.setSelection(i);
//                    countryCode = selectedCode;
//                    countrySpinner.setEnabled(false);
//                }
//            }
//        }
//        countrySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
//            @Override
//            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
//                if (((TextView) view.findViewById(R.id.spinner_text)).getText().toString().equals(getString(R.string.global)))
//                    countryCode = getString(R.string.GGG);
//                else
//                    countryCode = ((TextView) view.findViewById(R.id.spinner_text)).getText().toString().trim();
//            }
//
//            @Override
//            public void onNothingSelected(AdapterView<?> parent) {

//            }
//        });
//    }

    public class CustomArrayAdapter extends ArrayAdapter<String> {

        private final LayoutInflater mInflater;
        private final Context mContext;
        private final List<String> items;
        private final int mResource;

        public CustomArrayAdapter(@NonNull Context context, @LayoutRes int resource,
                                  @NonNull List<String> itemsList) {
            super(context, resource, 0, itemsList);

            mContext = context;
            mInflater = LayoutInflater.from(context);
            mResource = resource;
            items = itemsList;
        }

        @Override
        public View getDropDownView(int position, @Nullable View convertView,
                                    @NonNull ViewGroup parent) {
            return createItemView(position, convertView, parent);
        }

        @Override
        public @NonNull
        View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
            return createItemView(position, convertView, parent);
        }

        private View createItemView(int position, View convertView, ViewGroup parent) {
            final View view = mInflater.inflate(mResource, parent, false);
            TextView spinnerText = view.findViewById(R.id.spinner_text);
            ImageView countryFlag = view.findViewById(R.id.flag_iv_activity);
            spinnerText.setText(items.get(position));
            countryFlag.setImageDrawable(getResources().getDrawable(Customize.getCountryFlagRes(items.get(position).trim(), getContext())));
            return view;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    void convertGuestUser() {
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        if (googleUserId != null) {
            convertGuestUserRequest = new ConvertGuestUserRequest
                    (userUUID, deviceName, googleUserId, googleUsername, profileUrl, providerType);
        } else {
            convertGuestUserRequest = new ConvertGuestUserRequest
                    (userUUID, deviceName, userId, getIntent().getExtras().getString("fb_username"), profileUrl, providerType);
        }
        Call<ConvertGuestUserModel> call = retrofitNetworkInterface.convertGuestUserGogFb(convertGuestUserRequest);
        try {
            call.enqueue(new Callback<ConvertGuestUserModel>() {
                @Override
                public void onResponse(Call<ConvertGuestUserModel> call, Response<ConvertGuestUserModel> response) {
                    if (response.code() == 200 && response.body() != null) {
                        if (response.body().getMessage().equals(getString(R.string.success_status))) {
                            if (response.body().getData().getCOUNTRYCODE() != null) {
                                convertGuestUserModelArrayList.add(response.body());
                                convertGuestUserAdapter.notifyDataSetChanged();
                                recyclerView.invalidate();
                                if (convertGuestUserModelArrayList != null && convertGuestUserModelArrayList.size() == 5) {
                                    orCreateTv.setVisibility(View.GONE);
                                    profileLayout.setVisibility(View.GONE);
                                }
                                new Preference(getApplicationContext()).savePref(Constants.DEVICENAME, "");
                                showDialog(getString(R.string.account_created));
                            }
                        } else
                            showDialog(getString(R.string.already_have_user));
                    } else
                        Toast.makeText(getApplicationContext(), getString(R.string.something_went_wrong), Toast.LENGTH_LONG).show();
                }

                @Override
                public void onFailure(Call<ConvertGuestUserModel> call, Throwable t) {
                    Toast.makeText(getApplicationContext(), getString(R.string.something_went_wrong), Toast.LENGTH_LONG).show();
                }
            });
        } catch (Exception ex) {
            Toast.makeText(getApplicationContext(), getString(R.string.internal_error_occured), Toast.LENGTH_LONG).show();
        }
    }

    private void showDialog(String text) {
        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(this, R.style.MyCustomDialogTheme);
        LayoutInflater inflater = this.getLayoutInflater();
        final View dialogView = inflater.inflate(R.layout.confirm_dialog, null);
        dialogBuilder.setView(dialogView);
        final TextView dialogText = dialogView.findViewById(R.id.top_tv);
        dialogText.setText(text);
        final Button btnYes = dialogView.findViewById(R.id.btnyes);
        btnYes.setText(getString(R.string.ok));
        final Button btnCancel = dialogView.findViewById(R.id.btncancel);
        btnCancel.setVisibility(View.GONE);
        final AlertDialog alertDialog = dialogBuilder.create();
        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                alertDialog.dismiss();
                Intent intent = new Intent(getBaseContext(), Login.class);
                startActivity(intent);
                finish();
            }
        });
        alertDialog.setCancelable(false);
        alertDialog.setCanceledOnTouchOutside(false);
        alertDialog.show();
    }

    void loginwithGoogle() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("Google_userid", googleEmail);
            jsonObject.addProperty("device_serial", getDeviceUniqueId());

            Call<List<GoogleSigninRequest>> call = retrofitNetworkInterface.loginWithGoogleUser(jsonObject);
            call.enqueue(new Callback<List<GoogleSigninRequest>>() {
                @Override
                public void onResponse(Call<List<GoogleSigninRequest>> call, Response<List<GoogleSigninRequest>> response) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            for (GoogleSigninRequest googleSigninRequest : response.body()) {
                                GoogleSigninRequest googleSigninReq = new
                                        GoogleSigninRequest(
                                        googleSigninRequest.getUSERID(),
                                        googleSigninRequest.getUSERNAME(),
                                        googleSigninRequest.getCOUNTRY_CODE(),
                                        googleSigninRequest.getToken(),
                                        false);
                                googleLoginModelArrayList.add(googleSigninReq);
                            }
                            gogUserListAdapter.notifyDataSetChanged();
                            recyclerView.invalidate();
                            if (googleLoginModelArrayList != null && googleLoginModelArrayList.size() >= 5) {
                                orCreateTv.setVisibility(View.GONE);
                                profileLayout.setVisibility(View.GONE);
                            } else {
                                orCreateTv.setVisibility(View.VISIBLE);
                                profileLayout.setVisibility(View.VISIBLE);
                            }
                        } else {
                            orCreateTv.setVisibility(View.VISIBLE);
                            profileLayout.setVisibility(View.VISIBLE);
                        }
                    }
                }

                @Override
                public void onFailure(Call<List<GoogleSigninRequest>> call, Throwable t) {
                    Toast.makeText(LoginFbUser.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(LoginFbUser.this, e.getMessage(), Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

    void loginwithFBUser() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("fb_userid", getIntent().getExtras().getString("fb_userid"));
            jsonObject.addProperty("device_serial", getDeviceUniqueId());
            Call<List<FbUserModel>> call = retrofitNetworkInterface.loginWithFBUser(jsonObject);
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
                                        false);
                                fbUserModelArrayList.add(userModel);
                            }
                            mAdapter.notifyDataSetChanged();
                            recyclerView.invalidate();
                            if (fbUserModelArrayList != null && fbUserModelArrayList.size() >= 5) {
                                orCreateTv.setVisibility(View.GONE);
                                profileLayout.setVisibility(View.GONE);
                            } else {
                                orCreateTv.setVisibility(View.VISIBLE);
                                profileLayout.setVisibility(View.VISIBLE);
                            }
                        } else {
                            orCreateTv.setVisibility(View.VISIBLE);
                            profileLayout.setVisibility(View.VISIBLE);
                        }
                    }
                }

                @Override
                public void onFailure(Call<List<FbUserModel>> call, Throwable t) {
                    Toast.makeText(LoginFbUser.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(LoginFbUser.this, e.getMessage(), Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

    void signIN() {
        if (select_userid.equalsIgnoreCase("")) {
            CommonInterface commonInterface = new CommonInterface() {
                @Override
                public void OnCommonInterface(String response) {
                    if (!response.isEmpty()) {
                        try {
                            String status = new JSONObject(response).getString("status");
                            if (status.toLowerCase().equalsIgnoreCase("success")) {
                                new Preference(getApplicationContext()).savePref(Constants.token,
                                        new JSONObject(response).getString("token"));
                                JSONArray data = new JSONObject(response).getJSONArray("data");
                                for (int i = 0; i < data.length(); i++) {
                                    JSONObject jObj = data.getJSONObject(i);
                                    new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
                                    new Preference(getApplicationContext()).savePref(Constants.USERID,
                                            jObj.getString("USERID"));
                                    new Preference(getApplicationContext()).savePref(Constants.USERNAME,
                                            jObj.getString("USERNAME"));
                                    new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE,
                                            jObj.getString("COUNTRY_CODE"));
                                    new Preference(getApplicationContext()).savePref(Constants.PROFILEIMAGE, profileUrl);
                                    Intent intent1;
                                    if (new Preference(LoginFbUser.this).getPref(Constants.REFFERERUSERID).isEmpty()) {
                                        sessionManager.setLoginTime();
                                        intent1 = new Intent(LoginFbUser.this, ChooseInterestActivity.class);
                                    } else
                                        intent1 = new Intent(LoginFbUser.this, DashBoard.class);
                                    startActivity(intent1);
                                    sessionManager.setLoginTime();
                                    finish();
                                }
                            } else {
                                Toast.makeText(getApplicationContext(), status, Toast.LENGTH_SHORT).show();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    } else {
                        if (!createProfile.getText().toString().trim().isEmpty())
                            Toast.makeText(LoginFbUser.this, R.string.username_exists, Toast.LENGTH_SHORT).show();
                        else
                            Toast.makeText(LoginFbUser.this, R.string.select_one_profile, Toast.LENGTH_SHORT).show();
                    }
                }
            };

            try {
                JSONObject jsonObject = new JSONObject();
                if (!createProfile.getText().toString().equals("")) {
                    if (createProfile.getText().toString().length() > 6)
                        jsonObject.put("username", createProfile.getText().toString());
                    else
                        Toast.makeText(getApplicationContext(), getString(R.string.username_length_check_text), Toast.LENGTH_LONG).show();
                } else
                    jsonObject.put("username", select_username);
                jsonObject.put("country_code", getCountryCode);
                jsonObject.put("fb_username", getIntent().getExtras().getString("fb_username"));
                jsonObject.put("fb_userid", getIntent().getExtras().getString("fb_userid"));
                jsonObject.put("device_serial", getDeviceUniqueId());
                jsonObject.put("dp_url", profileUrl);
                jsonObject.put("tcc", tcc);
                new CommonAsync(LoginFbUser.this, commonInterface, jsonObject).execute(Constants.createFBUser);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
            new Preference(getApplicationContext()).savePref(Constants.USERID, select_userid);
            new Preference(getApplicationContext()).savePref(Constants.USERNAME, select_username);
            new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE, select_countrycode);
            new Preference(getApplicationContext()).savePref(Constants.token, select_token);
            new Preference(getApplicationContext()).savePref(Constants.PROFILEIMAGE, profileUrl);
            Intent intent;
            if (new Preference(LoginFbUser.this).getPref(Constants.NOTIFPOSTID).isEmpty()) {
                intent = new Intent(LoginFbUser.this, DashBoard.class);
                sessionManager.setLoginTime();
            } else
                intent = new Intent(LoginFbUser.this, Comments.class);
            startActivity(intent);
            sessionManager.setLoginTime();
            finish();
        }
    }

    void SignInFacebook() {

        JsonObject jsonObject = new JsonObject();
        if (!createProfile.getText().toString().equals("")) {
            if (createProfile.getText().toString().length() > 6)
                jsonObject.addProperty("username", createProfile.getText().toString());
            else
                Toast.makeText(getApplicationContext(), getString(R.string.username_length_check_text), Toast.LENGTH_LONG).show();
        } else
            jsonObject.addProperty("username", select_username);
        if (getCountryCode != null && !getCountryCode.trim().isEmpty()) {
            jsonObject.addProperty("country_code", getCountryCode);
        } else {
            jsonObject.addProperty("country_code", "GGG");
            Log.w("COUNTRY_CODE", "Fallback country_code used: GGG");
        }

        jsonObject.addProperty("fb_username", getIntent().getExtras().getString("fb_username"));
        jsonObject.addProperty("fb_userid", getIntent().getExtras().getString("fb_userid"));
        jsonObject.addProperty("device_serial", getDeviceUniqueId());
        jsonObject.addProperty("dp_url", profileUrl);
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        Call<GoogleCreateUserModel> call = retrofitNetworkInterface.createFacebookApiCalling(jsonObject);
        call.enqueue(new Callback<GoogleCreateUserModel>() {
            @Override
            public void onResponse(Call<GoogleCreateUserModel> call, Response<GoogleCreateUserModel> response) {
                if (response.code() == 200) {
                    try {
                        String status = response.body().getStatus();
                        if (status.toLowerCase().equalsIgnoreCase("success")) {
                            new Preference(getApplicationContext()).savePref(Constants.token,
                                    response.body().getToken());
                            List<GoogleCreateUserModel.Datum> data = response.body().getData();
                            for (int i = 0; i < data.size(); i++) {
                                new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
                                new Preference(getApplicationContext()).savePref(Constants.USERID,
                                        response.body().getData().get(i).getUSERID());
                                new Preference(getApplicationContext()).savePref(Constants.USERNAME,
                                        response.body().getData().get(i).getUSERNAME());
                                new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE,
                                        response.body().getData().get(i).getCOUNTRYCODE());
                                new Preference(getApplicationContext()).savePref(Constants.PROFILEIMAGE, profileUrl);
                                Intent intent1;
                                if (new Preference(LoginFbUser.this).getPref(Constants.REFFERERUSERID).isEmpty()) {
                                    intent1 = new Intent(LoginFbUser.this, DashBoard.class);
                                    sessionManager.setLoginTime();
                                } else
                                    intent1 = new Intent(LoginFbUser.this, DashBoard.class);
                                startActivity(intent1);
                                sessionManager.setLoginTime();
                                finish();
                            }
                        } else
                            Toast.makeText(LoginFbUser.this, status, Toast.LENGTH_SHORT).show();
                    } catch (Exception e) {
                        Toast.makeText(LoginFbUser.this, R.string.username_exists, Toast.LENGTH_SHORT).show();
                        e.printStackTrace();
                    }
                }
            }

            @Override
            public void onFailure(Call<GoogleCreateUserModel> call, Throwable t) {
                Toast.makeText(LoginFbUser.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
            }
        });

    }

    void logIn() {
        if (select_userid.equalsIgnoreCase("")) {
            CommonInterface commonInterface = new CommonInterface() {
                @Override
                public void OnCommonInterface(String response) {
                    if (!response.isEmpty()) {
                        try {
                            String status = new JSONObject(response).getString("status");
                            if (status.toLowerCase().equalsIgnoreCase("success")) {
                                new Preference(getApplicationContext()).savePref(Constants.token,
                                        new JSONObject(response).getString("token"));
                                JSONArray data = new JSONObject(response).getJSONArray("data");
                                for (int i = 0; i < data.length(); i++) {
                                    JSONObject jObj = data.getJSONObject(i);
                                    new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
                                    new Preference(getApplicationContext()).savePref(Constants.USERID,
                                            jObj.getString("USERID"));
                                    new Preference(getApplicationContext()).savePref(Constants.USERNAME,
                                            jObj.getString("USERNAME"));
                                    new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE,
                                            jObj.getString("COUNTRY_CODE"));
                                    new Preference(getApplicationContext()).savePref(Constants.PROFILEIMAGE, profileUrl);
                                    Intent intent1;
                                    if (new Preference(LoginFbUser.this).getPref(Constants.REFFERERUSERID).isEmpty()) {
                                        intent1 = new Intent(LoginFbUser.this, DashBoard.class);
                                        sessionManager.setLoginTime();
                                    } else
                                        intent1 = new Intent(LoginFbUser.this, DashBoard.class);
                                    startActivity(intent1);
                                    sessionManager.setLoginTime();
                                    finish();
                                }
                            } else
                                Toast.makeText(LoginFbUser.this, status, Toast.LENGTH_SHORT).show();
                        } catch (Exception e) {
                            Toast.makeText(LoginFbUser.this, R.string.username_exists, Toast.LENGTH_SHORT).show();
                            e.printStackTrace();
                        }
                    } else {
                        if (!createProfile.getText().toString().trim().isEmpty())
                            Toast.makeText(LoginFbUser.this, R.string.username_exists, Toast.LENGTH_SHORT).show();
                        else
                            Toast.makeText(LoginFbUser.this, R.string.select_one_profile, Toast.LENGTH_SHORT).show();
                    }
                }
            };

            try {
                JSONObject jsonObject = new JSONObject();
                if (!createProfile.getText().toString().isEmpty()) {
                    if (createProfile.getText().toString().length() > 5)
                        jsonObject.put("username", createProfile.getText().toString());
                    else
                        Toast.makeText(getApplicationContext(), R.string.username_length_check_text, Toast.LENGTH_LONG).show();
                } else
                    jsonObject.put("username", select_username);
                jsonObject.put("country_code", getCountryCode);
                jsonObject.put("fname", fName);
                jsonObject.put("lname", lName);
                jsonObject.put("google_email", googleEmail);
                jsonObject.put("Google_username", googleUsername);
                jsonObject.put("Google_userid", googleUserId);
                jsonObject.put("device_serial", getDeviceUniqueId());
                jsonObject.put("dp_url", profileUrl);
                new CommonAsync(LoginFbUser.this, commonInterface, jsonObject).execute(Constants.createUserGoogle);

            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
            new Preference(getApplicationContext()).savePref(Constants.USERID, select_userid);
            new Preference(getApplicationContext()).savePref(Constants.USERNAME, select_username);
            new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE, select_countrycode);
            new Preference(getApplicationContext()).savePref(Constants.token, select_token);
            new Preference(getApplicationContext()).savePref(Constants.PROFILEIMAGE, profileUrl);
            Intent intent;
            if (new Preference(LoginFbUser.this).getPref(Constants.NOTIFPOSTID).isEmpty()) {
                intent = new Intent(LoginFbUser.this, DashBoard.class);
                sessionManager.setLoginTime();
            } else
                intent = new Intent(LoginFbUser.this, Comments.class);
            startActivity(intent);
            finish();
        }

    }

    private void getGoogleUserApi() {
        fetchCountryCodeFallbackAndThen(() -> {
            JsonObject jsonObject = new JsonObject();
            if (!createProfile.getText().toString().isEmpty()) {
                if (createProfile.getText().toString().length() > 5)
                    jsonObject.addProperty("username", createProfile.getText().toString());
                else
                    Toast.makeText(getApplicationContext(), R.string.username_length_check_text, Toast.LENGTH_LONG).show();
            } else
                jsonObject.addProperty("username", select_username);

            if (getCountryCode != null && !getCountryCode.trim().isEmpty()) {
                jsonObject.addProperty("country_code", getCountryCode);
            } else {
                jsonObject.addProperty("country_code", "GGG");
                Log.w("COUNTRY_CODE", "Fallback country_code used: GGG");
            }

            jsonObject.addProperty("fname", fName);
            jsonObject.addProperty("lname", lName);
            jsonObject.addProperty("google_email", googleEmail);
            jsonObject.addProperty("Google_username", googleUsername);
            jsonObject.addProperty("Google_userid", googleEmail);
            jsonObject.addProperty("device_serial", getDeviceUniqueId());
            jsonObject.addProperty("dp_url", profileUrl);

            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            Call<GoogleCreateUserModel> call = retrofitNetworkInterface.createGoogleApiCalling(jsonObject);
            call.enqueue(new Callback<GoogleCreateUserModel>() {
                @Override
                public void onResponse(Call<GoogleCreateUserModel> call, Response<GoogleCreateUserModel> response) {
                    if (response.code() == 200) {
                        try {
                            String status = response.body().getStatus();
                            if (status.toLowerCase().equalsIgnoreCase("success")) {
                                new Preference(getApplicationContext()).savePref(Constants.token,
                                        response.body().getToken());
                                List<GoogleCreateUserModel.Datum> data = response.body().getData();
                                for (int i = 0; i < data.size(); i++) {
                                    new Preference(getApplicationContext()).saveIntPref(Constants.LOGGEDIN, 1);
                                    new Preference(getApplicationContext()).savePref(Constants.USERID,
                                            response.body().getData().get(i).getUSERID());
                                    new Preference(getApplicationContext()).savePref(Constants.USERNAME,
                                            response.body().getData().get(i).getUSERNAME());
                                    new Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE,
                                            response.body().getData().get(i).getCOUNTRYCODE());
                                    new Preference(getApplicationContext()).savePref(Constants.PROFILEIMAGE, profileUrl);
                                    Intent intent1;
                                    if (new Preference(LoginFbUser.this).getPref(Constants.REFFERERUSERID).isEmpty()) {
                                        intent1 = new Intent(LoginFbUser.this, DashBoard.class);
                                        sessionManager.setLoginTime();
                                    } else
                                        intent1 = new Intent(LoginFbUser.this, DashBoard.class);
                                    startActivity(intent1);
                                    sessionManager.setLoginTime();
                                    finish();
                                }
                            } else
                                Toast.makeText(LoginFbUser.this, status, Toast.LENGTH_SHORT).show();
                        } catch (Exception e) {
                            Toast.makeText(LoginFbUser.this, R.string.username_exists, Toast.LENGTH_SHORT).show();
                            e.printStackTrace();
                        }
                    }
                    if (response.code() == 500) {
                        Toast.makeText(LoginFbUser.this, R.string.username_exists, Toast.LENGTH_SHORT).show();
                    }
                }

                @Override
                public void onFailure(Call<GoogleCreateUserModel> call, Throwable t) {
                    Toast.makeText(LoginFbUser.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        });
    }



    @SuppressLint("HardwareIds")
    public String getDeviceUniqueId() {
        String uniqueId = "";
        try {
            uniqueId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return uniqueId;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.signin:
                if (providerType.equals("com.google")) {
                    if (profileLayout.getVisibility() == View.VISIBLE) {
                        if (createProfile.getText().toString().trim().length() < 6)
                            Toast.makeText(this, getString(R.string.username_length_check_text), Toast.LENGTH_SHORT).show();
                        else
                            TermConditionAlert();
                    } else
                        logIn();
                } else {
                    if (profileLayout.getVisibility() == View.VISIBLE) {
                        if (createProfile.getText().toString().trim().length() < 6)
                            Toast.makeText(this, getString(R.string.username_length_check_text), Toast.LENGTH_SHORT).show();
                        else
                            TermConditionAlert();
                    } else
                        signIN();
                }
                break;

            case R.id.cancel:
                cancel();
                break;
        }
    }

    void cancel() {
        UserUtils.logOutUser(this);
        Intent intent = new Intent(LoginFbUser.this, Login.class);
        startActivity(intent);
        finish();
    }

    // Patch to LoginFbUser.java (only affecting TermConditionAlert method)

    public void TermConditionAlert() {
        // Create an alert builder
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        // set the custom layout
        final View customLayout = getLayoutInflater()
                .inflate(R.layout.term_acceptation, null);
        builder.setView(customLayout);

        TextView text = customLayout.findViewById(R.id.termsandconditionstext);
        text.setText(Html.fromHtml(getResources().getString(R.string.web)));

        builder.setPositiveButton("Agreed",
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (providerType.equals("com.google")) {
                            fetchCountryCodeFallbackAndThen(() -> getGoogleUserApi());
                        } else {
                            SignInFacebook();
                        }
                    }
                });

        builder.setNegativeButton("Disagreed", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                onDisagreedDialog();
            }
        });

        // Create and show the alert dialog
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    void onDisagreedDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("Are you sure want to disagreed ?")
                .setCancelable(false)
                .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        startActivity(new Intent(LoginFbUser.this, Login.class));
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                });
        //Creating dialog box
        AlertDialog alert = builder.create();
        //Setting the title manually
        alert.setTitle("Disagreed");
        alert.show();
    }

    public String convertToAlpha3(String alpha2Code) {
        try {
            Locale locale = new Locale("", alpha2Code);
            return locale.getISO3Country();
        } catch (Exception e) {
            Log.e("COUNTRY_CONVERT", "Invalid alpha2 code: " + alpha2Code);
            return "GGG";
        }
    }

    public void fetchCountryCodeFallbackAndThen(Runnable onReady) {
        RetrofitNetworkInterface api = RetrofitClient.createService(RetrofitNetworkInterface.class);

        api.getIpinJson().enqueue(new Callback<JsonObject>() {
            @Override
            public void onResponse(Call<JsonObject> call, Response<JsonObject> response) {
                if (response.body() != null && response.body().has("ip")) {
                    String ip = response.body().get("ip").getAsString();
                    api.getIpAddressCountryCodeApi(ip).enqueue(new Callback<JsonObject>() {
                        @Override
                        public void onResponse(Call<JsonObject> call, Response<JsonObject> response) {
                            if (response.body() != null && response.body().has("country_code")) {
                                String alpha2 = response.body().get("country_code").getAsString();
                                getCountryCode = convertToAlpha3(alpha2);
                                Log.d("COUNTRY_CODE", "Resolved via IP: " + getCountryCode);
                                tvCountry.setText(getCountryCode);
                            } else {
                                Log.w("COUNTRY_CODE", "Inner response missing 'country_code'");
                                getCountryCode = "HHH";  // fallback
                            }
                            onReady.run();  // run regardless of success/failure
                        }

                        @Override
                        public void onFailure(Call<JsonObject> call, Throwable t) {
                            Log.e("COUNTRY_CODE", "Inner request failed: " + t.getMessage());
                            getCountryCode = "HHH";  // fallback
                            onReady.run();
                        }
                    });
                } else {
                    Log.w("COUNTRY_CODE", "Outer response missing or malformed");
                    getCountryCode = "GGG";  // fallback
                    onReady.run();
                }
            }

            @Override
            public void onFailure(Call<JsonObject> call, Throwable t) {
                Log.e("COUNTRY_CODE", "Outer request failed: " + t.getMessage());
                getCountryCode = "GGG";  // fallback
                onReady.run();
            }
        });
    }

}

