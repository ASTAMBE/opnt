package com.opinito.social.Activity;

import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;

import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.opinito.social.Adapter.SendImagesAdapter;
import com.opinito.social.Async.CommonAsync;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.Fragment.SendPostFragment;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Interface.ImageInterface;
import com.opinito.social.R;
import com.opinito.social.Utils.EmbeddedContent;
import com.opinito.social.Utils.SoftKeypad;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class EditComment extends AppCompatActivity implements ImageInterface {

    private Spinner topicSpinner;
    private EditText comment;
    private TextView spinnerText;
    private RecyclerView imageRecycler;
    private SendImagesAdapter sendImagesAdapter;
    private List<Uri> imagesUri = new ArrayList<>();
    private static Object mediaContent = null;
    public static int topicid = 0;
    public static String topicdescription = "";
    public static long postid = 0;
    private static final String TOPICID = "topicid";
    private static final String TOPICDESCRIPTION = "topicdescription";
    private static final String POSTID = "postid";
    private static final String MEDIACONTENT = "media_content";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.sendpostfragment);
        init();
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);
        getSupportActionBar().setTitle("");
        displayTopics();
    }

    private void init() {
        topicSpinner = findViewById(R.id.topic_type);
        comment = findViewById(R.id.comment);
        imageRecycler = findViewById(R.id.image_recycler);
        sendImagesAdapter = new SendImagesAdapter(this, imagesUri, this, getString(R.string.post));
        imageRecycler.setAdapter(sendImagesAdapter);
//        spinnerText = findViewById(R.id.spinnerText);
//        spinnerText.setVisibility(View.VISIBLE);
        topicSpinner.setClickable(false);
        mediaContent = getIntent().getExtras().getString(MEDIACONTENT);
        topicdescription = getIntent().getExtras().getString(TOPICDESCRIPTION);
        topicid = getIntent().getExtras().getInt(TOPICID);
        postid = Long.parseLong(getIntent().getExtras().getString(POSTID));
        if (mediaContent != null) {
            imagesUri.clear();
            List<String> imageList = Arrays.asList(mediaContent.toString().split(","));
            for (int i = 0; i < imageList.size(); i++) {
                imagesUri.add(Uri.parse(imageList.get(i).trim()));
                //compressFile((FileUtil.from(getActivity(), imagesUri.get(i))));
            }
            mediaContent = null;
            if (imagesUri.size() > 0) {
                sendImagesAdapter.notifyDataSetChanged();
                imageRecycler.invalidate();
            }
        }
    }

    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }

    public void displayTopics() {
        ArrayList<String> topicsStringArrayList = new ArrayList<>();
        if (FeedFragment.topicsModelArrayList != null && FeedFragment.topicsModelArrayList.size() > 0) {
            for (int i = 0; i < FeedFragment.topicsModelArrayList.size(); i++) {
                topicsStringArrayList.add(FeedFragment.topicsModelArrayList.get(i).getTOPIC());
            }
        }
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(EditComment.this, android.R.layout.simple_list_item_1, topicsStringArrayList);
        topicSpinner.setAdapter(adapter);
        adapter.notifyDataSetChanged();

        topicSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                for (int i = 0; i < FeedFragment.topicsModelArrayList.size(); i++) {
                    if (FeedFragment.topicsModelArrayList.get(i).getTOPIC().equalsIgnoreCase(parent.getItemAtPosition(position).toString())) {
                        topicid = FeedFragment.topicsModelArrayList.get(i).getTOPICID();
                        if (topicid != 0)
                            spinnerText.setVisibility(View.GONE);
                    }
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        if (topicid != 0) {
            for (int i = 0; i < FeedFragment.topicsModelArrayList.size(); i++) {
                if (FeedFragment.topicsModelArrayList.get(i).getTOPICID() == topicid) {
                    topicSpinner.setSelection(i);
                }
            }
            comment.setText(topicdescription);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_save, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        menu.findItem(R.id.action_save).setTitle("Save");
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_save) {
            if (comment.getText().toString().length() > 0) {

                new SoftKeypad().hide(this);

                CommonInterface commonInterface = new CommonInterface() {
                    @Override
                    public void OnCommonInterface(String response) {
                        String status = "";
                        try {
                            status = new JSONObject(response).getString("status");
                            if (status.equalsIgnoreCase(Constants.SUCCESS)) {
                                new Preference(getApplicationContext()).saveIntPref(Constants.TOPICID, topicid);
                                resetPostHolder();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        finish();
                    }
                };
                try {
                    JSONObject postinfoObject = new JSONObject();
                    postinfoObject.put("postid", postid);
                    postinfoObject.put("embedded_flag", "Y");
                    postinfoObject.put("message", comment.getText().toString());
                    postinfoObject.put("embedded_content", new EmbeddedContent().getEmbeddedContent(comment.getText().toString()));

                    JSONObject postobj = new JSONObject();
                    postobj.put("postInfo", postinfoObject);
                    postobj.put("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));

                    new CommonAsync(EditComment.this, commonInterface, postobj).execute(Constants.updatePost);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                Toast.makeText(getApplicationContext(), "Please enter all the fields", Toast.LENGTH_SHORT).show();
            }
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void resetPostHolder() {
        comment.setText("");
    }

    @Override
    public void removeImage(Uri imagePath, int position) {

    }

    @Override
    public void scrollImage(int position) {

    }
}
