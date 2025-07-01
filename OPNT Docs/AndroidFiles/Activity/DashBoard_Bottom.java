package com.opinito.social.Activity;

import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import androidx.appcompat.app.AppCompatActivity;
import android.view.MenuItem;

import com.opinito.social.R;
/**
 * Created by 502687702 on 6/21/2017.
 */

public class DashBoard_Bottom extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bottom);

        BottomNavigationView bottomNavigationView = findViewById(R.id.bottom_navigation);

        bottomNavigationView.setOnNavigationItemSelectedListener(
                new BottomNavigationView.OnNavigationItemSelectedListener() {
                    @Override
                    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                        switch (item.getItemId()) {
                            case R.id.action_feeds:
                                break;

//                            case R.id.action_list:
//                                break;

                            /*case R.id.action_profile:
                                break;*/

                            case R.id.action_send:
                                break;

                        }
                        return true;
                    }
                });
    }
}
