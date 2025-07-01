package com.opinito.social.Activity;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.ItemTouchHelper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.LinearSnapHelper;
import androidx.recyclerview.widget.RecyclerView;
import android.content.Intent;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import com.opinito.social.Adapter.FullScreenImageAdapter;
import com.opinito.social.Interface.ImageInterface;
import com.opinito.social.R;
import com.opinito.social.Utils.RecyclerUtils;

import java.util.ArrayList;

public class FullScreenImageActivity extends AppCompatActivity implements View.OnClickListener, ImageInterface {

    private ImageView backArrow;
    private RecyclerView recyclerView;
    private ArrayList<String> imagesList = new ArrayList<>();
    private int imagePos;
    private String IMAGELIST = "imageslist";
    private String IMAGEPOSITION = "imagePosition";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_full_screen_image);
        backArrow = findViewById(R.id.back_arrow);
        recyclerView = findViewById(R.id.recyler_fullimage);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this){
            @Override
            public boolean canScrollHorizontally() {
                return false;
            }

            @Override
            public boolean canScrollVertically() {
                return false;
            }
        };
        recyclerView.setLayoutManager(linearLayoutManager);
        backArrow.setOnClickListener(this);
        Intent callingActivityIntent = getIntent();
        if (callingActivityIntent != null) {
            imagesList = callingActivityIntent.getStringArrayListExtra(IMAGELIST);
            imagePos = callingActivityIntent.getIntExtra(IMAGEPOSITION, 0);
            FullScreenImageAdapter fullScreenImageAdapter = new FullScreenImageAdapter
                    (FullScreenImageActivity.this,
                            imagePos,
                            imagesList,
                            this,
                            recyclerView);
            recyclerView.setAdapter(fullScreenImageAdapter);
            fullScreenImageAdapter.notifyDataSetChanged();
            recyclerView.invalidate();
            recyclerView.scrollToPosition(imagePos);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.back_arrow:
                super.onBackPressed();
                break;
        }
    }

    @Override
    public void removeImage(Uri imagePath, int position) {
    }

    @Override
    public void scrollImage(int position) {
        recyclerView.scrollToPosition(position);
    }
}
