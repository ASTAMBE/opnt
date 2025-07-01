package com.opinito.social.Activity;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.text.Editable;
import android.text.SpannableStringBuilder;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.util.Base64;
import android.util.Log;
import android.util.Patterns;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.core.content.ContextCompat;

import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.google.android.gms.auth.api.identity.BeginSignInRequest;
import com.google.android.gms.auth.api.identity.BeginSignInResult;
import com.google.android.gms.auth.api.identity.Identity;
import com.google.android.gms.auth.api.identity.SignInClient;
import com.google.android.gms.auth.api.identity.SignInCredential;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.snackbar.Snackbar;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.gson.JsonObject;
import com.opinito.social.Async.SignInAsync;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.SendPostFragment;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.CreateGuestLoginModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class Login extends AppCompatActivity implements View.OnClickListener {

    /**
     * Last updated on 3/27/2020 by Ashish
     */
    RelativeLayout facebookLogin, loginwithGuest, googleButton;
    Button loginBtn;
    TextView versionTv, bannerTV;
    TextInputEditText BusernameET, BpasswordET;
    CallbackManager callbackManager;
    TextView termsandconditions;
    private FirebaseAuth mAuth;
    AccessTokenTracker mFacebookAccessTokenTracker;
    GoogleSignInClient mGoogleSignInClient;
    TextView whatisopinito;
    private Thread textUpdateThread;
    int flag = 0;
    ProgressDialog dialog;
    final CharSequence[] countryCodes = {
            "USA", "IND", "GLOBAL"
    };
    private static final int RC_SIGN_IN = 101;
    private boolean connectWithLikeMindedText = true;
    private String selectedString;
    private String trueCountryCode;
    private ProgressDialog pd;
    String IPaddress, validPhoneNumber;
    private SignInClient oneTapClient;
    private BeginSignInRequest signInRequest;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login);
//        continueButton = findViewById(R.id.btn_continue);
//        phone_number = findViewById(R.id.phone_number);
//        phone_number.addTextChangedListener(this);
//        continueButton.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                Intent intent = new Intent(Login.this, OTPActivity.class);
//                intent.putExtra("phoneNumber", validPhoneNumber);
//                startActivity(intent);
//            }
//        });
        //getting ip on main thread
        //   StrictMode.enableDefaults();
