package com.opinito.social.Adapter;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Vibrator;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.MimeTypeMap;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.opinito.social.Async.DownloadImageAsync;
import com.opinito.social.Interface.ImageInterface;
import com.opinito.social.R;
import com.opinito.social.ZoomInOutImage;

import java.util.ArrayList;

import static android.content.Context.VIBRATOR_SERVICE;

public class FullScreenImageAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private Activity context;
    private int imagePos;
    private ArrayList<String> images;
    private ImageInterface imageInterface;
    private Vibrator vibrator;
    private RecyclerView recyclerView;

    public FullScreenImageAdapter(Activity context, int imagePos, ArrayList<String> images, ImageInterface imageInterface, RecyclerView recyclerView) {
        this.context = context;
        this.imagePos = imagePos;
        this.images = images;
        this.imageInterface = imageInterface;
        this.recyclerView = recyclerView;
        vibrator = (Vibrator) context.getSystemService(VIBRATOR_SERVICE);
    }

    class FullScreenView extends RecyclerView.ViewHolder implements View.OnClickListener {

        private ImageView imageFullView;
        private ImageView previousArrow;
        private ImageView nextArrow;
        private ImageButton downloadImage;

        public FullScreenView(@NonNull View itemView) {
            super(itemView);
            imageFullView = itemView.findViewById(R.id.full_screen_imageview);
            downloadImage = itemView.findViewById(R.id.download_iv);
            downloadImage.setOnClickListener(this);
            imageFullView.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    ImageView view = (ImageView) v;
                    ZoomInOutImage.viewTransformation(view, event);
                    return true;
                }
            });
            previousArrow = itemView.findViewById(R.id.arrow_previous);
            previousArrow.setOnClickListener(this);
            nextArrow = itemView.findViewById(R.id.arrow_next);
            nextArrow.setOnClickListener(this);
            if (images.size() <= 1){
                nextArrow.setVisibility(View.GONE);
                previousArrow.setVisibility(View.GONE);
            }
        }

        @Override
        public void onClick(View v) {
            switch (v.getId()) {
                case R.id.download_iv:
                    vibrator.vibrate(20);
                    confirmDownload(getAdapterPosition(), context.getString(R.string.image));
                    break;

                case R.id.arrow_previous:
                    if (getAdapterPosition() != 0)
                        imageInterface.scrollImage(getAdapterPosition() - 1);
                    break;

                case R.id.arrow_next:
                    if (getAdapterPosition() != images.size())
                        imageInterface.scrollImage(getAdapterPosition() + 1);
                    break;
            }
        }

    }

    private void confirmDownload(int adapterPosition, String type) {
        androidx.appcompat.app.AlertDialog.Builder dialogBuilder = new androidx.appcompat.app.AlertDialog.Builder(context, R.style.MyCustomDialogTheme);
        LayoutInflater inflater = context.getLayoutInflater();
        final View dialogView = inflater.inflate(R.layout.confirm_dialog, null);
        dialogBuilder.setView(dialogView);
        final TextView dialogText = dialogView.findViewById(R.id.top_tv);
        final TextView descText = dialogView.findViewById(R.id.description_tv);
        descText.setVisibility(View.GONE);
        final Button btnYes = dialogView.findViewById(R.id.btnyes);
        btnYes.setText(context.getString(R.string.positive));
        final Button btnCancel = dialogView.findViewById(R.id.btncancel);
        btnCancel.setText(context.getString(R.string.negative));
        final androidx.appcompat.app.AlertDialog alertDialog = dialogBuilder.create();
        dialogText.setText(String.format(context.getString(R.string.save_image_text), type));
        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
                if (checkPermissionForExternalStorage(context))
                    new DownloadImageAsync(context, type).execute(images.get(adapterPosition));
                else
                    requestPermissionForExternalStorage(context);
            }
        });
        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
            }
        });
        alertDialog.setCancelable(false);
        alertDialog.setCanceledOnTouchOutside(false);
        alertDialog.show();
    }

    class VideoViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private VideoView videoView;
        private ImageView previousArrow;
        private ImageView nextArrow;
        ProgressBar progressBar;
        ImageView loadingImage;
        int first = 0;

        public VideoViewHolder(@NonNull View itemView) {
            super(itemView);
            previousArrow = itemView.findViewById(R.id.arrow_previous);
            previousArrow.setOnClickListener(this);
            nextArrow = itemView.findViewById(R.id.arrow_next);
            nextArrow.setOnClickListener(this);
            loadingImage = itemView.findViewById(R.id.loading_image);
            videoView = itemView.findViewById(R.id.video_view);
            progressBar = itemView.findViewById(R.id.progress_bar_vv);
            if (images.size() <= 1){
                nextArrow.setVisibility(View.GONE);
                previousArrow.setVisibility(View.GONE);
            }
            /*videoView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    vibrator.vibrate(20);
                    confirmDownload(getAdapterPosition(), context.getString(R.string.video));
                    return false;
                }
            });*/
            LinearLayoutManager layoutManager = ((LinearLayoutManager) recyclerView.getLayoutManager());
            recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {

                @Override
                public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                    switch (newState) {
                        case RecyclerView.SCROLL_STATE_IDLE:
                            new Handler().postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    try {
                                        int last = layoutManager.findLastCompletelyVisibleItemPosition();
                                        if (first != last)
                                            if (!videoView.isPlaying())
                                                progressBar.setVisibility(View.VISIBLE);
//                                                loadingImage.setVisibility(View.VISIBLE);
                                    } catch (Exception e) {
                                    }
                                }
                            }, 1000);
                            break;
                        case RecyclerView.SCROLL_STATE_DRAGGING:
                            first = layoutManager.findFirstCompletelyVisibleItemPosition();
                            break;

                    }
                    super.onScrollStateChanged(recyclerView, newState);
                }
            });
        }

        @Override
        public void onClick(View v) {
            switch (v.getId()) {

                case R.id.arrow_previous:
                    if (getAdapterPosition() != 0)
                        imageInterface.scrollImage(getAdapterPosition() - 1);
                    break;

                case R.id.arrow_next:
                    if (getAdapterPosition() != images.size())
                        imageInterface.scrollImage(getAdapterPosition() + 1);
                    break;
            }
        }
    }


    @Override
    public int getItemViewType(int position) {
        if (images.get(position) != null) {
            String extension = getMimeType(images.get(position));
            if (extension != null) {
                if (extension.startsWith(context.getString(R.string.type_image)))
                    return 0;
            } else {
                if (images.get(position).contains(context.getString(R.string.type_video)))
                    return 1;
                else
                    return 0;
            }
        }
        return 1;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case 0:
                return new FullScreenView(LayoutInflater.from(parent.getContext()).inflate(R.layout.fullscreenimage, parent, false));
            case 1:
                return new VideoViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.fullscreenvideo, parent, false));
        }
        return new FullScreenView(LayoutInflater.from(parent.getContext())
                .inflate(R.layout.fullscreenimage, parent, false));
    }

    private static String getMimeType(String fileUrl) {
        String extension = MimeTypeMap.getFileExtensionFromUrl(fileUrl);
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        switch (holder.getItemViewType()) {
            case 0:
                FullScreenView fullScreenView = (FullScreenView) holder;
                Glide.with(context)
                        .load(images.get(position).trim())
                        .error(R.drawable.noimage)
                        .into(fullScreenView.imageFullView);
                break;

            case 1:
                VideoViewHolder videoViewHolder = (VideoViewHolder) holder;
                MediaController mediacontroller = new MediaController(context);
                mediacontroller.setAnchorView(videoViewHolder.videoView);
                videoViewHolder.videoView.setVideoURI(Uri.parse(images.get(position).trim()));
                videoViewHolder.videoView.setMediaController(mediacontroller);
                videoViewHolder.videoView.start();
                Glide.with(context)
                        .load(R.drawable.tenor)
                        .into(videoViewHolder.loadingImage);
//                videoViewHolder.loadingImage.setVisibility(View.VISIBLE);
                videoViewHolder.loadingImage.setVisibility(View.GONE);
                videoViewHolder.progressBar.setVisibility(View.VISIBLE);
                videoViewHolder.videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                    @Override
                    public void onCompletion(MediaPlayer mp) {
                        try {
                            mp.setOnErrorListener(new MediaPlayer.OnErrorListener() {
                                @Override
                                public boolean onError(MediaPlayer mp, int what, int extra) {
                                    return false;
                                }
                            });
                            mp.seekTo(0);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
                videoViewHolder.videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mp) {
                        mp.start();
                        mp.setVolume(10, 10);
                        videoViewHolder.progressBar.setVisibility(View.GONE);
                        videoViewHolder.loadingImage.setVisibility(View.GONE);
                    }
                });
                break;
        }
    }

    @Override
    public int getItemCount() {
        return images.size();
    }

    public static void requestPermissionForExternalStorage(Activity activity) {
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity,
                Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            Toast.makeText(activity,
                    R.string.permission_required,
                    Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(activity,
                    new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                    2000);
        }
    }

    public static boolean checkPermissionForExternalStorage(Activity activity) {
        return ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
    }
}
