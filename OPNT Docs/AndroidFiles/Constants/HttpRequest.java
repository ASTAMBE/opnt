package com.opinito.social.Constants;

import android.content.Context;

import com.opinito.social.BuildConfig;

import org.json.JSONObject;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import static com.facebook.FacebookSdk.getApplicationContext;

/**
 * Created by chanti on 12/18/2016.
 */

public class HttpRequest implements Constants {
    Context mContext;
    HttpsURLConnection connection = null;

    public HttpRequest(Context context) {
        mContext = context;
    }

    public String HttpPost(JSONObject jsonObject, String address) {
        String responseString = "";
        try {
            URL url = new URL(address);
            connection = (HttpsURLConnection) url.openConnection();

            connection.setReadTimeout(30000);
            connection.setConnectTimeout(35000);
            connection.setRequestMethod("POST");
            //Dev
            //connection.setRequestProperty("X-ACCESS-KEY", Constants.dev_appid);
            //Production
            connection.setRequestProperty("X-ACCESS-KEY", BuildConfig.APP_ID);
            connection.setRequestProperty("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            connection.setDoInput(true);
            connection.setDoOutput(true);

            OutputStream out = new BufferedOutputStream(connection.getOutputStream());
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(out, StandardCharsets.UTF_8));
            writer.write(jsonObject.toString());

            // Close streams and disconnect.
            writer.close();
            out.close();

            int responsecode = connection.getResponseCode();
            StringBuilder responseStrBuilder = new StringBuilder();
            if (responsecode == HttpsURLConnection.HTTP_OK) {
                String line;
                BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                while ((line = br.readLine()) != null) {
                    responseStrBuilder.append(line);
                }
                responseString = responseStrBuilder.toString();
            } else {
            }
            connection.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return responseString;
    }

    public String HttpGet(String address) {
        String responseString = "";
        HttpURLConnection connection = null;
        try {
            URL obj = new URL(address);
            connection = (HttpURLConnection) obj.openConnection();

            // optional default is GET
            connection.setRequestMethod("GET");
            //connection.setConnectTimeout(20000);

            //add request header
            //Prod Access API KEY
            //connection.setRequestProperty("x-api-key","J.4O8SGQFNM%ZJR't8wX99y5a=X0/F");
            //Dev Access API KEY
            connection.setRequestProperty("x-api-key", "yjnX5DWi1yKAlKmi2JU28RXVRg15vwffaID70w4o");
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Accept", "application/json");

            int responsecode = connection.getResponseCode();
            StringBuilder responseStrBuilder = new StringBuilder();
            if (responsecode == HttpURLConnection.HTTP_OK) {
                String line;
                BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                while ((line = br.readLine()) != null) {
                    responseStrBuilder.append(line);
                }
                responseString = responseStrBuilder.toString();
            } else {
            }
            connection.disconnect();

        } catch (Exception e) {
            e.printStackTrace();
            responseString = e.getMessage();
        }

        return responseString;
    }
}