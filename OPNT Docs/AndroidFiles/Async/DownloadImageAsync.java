package com.opinito.social.Async;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Environment;
import android.os.Handler;
import android.provider.MediaStore;
import android.util.Log;
import android.widget.Toast;

import com.opinito.social.R;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URLConnection;

public class DownloadImageAsync extends AsyncTask<String, Integer, String> {
    private String TAG = "DownloadImage";
    @SuppressLint("StaticFieldLeak")
    private Context context;
    private ProgressDialog mProgressDialog;
    private int fileLength = 0;
    private String status;
    private InputStream input;
    private String type;
    private final int TIMEOUT_CONNECTION = 5000;//5sec
    private final int TIMEOUT_SOCKET = 30000;//30sec

    public DownloadImageAsync(Context context, String type) {
        this.context = context;
        this.type = type;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
        final DownloadImageAsync imageAsync = this;
        mProgressDialog = new ProgressDialog(context);
        mProgressDialog.setMessage(context.getString(R.string.downloading));
        mProgressDialog.setIndeterminate(true);
        mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
        mProgressDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                imageAsync.cancel(true);
                Toast.makeText(context, context.getString(R.string.download_failed), Toast.LENGTH_SHORT).show();
            }
        });
        mProgressDialog.show();
    }

    private String downloadImageBitmap(String sUrl) {
        if (type.equals(context.getString(R.string.image))) {
            try {
                java.net.URL url = new java.net.URL(sUrl.trim());
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setDoInput(true);
                connection.connect();
                fileLength = connection.getContentLength();
                input = connection.getInputStream();
                Bitmap bitmap = BitmapFactory.decodeStream(input);
                input = new BufferedInputStream(url.openStream());
                status = saveImage(context
                        , bitmap
                        , System.currentTimeMillis() + "_" + context.getString(R.string.app_name));
                if (input != null)
                    input.close();
                if (connection != null)
                    connection.disconnect();
            } catch (Exception e) {
                Log.d(TAG, "Exception 1, Something went wrong!");
                e.printStackTrace();
            }
        } else {
            try {
                java.net.URL url = new java.net.URL(sUrl.trim()); //you can write here any link
                File file = new File(context.getExternalFilesDir(Environment.DIRECTORY_MOVIES), System.currentTimeMillis() + ".mp4");
                /* Open a connection to that URL. */
                URLConnection ucon = url.openConnection();
                fileLength = ucon.getContentLength();
                /*
                 * Define InputStreams to read from the URLConnection.
                 */
                ucon.setReadTimeout(TIMEOUT_CONNECTION);
                ucon.setConnectTimeout(TIMEOUT_SOCKET);

                //Define InputStreams to read from the URLConnection.
                // uses 3KB download buffer
                InputStream is = ucon.getInputStream();
                BufferedInputStream inStream = new BufferedInputStream(is, 1024 * 5);
                FileOutputStream outStream = new FileOutputStream(file);
                byte[] buff = new byte[5 * 1024];
                long total = 0;
                //Read bytes (and store them) until there is nothing more to read(-1)
                int len;
                while ((len = inStream.read(buff)) != -1) {
                    total += len;
                    if (fileLength > 0)
                        publishProgress((int) (total * 100 / fileLength));
                    outStream.write(buff, 0, len);
                }

                //clean up
                outStream.flush();
                outStream.close();
                inStream.close();
                status = context.getString(R.string.downloaded_success);

            } catch (MalformedURLException e) {
                status = context.getString(R.string.download_failed);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return status;
    }

    @Override
    protected String doInBackground(String... params) {
        return downloadImageBitmap(params[0]);
    }

    protected void onPostExecute(String result) {
        mProgressDialog.setMessage(result);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                mProgressDialog.dismiss();
            }
        }, 1000);
    }

    @Override
    protected void onProgressUpdate(Integer... values) {
        super.onProgressUpdate(values);
        mProgressDialog.setIndeterminate(false);
        mProgressDialog.setMax(100);
        mProgressDialog.setProgress(values[0]);
    }

    private String saveImage(Context context, Bitmap b, String imageName) {
        String stored = context.getString(R.string.download_failed);
        File file = new File(context.getExternalFilesDir(Environment.DIRECTORY_PICTURES), imageName + ".jpg");
        if (file.exists())
            return stored;
        try {
            FileOutputStream out = new FileOutputStream(file);
            b.compress(Bitmap.CompressFormat.JPEG, 100, out);
            byte[] data = new byte[1024];
            long total = 0;
            int count;
            while ((count = input.read(data)) != -1) {
                total += count;
                if (fileLength > 0)
                    publishProgress((int) (total * 100 / fileLength));
                out.write(data, 0, count);
            }
            out.flush();
            out.close();
            stored = context.getString(R.string.downloaded_success);
            //to send the broadcast to the gallery
            MediaStore.Images.Media.insertImage(context.getContentResolver(),file.getAbsolutePath(),file.getName(),file.getName());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stored;
    }
}