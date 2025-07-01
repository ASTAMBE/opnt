package com.opinito.social.Utils;

import static androidx.navigation.fragment.FragmentKt.findNavController;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.text.HtmlCompat;

import com.facebook.login.LoginManager;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.opinito.social.Activity.Comments;
import com.opinito.social.Activity.DashBoard;
import com.opinito.social.Activity.Login;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.ListFragment;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.Fragment.SendPostFragment;
import com.opinito.social.R;

public class UserUtils {

    public static boolean isGuestUser(Context context) {
        if (new Preference(context).getPref(Constants.GUESTUSER).equals(Constants.ONE)) {
            return true;
        } else {
            return false;
        }
    }

    public static void showUserConfirmation(Activity activity, String username, String postId) {
        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(activity, R.style.MyCustomDialogTheme);
        LayoutInflater inflater = activity.getLayoutInflater();
        final View dialogView = inflater.inflate(R.layout.confirm_dialog, null);
        dialogBuilder.setView(dialogView);
        final TextView dialogText = dialogView.findViewById(R.id.top_tv);
        final TextView descText = dialogView.findViewById(R.id.description_tv);
        descText.setVisibility(View.VISIBLE);
        final Button btnYes = dialogView.findViewById(R.id.btnyes);
        btnYes.setText(activity.getString(R.string.ok));
        final Button btnCancel = dialogView.findViewById(R.id.btncancel);
        btnCancel.setText(activity.getString(R.string.cancel));
        final AlertDialog alertDialog = dialogBuilder.create();
        dialogText.setText(activity.getString(R.string.confirmation));
        descText.setText(HtmlCompat.fromHtml(
                String.format(activity.getString(R.string.notloggedinwithuser), username, username),
                HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM));
        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    alertDialog.dismiss();
                    if (postId != null)
                        new Preference(activity).savePref(Constants.NOTIFPOSTID, postId);
                    logOutUser(activity);
                    new Preference(activity).savePref(Constants.USERNAME, "");
                    new Preference(activity).savePref(Constants.PROVIDERTYPE, "");
                    new Preference(activity).savePref(Constants.PROFILEIMAGE, "");
                    Intent intent = new Intent(activity, Login.class);
                    activity.startActivity(intent);
                    activity.finish();
                } catch (Exception e) {
                    e.printStackTrace();
                }
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

    public static void showConfirmation(Activity activity) {
        LayoutInflater factory = LayoutInflater.from(activity);
        final View dialogView = factory.inflate(R.layout.custom_dialog_layout, null);
        dialogView.setElevation(5);
        Button cancelButton = dialogView.findViewById(R.id.cancel_button);
        Button loginbutton = dialogView.findViewById(R.id.login_button);
        final AlertDialog dialog = new AlertDialog.Builder(activity).create();
        dialog.setView(dialogView);
        loginbutton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearPreferences(activity);
                dialog.dismiss();
                Intent intent = new Intent(activity, Login.class);
                activity.startActivity(intent);
                activity.finish();
            }
        });
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
//                    if (((DashBoard) activity).getSelectedTab() == 2)
//                        ((DashBoard) activity).Tabselection(0);
//                    ((DashBoard) activity).resetPostScreen();

                    dialog.dismiss();
                } catch (Exception e) {
                    new Preference(activity).savePref(Constants.SHAREDIMAGEPATH, "");
                    new Preference(activity).savePref(Constants.SHAREDVIDEOPATH, "");
                    new Preference(activity).savePref(Constants.SHAREDTEXT, "");
                    dialog.dismiss();
                    e.printStackTrace();
                }
            }
        });
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
    }

    public static void logOutUser(Activity activity) {
        ListFragment.load = false;
        ProfileFragment.load = false;
        ActivityFragment.refresh = true;
        SendPostFragment.load = false;
        FeedFragment.firstLoad = true;
        FeedFragment.load = false;

        if (new Preference(activity).getPref(Constants.GUESTUSER).equals(Constants.ZERO)) {
            FirebaseAuth.getInstance().signOut();
            GoogleSignInAccount acct = GoogleSignIn.getLastSignedInAccount(activity);
            if (acct != null) {
                GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                        .requestEmail().requestServerAuthCode(activity.getString(R.string.server_client_id))
                        .build();
                GoogleSignInClient mGoogleSignInClient = GoogleSignIn.getClient(activity, gso);
                mGoogleSignInClient.signOut()
                        .addOnCompleteListener(activity, new OnCompleteListener<Void>() {
                            @Override
                            public void onComplete(@NonNull Task<Void> task) {
                                mGoogleSignInClient.revokeAccess()
                                        .addOnCompleteListener(activity, new OnCompleteListener<Void>() {
                                            @Override
                                            public void onComplete(@NonNull Task<Void> task) {
                                                // ...
                                            }
                                        });
                            }
                        });
            }
            if (new Preference(activity).getIntPref(Constants.ISFB) == 1) {
                LoginManager.getInstance().logOut();
            }
        }
        clearPreferences(activity);
    }

    public static void clearRefferalPrefs(Activity activity) {
        new Preference(activity).saveBooleanPref(Constants.ISDEEPLINK, false);
        new Preference(activity).saveIntPref(Constants.DEEPLINKTOPICID, 0);
        new Preference(activity).savePref(Constants.DEEPLINKPOSTID, Constants.ZERO);
        new Preference(activity).savePref(Constants.REFFERERUSERID, "");
        new Preference(activity).savePref(Constants.DEEPLINKUSERNAME, "");
    }

    public static void clearPreferences(Activity activity) {
        new Preference(activity).savePref(Constants.SHAREDIMAGEPATH, "");
        new Preference(activity).savePref(Constants.SHAREDVIDEOPATH, "");
        new Preference(activity).savePref(Constants.SHAREDTEXT, "");
        new Preference(activity).savePref(Constants.USERID, "");
        new Preference(activity).savePref(Constants.COUNTRYCODE, "");
        new Preference(activity).savePref(Constants.token, "");
        new Preference(activity).saveIntPref(Constants.LOGGEDIN, 0);
        new Preference(activity).savePref(Constants.REFFERED, "false");
        new Preference(activity).savePref(Constants.GUESTUSER, Constants.ZERO);
    }
}