//        getDeviceIpAddress();
        getIp();
        progressDialogBar();
        Intent intent = getIntent();
        if (intent != null)
            flag = intent.getIntExtra("flag", 0);
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(getString(R.string.server_client_id))
                .requestEmail()
                .build();
        mGoogleSignInClient = GoogleSignIn.getClient(this, gso);
        mAuth = FirebaseAuth.getInstance();
        mFacebookAccessTokenTracker = new AccessTokenTracker() {
            @Override
            protected void onCurrentAccessTokenChanged(AccessToken oldAccessToken, AccessToken currentAccessToken) {
                // onAccessTokenAvailable(currentAccessToken);
            }
        };
        versionTv = findViewById(R.id.infoVersion);
        termsandconditions = findViewById(R.id.termsandconditions);
        customTCTextView(termsandconditions);
        whatisopinito = findViewById(R.id.whatisopinito);
        googleButton = findViewById(R.id.Google_sign_in_button);
        googleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                googleSignIN();
            }
        });
        FacebookSdk.sdkInitialize(this);
        callbackManager = CallbackManager.Factory.create();
        try {
            PackageInfo pInfo = getApplicationContext().getPackageManager().getPackageInfo(getPackageName(), 0);
            String version = "v" + pInfo.versionName;
            versionTv.setText(version);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        //to generate the KeyHash for Facebook
        try {
            PackageInfo info = getPackageManager().getPackageInfo(
                    getPackageName(),
                    PackageManager.GET_SIGNATURES);
            for (Signature signature : info.signatures) {
                MessageDigest md = MessageDigest.getInstance("SHA");
                md.update(signature.toByteArray());
                Log.d("KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT));
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }

        loginwithGuest = findViewById(R.id.loginwithguest);
        if (new Preference(Login.this).getPref(Constants.CONVERTED).equalsIgnoreCase(Constants.ONE))
            loginwithGuest.setVisibility(View.VISIBLE);
        loginwithGuest.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (new Preference(getApplicationContext()).getPref(Constants.GUESTUSER).equalsIgnoreCase("")
                        || new Preference(getApplicationContext()).getPref(Constants.GUESTUSERCOUNTRY).equalsIgnoreCase("")) {
                    if (!new Preference(Login.this).getBooleanPref(Constants.ISDEEPLINK)) {
//                         AlertDialog.Builder builder = new AlertDialog.Builder(Login.this);
//                        builder.setTitle("Select you country");
//                        builder.setItems(countryCodes, new DialogInterface.OnClickListener() {
//                            public void onClick(DialogInterface dialog, int position) {
//                                 Do something with the selection
//                                String selectedString = String.valueOf(countryCodes[position]);
//                                if (countryCodes[position].equals("GLOBAL")) {
//                                    selectedString = "GGG";
//                                }

                        new Preference(getApplicationContext()).savePref(Constants.GUESTUSERCOUNTRY, selectedString);
                        if (getPhoneName().length() < 8) {
                            GuestLogin(getPhoneName());
                        } else {
                            GuestLogin(getPhoneName().substring(0, 7));
                        }


                    } else {
                        new Preference(Login.this).savePref(Constants.GUESTUSERCOUNTRY,
                                new Preference(Login.this).getPref(Constants.DEEPLINKCOUNTRYCODE));
                        if (getPhoneName().length() < 8) {
                            GuestLogin(getPhoneName());
                        } else {
                            GuestLogin(getPhoneName().substring(0, 7));
                        }
                    }
                } else {
                    if (!new Preference(getApplicationContext()).getPref(Constants.DEVICENAME).equalsIgnoreCase("") ||
                            !new Preference(getApplicationContext()).getPref(Constants.UUID).equalsIgnoreCase("")) {
//                        LoginGuest(new Preference(getApplicationContext()).getPref(Constants.DEVICENAME),
//                                new Preference(getApplicationContext()).getPref(Constants.UUID));
                        if (getPhoneName().length() < 8) {
                            GuestLogin(getPhoneName());
                        } else {
                            GuestLogin(getPhoneName().substring(0, 7));
                        }
                    } else {
                        if (getPhoneName().length() < 8) {
                            GuestLogin(getPhoneName());
                        } else {
                            GuestLogin(getPhoneName().substring(0, 7));
                        }
                    }
                }
            }
        });
        facebookLogin = findViewById(R.id.login_button);
        if (!Constants.DATEOFEXPIRATION.isEmpty()) {
            try {
                if (!getCurrentDate()) {
                    facebookLogin.setEnabled(false);
                    googleButton.setEnabled(false);
                    loginwithGuest.setEnabled(false);
                    Snackbar.make(findViewById(android.R.id.content), getString(R.string.cannot_use_the_app), Snackbar.LENGTH_INDEFINITE)
                            .setAction(getString(R.string.ok), new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {

                                }
                            })
                            .setActionTextColor(ContextCompat.getColor(this, R.color.colorPrimary))
                            .show();
                }
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        facebookLogin.setOnClickListener(this);
        whatisopinito.setOnClickListener(this);
        bannerTV = findViewById(R.id.bannerImageText);
        swapBannerText();
//        bannerTV.setOnClickListener(this);
        View view = getLayoutInflater().inflate(R.layout.bottomsheet_register_user, null);
        BusernameET = view.findViewById(R.id.usernameET);
        BpasswordET = view.findViewById(R.id.passwordET);
        loginBtn = view.findViewById(R.id.loginBtn);
    }

    private String getIp() {
        dialog = ProgressDialog.show(Login.this, "",
                "Loading. Please wait...", true);
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        Call<JsonObject> call = retrofitNetworkInterface.getIpinJson();
        call.enqueue(new Callback<JsonObject>() {

            @Override
            public void onResponse(Call<JsonObject> call, Response<JsonObject> response) {
                if (response.isSuccessful() && response.body() != null) {
                    Log.d("taggy", response.body().get("ip").getAsString());
                    IPaddress = response.body().get("ip").getAsString();

                    getIpAddressApiCalling();

//                 IPaddress= response.body().get("ip");
                } else {
                    Log.d("taggy", "Error in getGenericJson:" + response.code() + " " + response.message());
                }
            }

            @Override
            public void onFailure(Call<JsonObject> call, Throwable t) {
                Log.d("taggy", "Error in getGenericJson:" + t.getCause());

            }
        });
        return IPaddress;
    }

    private void progressDialogBar() {
        pd = new ProgressDialog(Login.this);
        pd.setMessage("Loading");

    }

    private Boolean getCurrentDate() throws ParseException {
        @SuppressLint("SimpleDateFormat") SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        Date currentDate = sdf.parse(sdf.format(new Date()));
        Date enteredDate = sdf.parse(Constants.DATEOFEXPIRATION);
        assert enteredDate != null;
        return enteredDate.after(currentDate);
    }

    private void customTCTextView(TextView view) {
        SpannableStringBuilder spanTxt = new SpannableStringBuilder(
                "By logging in to Opinito, you express your consent to agreement with and understanding of the ");
        spanTxt.append("terms and conditions");
        spanTxt.setSpan(new ClickableSpan() {
            @Override
            public void onClick(View widget) {
                Intent termsIntent = new Intent(Login.this, TermsandConditions.class);
                startActivity(termsIntent);
            }
        }, spanTxt.length() - "terms and conditions".length(), spanTxt.length(), 0);
        spanTxt.append(" and ");
        spanTxt.append("privacy policy");
        spanTxt.setSpan(new ClickableSpan() {
            @Override
            public void onClick(View widget) {
                Intent termsIntent = new Intent(Login.this, TermsandConditions.class);
                termsIntent.putExtra(getString(R.string.privacy_policy), getString(R.string.privacy_policy));
                startActivity(termsIntent);
            }
        }, spanTxt.length() - "privacy policy".length(), spanTxt.length(), 0);
        spanTxt.append(" of Opinito usage and user responsibilities");
        view.setMovementMethod(LinkMovementMethod.getInstance());
        view.setText(spanTxt, TextView.BufferType.SPANNABLE);
    }

    private void swapBannerText() {
        textUpdateThread = new Thread() {
            @Override
            public void run() {
                try {
                    while (!textUpdateThread.isInterrupted()) {
                        Thread.sleep(1500);
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (connectWithLikeMindedText) {
                                    bannerTV.setText(getString(R.string.debate_with_opposites));
                                    connectWithLikeMindedText = false;
                                } else {
                                    bannerTV.setText(getString(R.string.connect_with_nlike_minded_people));
                                    connectWithLikeMindedText = true;
                                }
                            }
                        });
                    }
                } catch (InterruptedException e) {
                }
            }
        };
        textUpdateThread.start();
    }

    public void onGoogleSignInButtonClicked() {
        Intent intent = mGoogleSignInClient.getSignInIntent();
        startActivityForResult(intent, RC_SIGN_IN);
    }

    public void openBottomSheet() {
        View view = getLayoutInflater().inflate(R.layout.bottomsheet_register_user, null);
        BusernameET = view.findViewById(R.id.usernameET);
        BpasswordET = view.findViewById(R.id.passwordET);
        loginBtn = view.findViewById(R.id.loginBtn);
        loginBtn.setOnClickListener(this);
        final Dialog mBottomSheetDialog = new Dialog(this,
                R.style.MaterialDialogSheet);
        mBottomSheetDialog.setContentView(view);
        mBottomSheetDialog.setCancelable(true);
        mBottomSheetDialog.getWindow().setLayout(LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        mBottomSheetDialog.getWindow().setGravity(Gravity.BOTTOM);
        mBottomSheetDialog.show();
    }

    void GraphResult(GoogleSignInAccount account) {
        try {
            AuthCredential credential = GoogleAuthProvider.getCredential(account.getIdToken(), null);
            mAuth.signInWithCredential(credential).addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    if (task.isSuccessful()) {
                        new Preference(getApplicationContext()).savePref(Constants.DEVICENAME, "");
                        new Preference(getApplicationContext()).savePref(Constants.CONVERTED, "1");
                        Intent intent = new Intent(Login.this, LoginFbUser.class);
                        intent.putExtra("providertype", "com.google");
                        intent.putExtra("username", account.getDisplayName());
                        intent.putExtra("fname", account.getGivenName());
                        intent.putExtra("lname", account.getDisplayName());
                        intent.putExtra("google_email", account.getEmail());
                        intent.putExtra("Google_username", account.getDisplayName());
                        //intent.putExtra("Google_userid", account.getId());
                        intent.putExtra("countryCode", selectedString);
                        if (!Uri.EMPTY.equals(account.getPhotoUrl()))
                            intent.setData(account.getPhotoUrl());
                        startActivity(intent);
//                        finish();
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    void GraphResult(AccessToken accessToken, final LoginResult loginResult) {
        AuthCredential credential = FacebookAuthProvider.getCredential(accessToken.getToken());
        mAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            GraphRequest request = GraphRequest.newMeRequest(
                                    accessToken,
                                    new GraphRequest.GraphJSONObjectCallback() {
                                        @Override
                                        public void onCompleted(
                                                JSONObject object,
                                                GraphResponse response) {
                                            // Application code
                                            new Preference(getApplicationContext()).saveIntPref(Constants.ISFB, 1);
                                            try {
                                                new Preference(getApplicationContext()).savePref(Constants.CONVERTED, Constants.ONE);
                                                new Preference(getApplicationContext()).savePref(Constants.DEVICENAME, "");
                                                Intent intent = new Intent(Login.this, LoginFbUser.class);
                                                intent.putExtra("fb_userid", loginResult.getAccessToken().getUserId());
                                                intent.putExtra("fb_username", response.getJSONObject().getString("name"));
                                                intent.putExtra("dp_url", loginResult.getAccessToken().getUserId());
                                                intent.putExtra("providertype", "com.facebook");
                                                intent.putExtra("countryCode", selectedString);
                                                startActivity(intent);
//                                                finish();
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            }
                                        }
                                    });
                            Bundle parameters = new Bundle();
                            parameters.putString("fields", "id,name,first_name,last_name,email,gender");
                            request.setParameters(parameters);
                            request.executeAsync();
                        } else {
                            Toast.makeText(Login.this, "google error", Toast.LENGTH_LONG).show();
                        }
                    }
                });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        callbackManager.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_CANCELED) {
            if (requestCode == RC_SIGN_IN) {
        /*    try {
                SignInCredential credential = oneTapClient.getSignInCredentialFromIntent(data);
                String idToken = credential.getGoogleIdToken();
                String username = credential.getId();
                String password = credential.getPassword();

                new Preference(getApplicationContext()).savePref(Constants.DEVICENAME, "");
                new Preference(getApplicationContext()).savePref(Constants.CONVERTED, "1");
                Intent intent = new Intent(Login.this, LoginFbUser.class);
                intent.putExtra("providertype", "com.google");
                intent.putExtra("username", credential.getDisplayName());
                intent.putExtra("fname", credential.getGivenName());
                intent.putExtra("lname", credential.getDisplayName());
                intent.putExtra("google_email", credential.getId());
                intent.putExtra("Google_username", credential.getDisplayName());
                intent.putExtra("Google_userid", credential.getGoogleIdToken());
                intent.putExtra("countryCode", selectedString);
                if (!Uri.EMPTY.equals(credential.getProfilePictureUri()))
                    intent.setData(credential.getProfilePictureUri());
                startActivity(intent);
                finish();

                if (idToken !=  null) {
                    // Got an ID token from Google. Use it to authenticate
                    // with your backend.
                    Log.d("LoginActivity", "Got ID token.");
                } else if (password != null) {
                    // Got a saved username and password. Use them to authenticate
                    // with your backend.
                    Log.d("LoginActivity", "Got password.");
                }
            } catch (ApiException e) {
                Log.d("LoginActivity", "APIException: "+e.getLocalizedMessage());
            }*/
                SignInCredential googleCredential = null;
                try {
                    googleCredential = oneTapClient.getSignInCredentialFromIntent(data);
                } catch (ApiException e) {
                    e.printStackTrace();
                }
                try {
                    assert googleCredential != null;
                    String idToken = googleCredential.getGoogleIdToken();
                    Log.d("Auth",idToken.toString());
                    if (idToken != null) {
                        // Got an ID token from Google. Use it to authenticate
                        // with Firebase.
                        AuthCredential firebaseCredential = GoogleAuthProvider.getCredential(idToken, null);
                        mAuth.signInWithCredential(firebaseCredential)
                                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                                    @Override
                                    public void onComplete(@NonNull Task<AuthResult> task) {
                                        if (task.isSuccessful()) {
                                            // Sign in success, update UI with the signed-in user's information
                                            FirebaseUser user = mAuth.getCurrentUser();
                                            SignInCredential credential = null;
                                            try {
                                                credential = oneTapClient.getSignInCredentialFromIntent(data);
                                            } catch (ApiException e) {
                                                e.printStackTrace();
                                            }


                                            new Preference(getApplicationContext()).savePref(Constants.DEVICENAME, "");
                                            new Preference(getApplicationContext()).savePref(Constants.CONVERTED, "1");
                                            Intent intent = new Intent(Login.this, LoginFbUser.class);
                                            intent.putExtra("providertype", "com.google");
                                            intent.putExtra("username", credential.getDisplayName());
                                            intent.putExtra("fname", credential.getGivenName());
                                            intent.putExtra("lname", credential.getDisplayName());
                                            intent.putExtra("google_email", credential.getId());
                                            intent.putExtra("Google_username", credential.getDisplayName());
                                            intent.putExtra("Google_userid", user.getUid());
                                            intent.putExtra("countryCode", selectedString);
                                    /*if (!Uri.EMPTY.equals(user.getProfilePictureUri()))
                                        intent.setData(credential.getProfilePictureUri());*/
                                            startActivity(intent);
//                                            finish();

                                        } else {
                                            // If sign in fails, display a message to the user.
                                            Log.w("Loginctivity", "signInWithCredential:failure", task.getException());

                                        }
                                    }
                                });
                    }
                } catch (Exception exception) {
                    exception.printStackTrace();
                }

            }
        }

    }

    /**
     * Do not use a user's email address or user ID to communicate the currently signed-in user to your app's backend server.
     * Instead, send the user's ID token to your backend server and validate the token on the server, or use the server auth code flow.
     */
    private void handleSignInResult(Task<GoogleSignInAccount> completedTask) {
        try {
            GoogleSignInAccount account = completedTask.getResult(ApiException.class);
            GraphResult(account);
        } catch (ApiException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.bannerImageText:
                openBottomSheet();
                break;
            case R.id.login_button:
                //  dialog = ProgressDialog.show(Login.this, "",
                //         "Loading. Please wait...", true);
                LoginManager.getInstance().logInWithReadPermissions(this, Arrays.asList("email", "public_profile", "user_friends"));
                callbackManager = CallbackManager.Factory.create();
                LoginManager.getInstance().registerCallback(callbackManager,
                        new FacebookCallback<LoginResult>() {
                            @Override
                            public void onSuccess(LoginResult loginResult) {
                                dialog.dismiss();
                                Log.d("facebookcheck", "onSuccess: ");
                                GraphResult(loginResult.getAccessToken(), loginResult);
                            }

                            @Override
                            public void onCancel() {
                                dialog.dismiss();


                            }

                            @Override
                            public void onError(@NonNull FacebookException exception) {
                                dialog.dismiss();
                                Log.d("facebookcheck", "onSuccess: " + exception.getMessage());
                                Toast.makeText(getApplicationContext(), "onError: " + exception.getMessage(), Toast.LENGTH_LONG).show();

                            }
                        });
                break;
            case R.id.whatisopinito:
                String url = "https://www.youtube.com/watch?v=VQ2IrFvLJ4Q&feature=youtu.be";
                Intent i = new Intent(Intent.ACTION_VIEW);
                i.setData(Uri.parse(url));
                startActivity(i);
                break;
            case R.id.loginBtn:
                if (BusernameET.getText().toString().isEmpty() || BusernameET.getText().toString().length() < 6) {
                    Toast.makeText(getApplicationContext(), getResources().getString(R.string.invalid_username), Toast.LENGTH_LONG).show();
                } else if (BpasswordET.getText().toString().length() < 6 || BpasswordET.getText().toString().isEmpty()) {
                    Toast.makeText(getApplicationContext(), getResources().getString(R.string.invalid_password), Toast.LENGTH_LONG).show();
                } else {
                    CommonInterface commonInterface = new CommonInterface() {
                        @Override
                        public void OnCommonInterface(String response) {
                            try {
                                String status = new JSONArray(response).getJSONObject(0).getString("USERID");
                                if (!status.isEmpty()) {
                                    Intent intent = new Intent(Login.this, CheckUserAct.class);
                                    startActivity(intent);
                                } else {
                                    Toast.makeText(getApplicationContext(), getString(R.string.something_went_wrong), Toast.LENGTH_LONG).show();
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                Toast.makeText(getApplicationContext(), getString(R.string.internal_error_occured), Toast.LENGTH_LONG).show();
                            }
                        }
                    };
                    new SignInAsync(Login.this, commonInterface).execute(BusernameET.getText().toString(), BpasswordET.getText().toString());
                }
                break;
        }
    }

//    void GuestLogin(String phoneName) {
//        CommonInterface commonInterface = new CommonInterface() {
//            @Override
//            public void OnCommonInterface(String response) {
//                try {
//                    if (!response.isEmpty()) {
//                        if (new JSONObject(response).getString("status").equals(getString(R.string.success_status))) {
//                            new Preference(getApplicationContext()).savePref(Constants.token,
//                                    new JSONObject(response).getString("token"));
//                            String devicename = new JSONObject(response).getJSONArray("data")
//                                    .getJSONObject(0).getString("USERNAME");
//                            String uuid = new JSONObject(response).getJSONArray("data")
//                                    .getJSONObject(0).getString("USER_UUID");
//                            LoginGuest(devicename, uuid);
//                        }
//                    }
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//            }
//        };
//        try {
//            JSONObject jsonObject = new JSONObject();
//            jsonObject.put("devicename", phoneName);
//            jsonObject.put("country_code", new Preference(getApplicationContext()).getPref(Constants.GUESTUSERCOUNTRY));
//            jsonObject.put("device_serial", getDeviceUniqueId());
//            new CommonAsync(Login.this, commonInterface, jsonObject).execute(Constants.createGuestUserApp);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    void GuestLogin(String phoneName) {
        // getIpAddressApiCalling();
        JsonObject json = new JsonObject();
        json.addProperty("devicename", phoneName);
        json.addProperty("country_code", new Preference(getApplicationContext()).getPref(Constants.GUESTUSERCOUNTRY));
        json.addProperty("device_serial", getDeviceUniqueId());
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        Call<CreateGuestLoginModel> call = retrofitNetworkInterface.createGuestApiCalling(json);
        call.enqueue(new Callback<CreateGuestLoginModel>() {
            @Override
            public void onResponse(Call<CreateGuestLoginModel> call, Response<CreateGuestLoginModel> response) {
                if (response.code() == 200 && response.body() != null) {
                    new Preference(getApplicationContext()).savePref(Constants.token,
                            response.body().getToken());
                    String devicename = response.body().getData().get(0).getUSERNAME();
                    new Preference(getApplicationContext()).savePref("DeviceName", devicename);
                    String uuid = response.body().getData().get(0).getUSERUUID();
                    LoginGuest(devicename, uuid);
                } else if (response.code() == 500) {
                    Toast.makeText(Login.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                } else if (response.code() == 404) {
                    Toast.makeText(Login.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<CreateGuestLoginModel> call, Throwable t) {
                Toast.makeText(Login.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
            }
        });
    }
//    void LoginGuest(String devicename, String uuid) {
//        CommonInterface commonInterface = new CommonInterface() {
//            @Override
//            public void OnCommonInterface(String response) {
//                try {
//                    String status = new JSONArray(response).getJSONObject(0).getString("USERID");
//                    if (!status.isEmpty()) {
//                        new Preference(Login.this).saveIntPref(Constants.LOGGEDIN, 1);
//                        new Preference(Login.this).savePref(Constants.USERID, status);
//                        new Preference(Login.this).savePref(Constants.COUNTRYCODE,
//                                new JSONArray(response).getJSONObject(0).getString("COUNTRY_CODE"));
//                        new Preference(getApplicationContext()).saveIntPref(Constants.ISFB, 0);
//                        new Preference(getApplicationContext()).saveIntPref(Constants.TOPICID, 0);
//                        new Preference(getApplicationContext()).saveIntPref(Constants.TOPICCARTID, 0);
//                        new Preference(getApplicationContext()).savePref(Constants.USERNAME, devicename);
//                        new Preference(getApplicationContext()).savePref(Constants.DEVICENAME, devicename);
//                        new Preference(getApplicationContext()).savePref(Constants.UUID, uuid);
//                        new Preference(Login.this).savePref(Constants.GUESTUSER, Constants.ONE);
//                        SendPostFragment.topicid = 0;
//                        Intent intent1;
//                        if (new Preference(Login.this).getIntPref(Constants.isPreviouslyLoggedIn) == 1)
//                            intent1 = new Intent(Login.this, DashBoard.class);
//                        else if (!new Preference(Login.this).getBooleanPref(Constants.ISDEEPLINK))
//                            intent1 = new Intent(Login.this, ChooseInterestActivity.class);
//                        else intent1 = new Intent(Login.this, DashBoard.class);
//                        startActivity(intent1);
//                        finish();
//                    } else {
//                        Toast.makeText(getApplicationContext(), status, Toast.LENGTH_SHORT).show();
//                    }
//                } catch (Exception e) {
//                    e.printStackTrace();
//                    Toast.makeText(getApplicationContext(), "Invalid Login", Toast.LENGTH_SHORT).show();
//                }
//            }
//        };
//        try {
//            JSONObject jsonObject = new JSONObject();
//            jsonObject.put("devicename", devicename);
//            jsonObject.put("userid", uuid);
//            jsonObject.put("device_serial", getDeviceUniqueId());
//            new CommonAsync(Login.this, commonInterface, jsonObject).execute(Constants.loginGuestUserApp);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    void LoginGuest(String devicename, String uuid) {
        JsonObject json = new JsonObject();
        json.addProperty("devicename", devicename);
        json.addProperty("userid", uuid);
        json.addProperty("device_serial", getDeviceUniqueId());

        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        Call<ResponseBody> call = retrofitNetworkInterface.GuestLoginApiCalling(json);
        call.enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                if (response.code() == 200) {
                    try {
                        String status = new JSONArray(response.body().string()).getJSONObject(0).getString("USERID");
                        if (!status.isEmpty()) {
                            new Preference(Login.this).saveIntPref(Constants.LOGGEDIN, 1);
                            new Preference(Login.this).savePref(Constants.USERID, status);
                            new Preference(Login.this).savePref(Constants.COUNTRYCODE, selectedString);
                            new Preference(getApplicationContext()).saveIntPref(Constants.ISFB, 0);
                            new Preference(getApplicationContext()).saveIntPref(Constants.TOPICID, 0);
                            new Preference(getApplicationContext()).saveIntPref(Constants.TOPICCARTID, 0);
                            new Preference(getApplicationContext()).savePref(Constants.USERNAME, devicename);
                            new Preference(getApplicationContext()).savePref(Constants.DEVICENAME, devicename);
                            new Preference(getApplicationContext()).savePref(Constants.UUID, uuid);
                            new Preference(Login.this).savePref(Constants.GUESTUSER, Constants.ONE);
                            Intent intent1;
                            if (new Preference(Login.this).getIntPref(Constants.isPreviouslyLoggedIn) == 1)
                                intent1 = new Intent(Login.this, DashBoard.class);
                            else if (!new Preference(Login.this).getBooleanPref(Constants.ISDEEPLINK))
                                intent1 = new Intent(Login.this, DashBoard.class);
                            else intent1 = new Intent(Login.this, DashBoard.class);
                            startActivity(intent1);
                            finish();
                        } else {
                            Toast.makeText(getApplicationContext(), status, Toast.LENGTH_SHORT).show();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        Toast.makeText(getApplicationContext(), "Invalid Login", Toast.LENGTH_SHORT).show();
                    }

                }
            }

            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                Toast.makeText(Login.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
            }
        });

    }

    @SuppressLint("HardwareIds")
    private String getDeviceUniqueId() {
        String uniqueId = "";
        try {
            uniqueId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return uniqueId;
    }

    public String getPhoneName() {
        String ownerInfo = android.os.Build.MODEL;
        return ownerInfo;
    }

    private String getDeviceIpAddress() {
        URL whatismyip = null;
        try {
            whatismyip = new URL("http://checkip.amazonaws.com");
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        BufferedReader in = null;
        try {
            in = new BufferedReader(new InputStreamReader(
                    whatismyip.openStream()));
            String ip = in.readLine();
            return ip;
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return String.valueOf(whatismyip);
    }

    private void getIpAddressApiCalling() {

        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        Log.d("taggy", IPaddress);
        Call<JsonObject> call = retrofitNetworkInterface.getIpAddressCountryCodeApi(IPaddress);
        call.enqueue(new Callback<JsonObject>() {
            @Override
            public void onResponse(Call<JsonObject> call, Response<JsonObject> response) {
                if (response.code() == 200) {
                    dialog.dismiss();
                    if (response.body() != null) {
                        try {
//                        Log.d("taggy", response.body().get("country_code").getAsString());
                            String userIp = response.body().get("country_code").getAsString();
                            trueCountryCode = response.body().get("country_code").getAsString();
                            selectedString = userIp;
//                        if (userIp.equalsIgnoreCase("IND") || userIp.equalsIgnoreCase("USA")) {
//                            selectedString = userIp;
//
//                        } else {
//                            selectedString = "GGG";
//
//                        }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            }

            @Override
            public void onFailure(Call<JsonObject> call, Throwable t) {
                Toast.makeText(Login.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                dialog.dismiss();
            }
        });
    }

    void googleSignIN() {
        dialog = ProgressDialog.show(Login.this, "",
                "Loading. Please wait...", true);
        oneTapClient = Identity.getSignInClient(this);
        signInRequest = BeginSignInRequest.builder()
                .setGoogleIdTokenRequestOptions(BeginSignInRequest.GoogleIdTokenRequestOptions.builder()
                        .setSupported(true)
                        // Your server's client ID, not your Android client ID.
                        .setServerClientId(getString(R.string.default_web_client_id))
                        .setFilterByAuthorizedAccounts(false)
                        .build())
                .build();


        oneTapClient.beginSignIn(signInRequest)
                .addOnSuccessListener(this, new OnSuccessListener<BeginSignInResult>() {
                    @Override
                    public void onSuccess(BeginSignInResult result) {
                        try {
                            dialog.dismiss();
                            startIntentSenderForResult(
                                    result.getPendingIntent().getIntentSender(), RC_SIGN_IN,
                                    null, 0, 0, 0);
                        } catch (IntentSender.SendIntentException e) {
                            Log.d("LoginActivity", "Couldn't start One Tap UI: " + e.getLocalizedMessage());
                        }
                    }
                })
                .addOnFailureListener(this, new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        dialog.dismiss();
                        // No saved credentials found. Launch the One Tap sign-up flow, or
                        // do nothing and continue presenting the signed-out UI.
                        Log.d("LoginActivity", e.getLocalizedMessage());
                    }
                });

    }

//    @Override
//    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//
//    }
//
//    @Override
//    public void onTextChanged(CharSequence s, int start, int before, int count) {
//
//    }
//
//    @Override
//    public void afterTextChanged(Editable s) {
//        String phoneNumber = s.toString().trim();
//
//        // Validate phone number format using regex
//        boolean isValidPhoneNumber = Patterns.PHONE.matcher(phoneNumber).matches();
//        if (isValidPhoneNumber) {
//            continueButton.setBackground(AppCompatResources.getDrawable(this,R.drawable.button_round_corner));
//            continueButton.setEnabled(true);
//            validPhoneNumber = phoneNumber;
//        } else {
//            continueButton.setBackground(AppCompatResources.getDrawable(this,R.drawable.button_round_gray));
//            continueButton.setEnabled(false);
//            if (!isValidPhoneNumber) {
//                Toast.makeText(this, "Please enter a valid phone number", Toast.LENGTH_SHORT).show();
//            }
//        }
//    }
        /*
        int inputLength = s != null ? s.length() : 0;
        int buttonColor = inputLength == 10 ? R.drawable.button_round_corner : R.drawable.button_round_gray;
        */
}
