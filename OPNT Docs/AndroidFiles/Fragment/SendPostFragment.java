package com.opinito.social.Fragment;

import android.annotation.TargetApi;
import android.app.Dialog;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.text.HtmlCompat;
import androidx.core.view.MenuItemCompat;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Environment;
import android.os.IBinder;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CenterCrop;
import com.bumptech.glide.load.resource.bitmap.CenterInside;
import com.bumptech.glide.load.resource.bitmap.FitCenter;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.opinito.social.Activity.DashBoard;
import com.opinito.social.Adapter.SendImagesAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.ImageInterface;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.BaseResponse;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.CompressVideo.ChangeInProgress;
import com.opinito.social.Utils.CompressVideo.RxBus;
import com.opinito.social.Utils.CompressVideo.BoundService;
import com.opinito.social.Utils.CompressVideo.VideoCompress;
import com.opinito.social.Utils.CompressVideo.VideoUtils;
import com.opinito.social.Utils.Compressor;
import com.opinito.social.Utils.EmbeddedContent;
import com.opinito.social.Utils.FileUtil;
import com.opinito.social.Utils.SoftKeypad;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static android.app.Activity.RESULT_OK;
import static android.content.Context.BIND_AUTO_CREATE;
import static androidx.navigation.fragment.FragmentKt.findNavController;
import static com.facebook.FacebookSdk.getApplicationContext;
import static com.opinito.social.Utils.UtilsKt.customToolBar;

/**
 * Created by 502687702 on 6/21/2017.
 */

