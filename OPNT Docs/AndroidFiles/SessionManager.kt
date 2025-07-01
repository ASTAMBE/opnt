package com.opinito.social

import android.content.Context
import android.util.Log
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date

class SessionManager(private val context: Context) {

    fun setLoginTime() {
        Preference(context).saveLongPref(
            Constants.KEY_LOGIN_TIME,
            Calendar.getInstance().timeInMillis
        )
        val timestamp = Preference(context).getLongPref(Constants.KEY_LOGIN_TIME)
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val readableDate = sdf.format(Date(timestamp))
        Log.d(
            "Login_time", readableDate
        )
    }

    fun isSessionExpired(): Boolean {
        val loginTime = Preference(context).getLongPref(Constants.KEY_LOGIN_TIME)
        val currentTime = Calendar.getInstance().timeInMillis
        val elapsedTime = currentTime - loginTime
        return elapsedTime > (10 * 24 * 60 * 60 * 1000) // 10 Days
//        return elapsedTime > (1 * 60 * 1000) // 1 minute
    }

    fun clearSession() {
        Preference(context).saveIntPref(Constants.KEY_LOGIN_TIME, 0)
    }
}
