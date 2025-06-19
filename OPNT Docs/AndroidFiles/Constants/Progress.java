package com.opinito.social.Constants;

import android.app.ProgressDialog;
import android.content.Context;
import android.util.Log;

/**
 * Created by puppalapati on 05-09-2015.
 */

/**
 * Last updated on 3/27/2020 by Ashish
 * */
public class Progress {

    ProgressDialog progress;
    public Progress(Context context){
        progress = new ProgressDialog(context);
        progress.setMessage("Loading..");
        progress.setCancelable(false);
        progress.setIndeterminate(true);
        progress.show();
    }

    public void ProgressDismiss(){
        try{
                progress.dismiss();
        }
        catch (Exception ex){
        }
    }
}