public class SendPostFragment extends Fragment implements ImageInterface, View.OnClickListener {
    private Spinner topicSpinner;
    private EditText comment;
    public static Boolean load = false;
    public static int topicid = 0;
    public static long postid = 0;
    public static String topicdescription = "", sharedText = "";
    public static Object mediaContent = null;
    public static boolean isEdit = false;
    private List<Uri> imagesUri = new ArrayList<>();
    private RecyclerView imageRecycler;
    private SendImagesAdapter sendImagesAdapter;
    private List<MultipartBody.Part> avatar = new ArrayList<>();
    private boolean optionMenuEnabled = false;
    private String POSTTEXT = "";
    private Call<BaseResponse> call;
    private int REQUEST_MULTIPLE_FILES = 1;
    private Dialog mBottomSheetDialog;
    private static final int REQUEST_FOR_VIDEO_FILE = 1000;
    private String destPath = "";
    private View dialogView;
    private RxBus rxBus;
    private BoundService boundService;
    private ProgressBar progressBar;
    private ProgressBar progressSave;
    private TextView attachMediatv;
    private ImageView attachIv;
    private ImageView attachMediaIv;
    private TextView progressBarTv;
    private CompositeDisposable disposables;
    private final String DESTPATH = "destPath";
    private final String INPUTPATH = "inputDest";
    private Boolean isBound = false;
    private Dialog dialog;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.sendpostfragment, container, false);
        customToolBar(requireContext(),false, getString(R.string.create_new_post),((AppCompatActivity)getActivity()).getSupportActionBar());
        initView(view);
        optionMenuEnabled = true;
        setHasOptionsMenu(true);
        return view;
    }


    private void initView(View view) {
        rxBus = new RxBus();
        comment = view.findViewById(R.id.comment);
        disposables = new CompositeDisposable();
        boundService = new BoundService();
        attachIv = view.findViewById(R.id.attach_iv);
        attachIv.setOnClickListener(this);
        DisplayMetrics displayMetrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        attachIv.getLayoutParams().width = displayMetrics.widthPixels / 6;
        attachIv.getLayoutParams().height = displayMetrics.widthPixels / 6;
        attachMediatv = view.findViewById(R.id.attach_media_tv);
        attachMediatv.setOnClickListener(this);
        attachMediaIv = view.findViewById(R.id.attach_media_iv);
        attachMediaIv.setOnClickListener(this);
        progressSave = view.findViewById(R.id.save_progress);
        progressBar = view.findViewById(R.id.progressBar);
        progressBarTv = view.findViewById(R.id.progress_bar_tv);
        imageRecycler = view.findViewById(R.id.image_recycler);
        sendImagesAdapter = new SendImagesAdapter(getActivity(), imagesUri, this, getString(R.string.post));
        imageRecycler.setAdapter(sendImagesAdapter);
        sharedText = new Preference(getApplicationContext()).getPref(Constants.SHAREDTEXT);
        topicSpinner = view.findViewById(R.id.topic_type);
        topicSpinner.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (isEdit) {
                    topicSpinner.setEnabled(false);
                    topicSpinner.setClickable(false);
                }
                return false;
            }
        });

        comment.setHint(HtmlCompat.fromHtml(String.format(getString(R.string.connect_with_likeminded_people),
                new Preference(getActivity()).getPref(Constants.USERNAME)), HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM));
        comment.setOnClickListener(this);
        createBottomsheet();

    }

    public void displayTopics() {
        try {
            comment.setHint(HtmlCompat.fromHtml(String.format(getString(R.string.connect_with_likeminded_people),
                    new Preference(getActivity()).getPref(Constants.USERNAME)), HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM));
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            ArrayList<String> topicsStringArrayList = new ArrayList<>();
            if (UsersDiscussions.topicList != null && UsersDiscussions.topicList.size() > 0) {
                for (int i = 0; i < UsersDiscussions.topicList.size(); i++) {
                    topicsStringArrayList.add(UsersDiscussions.topicList.get(i).getTOPIC());
                }
            }
            topicsStringArrayList.add(0, getString(R.string.choosetopic));
            if (getActivity() != null) {
                ArrayAdapter<String> adapter = new ArrayAdapter<String>(getActivity(), android.R.layout.simple_spinner_item, topicsStringArrayList);
                topicSpinner.setEnabled(true);
                topicSpinner.setClickable(true);
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                topicSpinner.setAdapter(adapter);
                topicSpinner.setSelection(0);
                adapter.notifyDataSetChanged();
            }
            topicSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                    if (parent.getItemAtPosition(position).toString().equals(getString(R.string.choosetopic))) {
 //                       topicid = 0;
                    } else {
                        for (int i = 0; i < UsersDiscussions.topicList.size(); i++) {
                            if (UsersDiscussions.topicList.get(i).getTOPIC().equalsIgnoreCase(parent.getItemAtPosition(position).toString())) {
                                topicid = UsersDiscussions.topicList.get(i).getTOPICID();
                            }
                        }
                    }
                }

                @Override
                public void onNothingSelected(AdapterView<?> parent) {
                }
            });
            if (topicid != 0) {
                for (int i = 0; i < UsersDiscussions.topicList.size(); i++) {
                    if (UsersDiscussions.topicList.get(i).getTOPICID() == topicid) {
                        //set the item at Zero position to the default of the spinner
                        //topicSpinner.setSelection(i);
                    }
                }
                if (!topicdescription.isEmpty())
                    comment.setText(topicdescription);
            }
            if (mediaContent != null) {
                imagesUri.clear();
                List<String> imageList = Arrays.asList(mediaContent.toString().split(","));
                for (int i = 0; i < imageList.size(); i++) {
                    imagesUri.add(Uri.parse(imageList.get(i).trim()));
                    compressFile((FileUtil.from(getActivity(), imagesUri.get(i))));
                }
                mediaContent = null;
                if (imagesUri.size() > 0) {
                    sendImagesAdapter.notifyDataSetChanged();
                    imageRecycler.invalidate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void editComment(long editpostid) {
        postid = editpostid;
        isEdit = postid != 0;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        try {
            FeedFragment.imageOpen = true;
            if (resultCode == RESULT_OK) {
                if (requestCode == REQUEST_FOR_VIDEO_FILE) {
                    if (data != null && data.getData() != null) {
                        File file = new File(getActivity().getExternalFilesDir(Environment.DIRECTORY_MOVIES),
                                System.currentTimeMillis() + "_" + getActivity().getString(R.string.app_name) + ".mp4");
                        long length = (FileUtil.from(getActivity(), data.getData()).length() / 1024) / 1024;
                        if (length > 1000) {
                            Toast.makeText(getContext(), R.string.video_max_size_reached, Toast.LENGTH_SHORT).show();
                        } else {
                            destPath = String.valueOf(file);
                            String inputPath = FileUtil.from(getActivity(), data.getData()).getPath();
                            compressVideo(inputPath, destPath);
                        }
                    }
                } else {
                    if (requestCode == REQUEST_MULTIPLE_FILES) {
                        Uri selectedImageUri;
                        if (data.getClipData() != null) {
                            int count = data.getClipData().getItemCount();
                            if (imagesUri.size() + count <= 4) {
                                for (int i = 0; i < count; i++) {
                                    selectedImageUri = data.getClipData().getItemAt(i).getUri();
                                    compressFile((FileUtil.from(getActivity(), selectedImageUri)));
                                }
                            } else
                                Toast.makeText(getContext(), R.string.upload_4_images_only, Toast.LENGTH_SHORT).show();
                        } else if (data.getData() != null) {
                            selectedImageUri = data.getData();
                            if (imagesUri.size() < 4) {
                                compressFile((FileUtil.from(getActivity(), selectedImageUri)));
                            } else
                                Toast.makeText(getContext(), R.string.upload_4_images_only, Toast.LENGTH_SHORT).show();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private ServiceConnection boundServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            BoundService.MyBinder binderBridge = (BoundService.MyBinder) service;
            boundService = binderBridge.getService();
            rxBus = binderBridge.getRxbus();
            try {
                if (disposables != null) {
                    if (rxBus != null) {
                        disposables.add(rxBus.asFlowable().subscribe(
                                event -> {
                                    if (event instanceof ChangeInProgress) {
                                        progressBar.setProgress((int) ((ChangeInProgress) event).getChange());
                                        if (((ChangeInProgress) event).isCompleted()) {
                                            // video process done.
                                            attachIv.setVisibility(View.VISIBLE);
                                            imageRecycler.setVisibility(View.VISIBLE);
                                            attachMediaIv.setVisibility(View.GONE);
                                            attachMediatv.setVisibility(View.GONE);
                                            progressBar.setVisibility(View.GONE);
                                            progressBarTv.setVisibility(View.GONE);
                                            getActivity().getWindow().clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
                                            File file = new File(destPath);
                                            imagesUri.add(Uri.fromFile(file));
                                            sendImagesAdapter.notifyDataSetChanged();
                                            if (isBound) {
                                                getActivity().unbindService(boundServiceConnection);
                                                isBound = false;
                                            }
                                        }
                                    }
                                }));
                        isBound = true;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            isBound = false;
            boundService = null;
        }
    };

    private void compressVideo(String inputPath, String destPath) {
        try {
            progressBar.setVisibility(View.VISIBLE);
            progressBarTv.setVisibility(View.VISIBLE);
            getActivity().getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
            Intent intent = new Intent(getActivity(), BoundService.class);
            intent.putExtra(DESTPATH, destPath);
            intent.putExtra(INPUTPATH, inputPath);
            getActivity().startService(intent);
            getActivity().bindService(intent, boundServiceConnection, BIND_AUTO_CREATE);
        } catch (Exception e) {
            resetPostHolder();
            Toast.makeText(getActivity(), getString(R.string.couldnt_load_media), Toast.LENGTH_LONG).show();
            e.printStackTrace();
        }
    }

    @Override
    public void onStop() {
        Log.d("Selection","Selection lost from onStop");
        topicSpinner.setSelection(0);
        topicSpinner.setSelection(AdapterView.SCROLLBAR_POSITION_DEFAULT);
        resetPostHolder();
        super.onStop();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d("Selection","Selection lost from Destroy");
        disposables.dispose();
    }


    private void createBottomsheet() {
        ImageView imagePicker, videoPicker;
        dialogView = getLayoutInflater().inflate(R.layout.image_video_picker, null);
        imagePicker = dialogView.findViewById(R.id.select_image_iv);
        imagePicker.setOnClickListener(this);
        videoPicker = dialogView.findViewById(R.id.select_video_iv);
        videoPicker.setOnClickListener(this);
        mBottomSheetDialog = new Dialog(getActivity(),
                R.style.BottomDialogSheet);
        mBottomSheetDialog.setContentView(dialogView);
        mBottomSheetDialog.setCancelable(true);
        mBottomSheetDialog.getWindow().setLayout(LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        mBottomSheetDialog.getWindow().setGravity(Gravity.BOTTOM);
    }

    private void compressFile(File file) {
        try {
            new Compressor(getContext())
                    .compressToFileAsFlowable(file)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new Consumer<File>() {
                        @Override
                        public void accept(File file) {
                            imagesUri.add(Uri.fromFile(file));
                            sendImagesAdapter.notifyDataSetChanged();
                            attachIv.setVisibility(View.VISIBLE);
                            imageRecycler.setVisibility(View.VISIBLE);
                            attachMediaIv.setVisibility(View.GONE);
                            attachMediatv.setVisibility(View.GONE);
                            sendImagesAdapter.notifyDataSetChanged();
                        }
                    }, new Consumer<Throwable>() {
                        @Override
                        public void accept(Throwable throwable) {
                            throwable.printStackTrace();
                        }
                    });
        } catch (Exception e) {
            resetPostHolder();
            Toast.makeText(getActivity(), getString(R.string.couldnt_load_media), Toast.LENGTH_LONG).show();
            e.printStackTrace();
        }
    }

    public void refreshEdit() {
        try {
            if (!sharedText.equals(getString(R.string.sharedtext)))
                comment.setText(sharedText);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void resetPostHolder() {
        Log.d("Selection","Selection lost");
        attachIv.setVisibility(View.GONE);
        imageRecycler.setVisibility(View.GONE);
        attachMediaIv.setVisibility(View.VISIBLE);
        attachMediatv.setVisibility(View.VISIBLE);
        comment.setText("");
        isEdit = false;
        avatar.clear();
        imagesUri.clear();
        mediaContent = null;
        sendImagesAdapter.notifyDataSetChanged();
        topicdescription = "";
        postid = 0;
        sharedText = "";
        topicSpinner.setSelection(0);
        topicSpinner.setSelection(AdapterView.INVALID_POSITION);
        clearSharedPrefs();
    }

    private void clearSharedPrefs() {
        new Preference(getActivity()).savePref(Constants.SHAREDVIDEOPATH, "");
        new Preference(getActivity()).savePref(Constants.SHAREDTEXT, "");
        new Preference(getActivity()).savePref(Constants.SHAREDIMAGEPATH, "");
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        displayTopics();
        preparePost();
    }

    public void preparePost() {
        if (!sharedText.isEmpty()) {
            comment.setText(sharedText);
        } else if (!new Preference(getApplicationContext()).getPref(Constants.SHAREDIMAGEPATH).isEmpty()) {
            try {
                String imagesPath = new Preference(getApplicationContext()).getPref(Constants.SHAREDIMAGEPATH);
                if (!imagesPath.isEmpty()) {
                    List<String> imagesList = Arrays.asList(imagesPath.split(","));
                    for (int i = 0; i < imagesList.size(); i++) {
                        Uri imageUri = Uri.parse(imagesList.get(i).trim());
                        compressFile((FileUtil.from(getActivity(), imageUri)));
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else if (!new Preference(getApplicationContext()).getPref(Constants.SHAREDVIDEOPATH).isEmpty()) {
            String videoPath = new Preference(getApplicationContext()).getPref(Constants.SHAREDVIDEOPATH);
            File file = new File(getActivity().getExternalFilesDir(Environment.DIRECTORY_MOVIES),
                    System.currentTimeMillis() + "_" + getActivity().getString(R.string.app_name) + ".mp4");
            destPath = String.valueOf(file);
            String inputPath = null;
            try {
                File file1 = FileUtil.from(getActivity(), Uri.parse(videoPath));
                try {
                    inputPath = file1.getPath();
                } catch (Exception e) {
                    inputPath = file1.getAbsolutePath();
                }
                compressVideo(inputPath, destPath);
            } catch (Exception e) {
                resetPostHolder();
                Toast.makeText(getActivity(), getString(R.string.couldnt_load_media), Toast.LENGTH_LONG).show();
                e.printStackTrace();
            }
        }
        clearSharedPrefs();
    }

    @Override
    public void onResume() {
        if (!POSTTEXT.isEmpty()) {
            comment.setText(POSTTEXT);
            POSTTEXT = "";
        }
        super.onResume();
    }

    @Override
    public void removeImage(Uri imagePath, int position) {
        try {
            imagesUri.remove(imagePath);
        } catch (Exception e) {
            imagesUri.remove(position);
        }
        if (imagesUri.size() == 0) {
            attachIv.setVisibility(View.GONE);
            imageRecycler.setVisibility(View.GONE);
            attachMediaIv.setVisibility(View.VISIBLE);
            attachMediatv.setVisibility(View.VISIBLE);
        }
        sendImagesAdapter.notifyDataSetChanged();
    }

    @Override
    public void scrollImage(int position) {

    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        getActivity().getMenuInflater().inflate(R.menu.menu_save, menu);
        MenuItem item = menu.findItem(R.id.action_save);
        MenuItemCompat.setActionView(item, R.layout.publish_layout);
        View publishView = MenuItemCompat.getActionView(item);
        publishView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onOptionsItemSelected(menu.findItem(R.id.action_save));
            }
        });

        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public void onPrepareOptionsMenu(Menu menu) {
        menu.findItem(R.id.action_save);
        if (optionMenuEnabled)
            menu.findItem(R.id.action_save).setEnabled(true);
        else
            menu.findItem(R.id.action_save).setEnabled(false);
        super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.action_save) {
            getActivity().invalidateOptionsMenu();
            if (topicid == 0)
                Toast.makeText(getContext(), R.string.please_check_again, Toast.LENGTH_LONG).show();
            else
                saveThePost("Are you sure you want to post this ?");
//                savePost();
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        POSTTEXT = comment.getText().toString();
    }

    private void attachMediaFile(String type) {
        mBottomSheetDialog.dismiss();
        if ((4 - imagesUri.size()) > 0) {
            SendPostFragment.load = false;
            FeedFragment.load = false;
//            ProfileFragment.load = false;
            ActivityFragment.refresh = true;
            ListFragment.load = false;
            if (type.equals(getString(R.string.image))) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
                intent.setType("image/*");
                startActivityForResult(Intent.createChooser(intent, getString(R.string.select_picture)), REQUEST_MULTIPLE_FILES);
                topicSpinner.setSelection(0);
                topicSpinner.setSelection(AdapterView.SCROLLBAR_POSITION_DEFAULT);
            } else {
                Intent intent = new Intent();
                intent.setType("video/*");
                intent.setAction(Intent.ACTION_GET_CONTENT);
                startActivityForResult(intent, REQUEST_FOR_VIDEO_FILE);
                topicSpinner.setSelection(0);
                topicSpinner.setSelection(AdapterView.SCROLLBAR_POSITION_DEFAULT);
            }
            Toast.makeText(getContext(), String.format(getString(R.string.select_images), String.valueOf(4 - imagesUri.size())), Toast.LENGTH_SHORT).show();
        } else
            Toast.makeText(getContext(), R.string.cannot_add_images, Toast.LENGTH_SHORT).show();
    }

    private void progressShow() {
        try {
            progressSave.setVisibility(View.VISIBLE);
            getActivity().getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void progressHide() {
        try {
            progressSave.setVisibility(View.GONE);
            getActivity().getWindow().clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void savePost() {
        dialog.dismiss();
        RequestBody embeddedContent;
        RequestBody embeddedFlag;
        try {
            if (!comment.getText().toString().trim().isEmpty()) {
                //send post API
                progressShow();
                RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
                RequestBody message = RequestBody.create(MediaType.parse("text/plain"), comment.getText().toString()
                        .replaceAll("(?m)(^ *| +(?= |$))", "")
                        .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());
                RequestBody countryCode = RequestBody.create(MediaType.parse("text/plain"),
                        new Preference(getActivity()).getPref(Constants.COUNTRYCODE));
                RequestBody userId = RequestBody.create(MediaType.parse("text/plain"),
                        new Preference(getActivity()).getPref(Constants.USERID));
                if (new EmbeddedContent().getEmbeddedContent(comment.getText().toString().trim()) != null &&
                        !new EmbeddedContent().getEmbeddedContent(comment.getText().toString().trim()).isEmpty()) {
                    embeddedFlag = RequestBody.create(MediaType.parse("text/plain"), getString(R.string.flay_Y));
                    embeddedContent = RequestBody.create(MediaType.parse("text/plain"),
                            new EmbeddedContent().getEmbeddedContent(comment.getText().toString()));
                    Log.d("emb",embeddedContent.toString());
                } else {
                    embeddedFlag = RequestBody.create(MediaType.parse("text/plain"), getString(R.string.flay_N));
                    embeddedContent = RequestBody.create(MediaType.parse("text/plain"), "");
                    Log.d("emb1",embeddedContent.toString());
                }
                if (imagesUri.size() != 0) {
                    for (int i = 0; i < imagesUri.size(); i++) {
                        RequestBody requestFile = RequestBody.create(MediaType.parse("image/*"), FileUtil.from(getActivity(), imagesUri.get(i)));
                        avatar.add(MultipartBody.Part.createFormData("avatar[]",
                                FileUtil.from(getActivity(), imagesUri.get(i)).getName(), requestFile));
                    }
                }
                if (isEdit) {
                    RequestBody postId = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(postid));
                    // call for updating the post
                    call = retrofitNetworkInterface.updatePost
                            (message,
                                    embeddedFlag,
                                    userId,
                                    postId,
                                    avatar,
                                    embeddedContent);
                } else {
                    RequestBody topicId = RequestBody.create(MediaType.parse("text/plain"), String.valueOf(topicid));
                    Map<String, String> header = new HashMap<>();
                    header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
                    header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
                    // call for a new post
                    call = retrofitNetworkInterface.newPost
                            (header, message,
                                    countryCode,
                                    embeddedFlag,
                                    userId,
                                    topicId,
                                    avatar,
                                    embeddedContent);
                }
                call.enqueue(new Callback<BaseResponse>() {
                    @Override
                    public void onResponse(Call<BaseResponse> call, Response<BaseResponse> response) {
                        try {

                            if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                new SoftKeypad().hide(getActivity());
                                progressHide();
                                new Preference(getActivity()).saveIntPref(Constants.TOPICID, topicid);
                                new Preference(getActivity()).saveIntPref(Constants.TOPICCARTID, topicid);
                                resetPostHolder();
                                findNavController(requireParentFragment()).navigate(R.id.action_sendPostFragment_to_usersDiscussions);
                                Toast.makeText(getContext(), R.string.posted_successfully, Toast.LENGTH_LONG).show();
                                dialog.dismiss();
                            } else {
                                progressHide();
                                avatar.clear();
                                Toast.makeText(getContext(), R.string.something_went_wrong, Toast.LENGTH_LONG).show();
                            }
                        }catch (Exception e){e.printStackTrace();}
                    }

                    @Override
                    public void onFailure(Call<BaseResponse> call, Throwable t) {
                        try {
                            progressHide();
                            avatar.clear();
                            Toast.makeText(getContext(), R.string.something_went_wrong, Toast.LENGTH_LONG).show();
                            dialog.dismiss();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
            } else {
                avatar.clear();
                Toast.makeText(getActivity(), R.string.enter_all_fields, Toast.LENGTH_SHORT).show();
            }
        } catch (Exception e) {
            e.printStackTrace();
            progressHide();
            avatar.clear();
            Toast.makeText(getContext(), R.string.internal_error_occured, Toast.LENGTH_LONG).show();
        }
    }

    private void saveThePost(String text) {
        dialog = new Dialog(requireContext());
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.confirm_dialog);

        TextView dialogText = dialog.findViewById(R.id.top_tv);
        dialogText.setText(text);

        Button btnYes = dialog.findViewById(R.id.btnyes);
        TextView title = dialog.findViewById(R.id.app_name_tv);

        if (dialog.getWindow() != null) {
            dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        }

        Button btnCancel = dialog.findViewById(R.id.btncancel);
//        title.setText("Save Interests");
        title.setVisibility(View.VISIBLE);

        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                savePost();
            }
        });

        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });

        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.attach_iv:
            case R.id.attach_media_iv:
            case R.id.attach_media_tv:
                mBottomSheetDialog.show();
                break;

            case R.id.select_image_iv:
                attachMediaFile(getString(R.string.image));
                break;

            case R.id.select_video_iv:
                attachMediaFile(getString(R.string.video));
                break;
        }
    }
}
