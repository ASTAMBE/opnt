package com.opinito.social.Utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.ShortDynamicLink;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.R;

public class DynamicLinksUtil {

    private static final String QUERY_USER_ID = "userId";
    private static final String QUERY_TOPIC_ID = "topicId";
    private static final String QUERY_POST_ID = "postId";
    private static final String QUERY_USERNAME = "username";
    private static final String QUERY_COUNTRY_CODE = "countrycode";
    private static Uri shortli = null;

    public static void createDynamicUri(String topicId,String postId, Context context, String title, String newsURL, String imagePreviewURL) {

        Log.d("DeepLink is =>",topicId+","+postId+","+title+","+newsURL+","+imagePreviewURL);
        Uri builtUri = Uri.parse("https://www.opinito.com")
                .buildUpon()
                .appendQueryParameter(QUERY_TOPIC_ID, topicId )
                .appendQueryParameter(QUERY_POST_ID, postId)
                .appendQueryParameter(QUERY_COUNTRY_CODE, new Preference(context).getPref(Constants.COUNTRYCODE))
                .appendQueryParameter(QUERY_USER_ID, new Preference(context).getPref(Constants.USERID))
                .appendQueryParameter(QUERY_USERNAME, new Preference(context).getPref(Constants.USERNAME))
                .build();
        generateContentLink(builtUri, context, title, newsURL,imagePreviewURL);
    }

    private static void generateContentLink(Uri uri, Context context, String title, String newsURL, String imagePreviewURL) {
        FirebaseDynamicLinks.getInstance()
                .createDynamicLink()
                .setLink(uri)
                .setDomainUriPrefix("https://opinito.page.link")
                .setAndroidParameters(
                        new DynamicLink.AndroidParameters.Builder("com.opinito.social")
                                .build())
                .setIosParameters(
                        new DynamicLink.IosParameters.Builder("com.opinito.dev")
                                .setAppStoreId("1299382443")
                                .build())
                .setSocialMetaTagParameters(
                        new DynamicLink.SocialMetaTagParameters.Builder()
                                .setTitle(title)
                                .setImageUrl(Uri.parse(imagePreviewURL))
                                .setDescription(newsURL)
                                .build())
                .buildShortDynamicLink()
                .addOnCompleteListener((Activity) context, new OnCompleteListener<ShortDynamicLink>() {
                    @Override
                    public void onComplete(@NonNull Task<ShortDynamicLink> task) {
                        if (task.isSuccessful()) {
                            // Short link created
                            shortli = task.getResult().getShortLink();
                            makeIntent(context, shortli);
                        }
                    }
                });
    }

    private static void makeIntent(Context context, Uri uri) {
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_SUBJECT, context.getString(R.string.app_name));
        sendIntent.putExtra(Intent.EXTRA_TEXT, context.getString(R.string.refferal_text) + uri);
        sendIntent.setType("text/plain");
        Intent shareIntent = Intent.createChooser(sendIntent, null);
        context.startActivity(shareIntent);
    }
}
