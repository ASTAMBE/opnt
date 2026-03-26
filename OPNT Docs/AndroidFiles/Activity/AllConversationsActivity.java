package com.opinito.social.Activity;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.opinito.social.Adapter.ChatUsersListAdapter;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Model.ChatUsersListModel;
import com.opinito.social.R;
import com.opinito.social.Utils.Customize;
import com.opinito.social.databinding.ActivityAllConversationsBinding;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.function.Consumer;

public class AllConversationsActivity extends AppCompatActivity {

    private ActivityAllConversationsBinding binding;
    private List<ChatUsersListModel> usersList = new ArrayList<>();
    private ChatUsersListAdapter chatUsersListAdapter;
    private String LASTSENTDTM = "lastsentDTM";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAllConversationsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        init();
    }

    private void init() {
        Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
                getString(R.string.all_conversations), null);
        chatUsersListAdapter = new ChatUsersListAdapter(this, usersList);
        binding.usersListRecycler.setAdapter(chatUsersListAdapter);
        FirebaseDatabase.getInstance().getReference()
                .child("conversations")
                .child(new Preference(this).getPref(Constants.USERNAME))
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            snapshot.getChildren().iterator().forEachRemaining(new Consumer<DataSnapshot>() {
                                @Override
                                public void accept(DataSnapshot dataSnapshot) {
                                    String lastSeenDTM = dataSnapshot.child(LASTSENTDTM).getValue() != null ?
                                            Objects.requireNonNull(dataSnapshot.child(LASTSENTDTM).getValue()).toString() : "";
                                    String profileUrl = dataSnapshot.child(Constants.PROFILEIMAGE).getValue() != null ?
                                            Objects.requireNonNull(dataSnapshot.child(Constants.PROFILEIMAGE).getValue()).toString() : "";
                                    usersList.add(new ChatUsersListModel(dataSnapshot.getKey(),
                                            lastSeenDTM,
                                            profileUrl));
                                }
                            });
                        } else {
                            for (DataSnapshot dataSnapshot : snapshot.getChildren()){
                                String lastSeenDTM = dataSnapshot.child(LASTSENTDTM).getValue() != null ?
                                        Objects.requireNonNull(dataSnapshot.child(LASTSENTDTM).getValue()).toString() : "";
                                String profileUrl = dataSnapshot.child(Constants.PROFILEIMAGE).getValue() != null ?
                                        Objects.requireNonNull(dataSnapshot.child(Constants.PROFILEIMAGE).getValue()).toString() : "";
                                usersList.add(new ChatUsersListModel(dataSnapshot.getKey(),
                                        lastSeenDTM,
                                        profileUrl));
                            }
                        }
                        chatUsersListAdapter.notifyDataSetChanged();
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {

                    }
                });
    }
}
