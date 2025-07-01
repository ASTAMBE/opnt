package com.opinito.social.Constants;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Created by 502687702 on 12/27/2016.
 */

public class Preference {
    Context mcontext;
    SharedPreferences sharedPreferences;
    SharedPreferences.Editor editor;

    public Preference(Context context) {
        try {
            mcontext = context;
            sharedPreferences = mcontext.getSharedPreferences(Constants.PREFERENCE, Context.MODE_PRIVATE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String savePref(String key, String value) {
        editor = sharedPreferences.edit();
        editor.putString(key, value);
        editor.commit();

        return null;
    }

    public void saveBooleanPref(String key, boolean value) {
        editor = sharedPreferences.edit();
        editor.putBoolean(key, value);
        editor.commit();
    }

    public boolean getBooleanPref(String key) {
        try {
            return sharedPreferences.getBoolean(key, false);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getPref(String key) {
        try {
            return sharedPreferences.getString(key, "");
        } catch (Exception e) {
            return "";
        }
    }

    public String saveIntPref(String key, int value) {
        editor = sharedPreferences.edit();
        editor.putInt(key, value);
        editor.commit();
        return null;
    }

    public int getIntPref(String key) {
        try {
            return sharedPreferences.getInt(key, 0);
        } catch (Exception e) {
            return 0;
        }
    }

    public String saveLongPref(String key, Long value) {
        editor = sharedPreferences.edit();
        editor.putLong(key, value);
        editor.commit();
        return null;
    }
    public Long getLongPref(String key) {
        try {
            return sharedPreferences.getLong(key, 0);
        } catch (Exception e) {
            return 0L;
        }
    }
}
