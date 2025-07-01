package com.opinito.social.Activity;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;

import com.opinito.social.R;
import com.opinito.social.databinding.ActivityTerminologiesBinding;

public class Terminology extends AppCompatActivity implements View.OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ActivityTerminologiesBinding binding = ActivityTerminologiesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        binding.cancelTerminology.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.cancel_terminology){
            finish();
        }
    }
}
