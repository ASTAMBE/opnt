package com.opinito.social.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.res.ColorStateList;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.opinito.social.Adapter.ChatAdapter;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Model.ChatMessage;
import com.opinito.social.R;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.TimeUtils;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.ActivityChatMessagesBinding;
import com.opinito.social.fcmclient.VolleySingleton;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class ChatMessagesActivity extends AppCompatActivity implements View.OnClickListener, View.OnTouchListener {

    private String TAG = ChatMessagesActivity.this.getClass().getSimpleName();
    private ActivityChatMessagesBinding binding;
    private DatabaseReference mFirebaseDatabaseReference;
    private DatabaseReference secondUserDBRef;
    private String chatWithUsername = "";
    private String profileUrl = "";
    final private String FCM_API = "https://fcm.googleapis.com/fcm/send";
    final private String FCM_API_V1 = "https://fcm.googleapis.com/v1/projects/myproject-b5ae1/messages:send";
    final private String serverKey = "key=";
    final private String contentType = "application/json";
    private boolean mRefInitializedtoPath = false;
    private String MESSAGETEXT = "messageText";
    private String MESSAGEBY = "messageBy";
    private String SENTATDTM = "sentAtDTM";
    private String PROFILEURL = "profileUrl";
    private String LASTSENTDTM = "lastsentDTM";
    private List<HashMap<String, String>> dataSnapshotList = new ArrayList<>();
    private ChatAdapter chatAdapter;
    private boolean isBlocked = false;
    private boolean selfBlock = false;
    private final String BLOCKED = "blocked";
    private FirebaseRemoteConfig mFirebaseRemoteConfig;
    private String fcmServerId= "";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityChatMessagesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        init();
    }

    @SuppressLint("ClickableViewAccessibility")
    private void init() {
        chatWithUsername = getIntent().getStringExtra(Constants.USERNAME);
        profileUrl = getIntent().getStringExtra(Constants.PROFILEIMAGE);
        dataSnapshotList.clear();
        Customize.getChatSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
                chatWithUsername, profileUrl);
        binding.blockFromChatText.setText(String.format(getString(R.string.wants_to_send_message), chatWithUsername));
        chatAdapter = new ChatAdapter(dataSnapshotList, this);
        binding.chatRecycler.setAdapter(chatAdapter);
        //firebase database
        firebaseDataHandler();
        mFirebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
        //fcmServerId = mFirebaseRemoteConfig.getString("fcm_server_id");
        fcmServerId = new Preference(ChatMessagesActivity.this).getPref("fcm_server_id");


        //add firebase token
        try {
            FirebaseDatabase.getInstance().getReference()
                    .child(Constants.FCM_TOKEN)
                    .child(new Preference(this).getPref(Constants.USERNAME))
                    .setValue(new Preference(this).getPref(Constants.FCM_TOKEN));
        } catch (Exception e) {
            e.printStackTrace();
        }

        //listeners
        binding.messageBox.setOnTouchListener(this);
        binding.unblockTv.setOnClickListener(this);
        binding.messageBox.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @RequiresApi(api = Build.VERSION_CODES.M)
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.toString().trim().length() > 0) {
                    binding.messageBox.setCompoundDrawableTintList(ColorStateList.valueOf(getResources().getColor(R.color.com_facebook_blue)));
                } else {
                    binding.messageBox.setCompoundDrawableTintList(ColorStateList.valueOf(getResources().getColor(R.color.gray)));
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        binding.nestedScrollerMessages.post(new Runnable() {
            @Override
            public void run() {
                binding.nestedScrollerMessages.fullScroll(View.FOCUS_DOWN);
            }
        });
    }

    private void firebaseDataHandler() {
        try {
            mFirebaseDatabaseReference = FirebaseDatabase.getInstance().getReference()
                    .child("conversations")
                    .child(new Preference(this).getPref(Constants.USERNAME))
                    .child(chatWithUsername);

            secondUserDBRef = FirebaseDatabase.getInstance().getReference()
                    .child("conversations")
                    .child(chatWithUsername)
                    .child(new Preference(this).getPref(Constants.USERNAME));

            mFirebaseDatabaseReference.addChildEventListener(new ChildEventListener() {
                @Override
                public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                    try {
                        if (!snapshot.getKey().equals(BLOCKED)) {
                            isBlocked = false;
                            invalidateOptionsMenu();
                            setUnBlockedView();
                            HashMap<String, String> chatText = new HashMap<>();
                            chatText.put(MESSAGEBY, snapshot.child(MESSAGEBY).getValue().toString());
                            chatText.put(MESSAGETEXT, snapshot.child(MESSAGETEXT).getValue().toString());
                            chatText.put(SENTATDTM, snapshot.child(SENTATDTM).getValue().toString());
                            dataSnapshotList.add(chatText);
                            chatAdapter.notifyDataSetChanged();
                        } else {
                            isBlocked = true;
                            setBlockedView(snapshot);
                            invalidateOptionsMenu();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {

                }

                @Override
                public void onChildRemoved(@NonNull DataSnapshot snapshot) {

                }

                @Override
                public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {

                }

                @Override
                public void onCancelled(@NonNull DatabaseError error) {

                }
            });
            mRefInitializedtoPath = true;
        } catch (Exception e) {
            mRefInitializedtoPath = false;
            mFirebaseDatabaseReference = FirebaseDatabase.getInstance().getReference();
        }
    }

    private void setBlockedView(DataSnapshot snapshot) {
        dataSnapshotList.clear();
        chatAdapter.notifyDataSetChanged();
        binding.chatDisabled.setVisibility(View.VISIBLE);
        binding.nestedScrollerMessages.setVisibility(View.GONE);
        binding.messageBox.setVisibility(View.GONE);
        if (snapshot.getValue().equals(new Preference(ChatMessagesActivity.this).getPref(Constants.USERNAME))) {
            binding.chatDisabled.setText(R.string.user_blocked_by_you);
            selfBlock = true;
            binding.unblockTv.setVisibility(View.VISIBLE);
        } else {
            binding.unblockTv.setVisibility(View.GONE);
            selfBlock = false;
            binding.chatDisabled.setText(R.string.you_have_been_blocked);
        }
    }

    private void setUnBlockedView() {
        binding.chatDisabled.setVisibility(View.GONE);
        binding.nestedScrollerMessages.setVisibility(View.VISIBLE);
        binding.messageBox.setVisibility(View.VISIBLE);
        binding.unblockTv.setVisibility(View.GONE);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.unblock_tv:
                unblockUserFromChat();
                break;
        }
    }

    private void prepareToSendNotif(String title, String message) {
        List<String> regList = new ArrayList<>();
        FirebaseDatabase.getInstance().getReference()
                .child(Constants.FCM_TOKEN).child(chatWithUsername).addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                JSONObject notification = new JSONObject();
                JSONObject notifcationBody = new JSONObject();
                JSONObject dataBody = new JSONObject();
                try {
                    if (snapshot.getValue() != null)
                        regList.add(snapshot.getValue().toString());
                    JSONArray jsonArray = new JSONArray(regList);
                    notifcationBody.put("title", title);
                    notifcationBody.put("body", message);
                    notifcationBody.put("click_action", "OPENCHAT");
                    dataBody.put(Constants.USERNAME, new Preference(ChatMessagesActivity.this).getPref(Constants.USERNAME));
                    dataBody.put(Constants.PROFILEIMAGE, profileUrl);
                    notification.put("registration_ids", jsonArray);
                    notification.put("notification", notifcationBody);
                    notification.put("data", dataBody);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                sendNotificationMessageToUser(notification);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
        //topic must match with what the receiver subscribed to
    }

    private void sendNotificationMessageToUser(JSONObject notification) {
        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(FCM_API, notification,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                    }
                }) {
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String, String> params = new HashMap<>();
                params.put("Authorization", serverKey + fcmServerId);
                params.put("Content-Type", contentType);
                return params;
            }
        };
        VolleySingleton.getInstance(getApplicationContext()).addToRequestQueue(jsonObjectRequest);
    }

    private void sendNotificationMessageToUsers(JSONObject notificationData) {
        try {
            JSONObject messagePayload = new JSONObject();
            JSONObject message = new JSONObject();

            message.put("notification", notificationData);

            message.put("token", "YOUR_TARGET_DEVICE_TOKEN");

            messagePayload.put("message", message);

            String fcmV1ApiUrl = "https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send";

            JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(
                    Request.Method.POST,
                    fcmV1ApiUrl,
                    messagePayload,
                    new Response.Listener<JSONObject>() {
                        @Override
                        public void onResponse(JSONObject response) {
                            // Handle successful response
                            Log.d("FCM", "Notification sent successfully: " + response.toString());
                        }
                    },
                    new Response.ErrorListener() {
                        @Override
                        public void onErrorResponse(VolleyError error) {
                            // Handle error response
                            Log.e("FCM", "Error sending notification: " + error.toString());
                        }
                    }
            ) {
                @Override
                public Map<String, String> getHeaders() throws AuthFailureError {
                    Map<String, String> headers = new HashMap<>();
                    headers.put("Authorization", "Bearer " + getAccessToken());
                    headers.put("Content-Type", "application/json; UTF-8");
                    return headers;
                }
            };

            VolleySingleton.getInstance(getApplicationContext()).addToRequestQueue(jsonObjectRequest);

        } catch (JSONException e) {
            Log.e("FCM", "JSONException occurred: " + e.getMessage());
        }
    }

    private String getAccessToken() {
        return "YOUR_OAUTH2_ACCESS_TOKEN";
    }


    private void unblockUserFromChat() {
        isBlocked = false;
        selfBlock = false;
        binding.chatDisabled.setText(getString(R.string.block_this_user));
        setNullForUsers();
        invalidateOptionsMenu();
        setUnBlockedView();
    }

    private void blockUserFromChat() {
        isBlocked = true;
        binding.chatDisabled.setText(getString(R.string.unblock_this_user));
        invalidateOptionsMenu();
        setNullForUsers();
        mFirebaseDatabaseReference
                .child(BLOCKED)
                .setValue(new Preference(this).getPref(Constants.USERNAME));
        secondUserDBRef.child(BLOCKED)
                .setValue(new Preference(this).getPref(Constants.USERNAME));
        super.onBackPressed();
    }

    private void setNullForUsers(){
        mFirebaseDatabaseReference.setValue(null);
        secondUserDBRef.setValue(null);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_chat, menu);
        MenuItem item = menu.findItem(R.id.block_unblock_item);
        if (selfBlock)
            item.setTitle(getString(R.string.unblock_this_user));
        else
            item.setTitle(getString(R.string.block_this_user));
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.block_unblock_item) {
            if (!binding.chatDisabled.getText().toString().equals(getString(R.string.you_have_been_blocked))) {
                if (item.getTitle().toString().equals(getString(R.string.block_this_user)))
                    blockUserFromChat();
                else
                    unblockUserFromChat();
            } else {
               // item.setEnabled(false);
                blockUserFromChat();
            }
        }
        return super.onOptionsItemSelected(item);
    }
    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if (v.getId() == R.id.message_box) {
            if (UserUtils.isGuestUser(this)) {
                UserUtils.showConfirmation(this);
                binding.messageBox.setEnabled(false);
                return true;
            } else {
                final int DRAWABLE_RIGHT = 2;
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    if (event.getRawX() >= (binding.messageBox.getRight()
                            - binding.messageBox.getCompoundDrawables()[DRAWABLE_RIGHT].getBounds().width())) {
                        try {
                            if (!binding.messageBox.getText().toString().trim().isEmpty()) {
                                DatabaseReference myRef = FirebaseDatabase.getInstance().getReference()
                                        .child("conversations")
                                        .child(new Preference(this).getPref(Constants.USERNAME))
                                        .child(chatWithUsername);
                                myRef.push()
                                        .setValue(new ChatMessage(binding.messageBox.getText().toString(),
                                                new Preference(this).getPref(Constants.USERNAME),
                                                String.valueOf(new TimeUtils().getCureentUTCTime()))
                                        );
                                myRef.child(Constants.PROFILEIMAGE).setValue(profileUrl);
                                myRef.child(LASTSENTDTM).setValue(String.valueOf(new TimeUtils().getCureentUTCTime()));
                                DatabaseReference otherUserRef = FirebaseDatabase.getInstance().getReference()
                                        .child("conversations")
                                        .child(chatWithUsername)
                                        .child(new Preference(this).getPref(Constants.USERNAME));
                                otherUserRef.push()
                                        .setValue(new ChatMessage(binding.messageBox.getText().toString(),
                                                new Preference(this).getPref(Constants.USERNAME),
                                                String.valueOf(new TimeUtils().getCureentUTCTime())));
                                otherUserRef.child(Constants.PROFILEIMAGE).setValue(new Preference(this).getPref(Constants.PROFILEIMAGE));
                                otherUserRef.child(LASTSENTDTM).setValue(String.valueOf(new TimeUtils().getCureentUTCTime()));
                                prepareToSendNotif(getString(R.string.message_from) + new Preference(this).getPref(Constants.USERNAME),
                                        binding.messageBox.getText().toString().trim());
                                if (!mRefInitializedtoPath)
                                    firebaseDataHandler();
                                binding.messageBox.setText("");
                                binding.messageBox.requestFocus();
                                binding.messageBox.setCursorVisible(true);
                                binding.nestedScrollerMessages.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        binding.nestedScrollerMessages.fullScroll(View.FOCUS_DOWN);
                                    }
                                });
                            }
                        } catch (Exception e){
                            e.printStackTrace();
                        }
                        return true;
                    }
                }
                return false;
            }
        }
        return false;
    }

}
