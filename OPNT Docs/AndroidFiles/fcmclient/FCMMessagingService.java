package com.opinito.social.fcmclient;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.opinito.social.Activity.ChatMessagesActivity;
import com.opinito.social.Activity.Comments;
import com.opinito.social.Activity.DashBoard;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.R;
import com.opinito.social.Utils.UserUtils;

import java.util.Objects;

/**
 * Created by bhaskar on 10/15/17.
 */

public class FCMMessagingService extends FirebaseMessagingService {

    private static final String POSTID = "postid";
    private static final String channelId = "notification_channel";
    private static final String channelName = "com.opinito.social";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d("messagecamehere",remoteMessage.getMessageId());
//            Log.d("messagecamehere1", remoteMessage.getData().get("sourceId"));
//            Log.d("messagecamehere2", remoteMessage.getData().get("username"));
//            Log.d("messagecamehere3", remoteMessage.getNotification().getClickAction());
       // noti();
//        try{
//            sendNotification( remoteMessage.getNotification().getBody(), remoteMessage.getNotification().getTitle(),remoteMessage.getMessageId();
//
//        }
//        catch (Exception e){
//
//        }
        try {
            if (!UserUtils.isGuestUser(getApplicationContext())) {
                if (new Preference(getApplicationContext()).getBooleanPref(Constants.ISCHATENABLED)) {
                    if (remoteMessage != null) {
                        try {
                            String title = Objects.requireNonNull(remoteMessage.getNotification()).getTitle();
                            String msgBody = Objects.requireNonNull(remoteMessage.getNotification()).getBody();
                            String clickAction = "";
                            try {
                                clickAction = remoteMessage.getNotification().getClickAction();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            Intent intent;
                            if (!Objects.requireNonNull(clickAction).isEmpty()) {
                                if (clickAction.equals("OPENCHAT")) {
                                    intent = new Intent(this, ChatMessagesActivity.class);
                                    intent.putExtra(Constants.PROFILEIMAGE, remoteMessage.getData().get(Constants.PROFILEIMAGE));
                                    intent.putExtra(Constants.USERNAME, remoteMessage.getData().get(Constants.USERNAME));
                                } else if (clickAction.equals("POST")) {
                                    intent = new Intent(this, DashBoard.class);
                                    String topicId = remoteMessage.getData().get("sourceId");
                                    new Preference(getApplicationContext()).saveIntPref(Constants.TOPICID,
                                            Integer.parseInt(Objects.requireNonNull(topicId)));
                                    new Preference(getApplicationContext()).saveIntPref(Constants.TOPICCARTID,
                                            Integer.parseInt(Objects.requireNonNull(topicId)));
                                } else if (clickAction.equals("COMMENT")) {
                                    intent = new Intent(this, Comments.class);
                                    String postId = remoteMessage.getData().get("sourceId");
                                    String username = remoteMessage.getData().get("username");
                                    intent.putExtra(POSTID, username);
                                    intent.putExtra(Constants.USERNAME, postId);
                                } else {
                                    intent = new Intent(this, DashBoard.class);
                                }
                            } else {
                                intent = new Intent(this, DashBoard.class);
                            }
                            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                            PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);
                            NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this);
                            notificationBuilder.setSmallIcon(R.drawable.ic_notif_icon);
                            notificationBuilder.setColor(getResources().getColor(R.color.colorPrimary));
                            notificationBuilder.setContentTitle(title);
                            notificationBuilder.setContentText(msgBody);
                            notificationBuilder.setAutoCancel(true);
                            notificationBuilder.setContentIntent(pendingIntent);
                            NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                            notificationManager.notify(0, notificationBuilder.build());
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                } else {
                    getNormalNotifs(remoteMessage);
                }
            } else {
                getNormalNotifs(remoteMessage);
            }
        }
        catch (Exception exception){

        }

    }
    private void sendNotification(String message, String title,String msg_id) {
        String CHANNEL_ID = "my_channel_01";            // The id of the channel.
        Intent intent = new Intent(this, DashBoard.class);

        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);


        PendingIntent pendingIntent = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            pendingIntent=  PendingIntent.getActivity(getApplicationContext(), 0, intent, PendingIntent.FLAG_IMMUTABLE);
        } else {
            PendingIntent.getActivity(getApplicationContext(), 0, intent, PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);
        }

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, "1")
                .setContentTitle(title)
                .setSmallIcon(R.mipmap.ic_launcher)
//                .setStyle(new NotificationCompat.BigTextStyle()
//                        .bigText(message))
                .setContentText(message)
                .setAutoCancel(true)
                .setChannelId(CHANNEL_ID)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {       // For Oreo and greater than it, we required Notification Channel.
            CharSequence name = "My New Channel";                   // The user-visible name of the channel.
            int importance = NotificationManager.IMPORTANCE_HIGH;

            NotificationChannel channel = new NotificationChannel(CHANNEL_ID,name, importance); //Create Notification Channel
            notificationManager.createNotificationChannel(channel);
        }

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }





    private void getNormalNotifs(RemoteMessage remoteMessage) {
        if (remoteMessage != null) {

                String title = remoteMessage.getNotification().getTitle();
                String msgBody = remoteMessage.getNotification().getBody();
                String clickAction = "";
                try {
                    clickAction = remoteMessage.getNotification().getClickAction();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Intent intent;
                if (clickAction!=null && !clickAction.isEmpty()) {
                    if (clickAction.equals("post")) {
                        intent = new Intent(this, DashBoard.class);
                        new Preference(getApplicationContext()).saveIntPref(Constants.TOPICID,
                                Integer.parseInt(Objects.requireNonNull(remoteMessage.getData().get("sourceId"))));
                        new Preference(getApplicationContext()).saveIntPref(Constants.TOPICCARTID,
                                Integer.parseInt(Objects.requireNonNull(remoteMessage.getData().get("sourceId"))));
                    } else if (clickAction.equals("comment")) {
                        intent = new Intent(this, Comments.class);
                        intent.putExtra(POSTID, remoteMessage.getData().get("sourceId"));
                    } else {
                        intent = new Intent(this, DashBoard.class);
                    }
                } else {
                    intent = new Intent(this, DashBoard.class);
                }
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                PendingIntent pendingIntent = null;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    pendingIntent=  PendingIntent.getActivity(getApplicationContext(), 0, intent, PendingIntent.FLAG_IMMUTABLE);
                } else {
                    PendingIntent.getActivity(getApplicationContext(), 0, intent, PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);
                }



            String CHANNEL_ID = "my_channel_01";            // The id of the channel.
           intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);



            NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, "1")
                    .setContentTitle(title)
                    .setSmallIcon(R.mipmap.ic_launcher)
//                .setStyle(new NotificationCompat.BigTextStyle()
//                        .bigText(message))
                    .setContentText(msgBody)
                    .setAutoCancel(true)
                    .setChannelId(CHANNEL_ID)
                    .setContentIntent(pendingIntent);

            NotificationManager notificationManager =
                    (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {       // For Oreo and greater than it, we required Notification Channel.
                CharSequence name = "My New Channel";                   // The user-visible name of the channel.
                int importance = NotificationManager.IMPORTANCE_HIGH;

                NotificationChannel channel = new NotificationChannel(CHANNEL_ID,name, importance); //Create Notification Channel
                notificationManager.createNotificationChannel(channel);
            }

            notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());







        }
    }

    @Override
    public void onNewToken(@NonNull String token) {
        new Preference(getApplicationContext()).savePref(Constants.FCM_TOKEN, token);
    }
}
