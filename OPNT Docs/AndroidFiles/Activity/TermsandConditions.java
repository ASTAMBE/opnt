package com.opinito.social.Activity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.opinito.social.R;
import com.opinito.social.Utils.Customize;

import java.util.Objects;

/**
 * Created by 488222L on 1/25/2018.
 */

public class TermsandConditions extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_termsandcondition);
        TextView termsandcondtions = findViewById(R.id.termsandconditionstext);
        TextView email = findViewById(R.id.email);
        if (getIntent().getStringExtra(getString(R.string.privacy_policy)) != null) {
            Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
                    getString(R.string.privacy_policy), null);
            termsandcondtions.setText(Html.fromHtml(getResources().getString(R.string.privacy_text)));
            email.setVisibility(View.VISIBLE);
        } else {
            email.setVisibility(View.GONE);
            Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
                    getString(R.string.terms_and_conditions), null);
            termsandcondtions.setText(Html.fromHtml(getResources().getString(R.string.web)));
        }
        email.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_SENDTO);
                intent.setData(Uri.parse("mailto:"));
                intent.putExtra(Intent.EXTRA_EMAIL, new String[]{"ast.common@gmail.com"});
                if (intent.resolveActivity(getPackageManager()) != null) {
                    startActivity(intent);
                } else {
                    Toast.makeText(getApplicationContext(), "No email app found", Toast.LENGTH_SHORT).show();
                }

            }
        });
    }

    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}
