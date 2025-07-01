package com.opinito.social.code_revamp.network_layer

import android.util.Log
import com.facebook.FacebookSdk.getApplicationContext
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject
import javax.net.ssl.SSLHandshakeException

class AuthInterceptor @Inject constructor() : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val xKey = BuildConfig.APP_ID
        val token = Preference(getApplicationContext()).getPref(Constants.token)
        val request = chain.request().newBuilder()
            .addHeader("Token", token)
            .addHeader("X-ACCESS-KEY", xKey)
            .build()

        try {
            return chain.proceed(request)
        } catch (e: SSLHandshakeException) {
            // Log SSLHandshakeException and handle it gracefully
            Log.e("AuthInterceptor", "SSLHandshakeException occurred: ${e.message}")
            // You can throw a custom exception or handle SSL handshake failure response here
            throw SSLHandshakeException("SSL handshake failed")
        } catch (e: Exception) {
            // Log other exceptions
            Log.e("AuthInterceptor", "Exception occurred: ${e.message}")
            // Handle other exceptions or rethrow them for higher-level handling
            throw e
        }
    }
}
