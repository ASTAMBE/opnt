package com.opinito.social.code_revamp.repository

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.facebook.FacebookSdk
import com.facebook.FacebookSdk.getApplicationContext
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.code_revamp.models.suggest_kw.SuggestKWRequest
import com.opinito.social.code_revamp.models.suggest_kw.SuggestKWResponse
import com.opinito.social.code_revamp.models.user_interests.request.UserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.response.UserInterestsResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.network_layer.UserAPI
import retrofit2.Response
import javax.inject.Inject

class MainRepository @Inject constructor(private val userAPI: UserAPI) {

    val xKey = BuildConfig.APP_ID
    val token = Preference(getApplicationContext()).getPref(Constants.token)

    private val _suggestKWResponseLiveData = MutableLiveData<NetworkResult<ShowFreshContentResponse>>()
    val suggestKWResponseLiveData: LiveData<NetworkResult<ShowFreshContentResponse>>
        get() = _suggestKWResponseLiveData

    private val _userInterestsResponseLiveData =
        MutableLiveData<NetworkResult<UserInterestsResponse>>()
    val userInterestsResponseLiveData: LiveData<NetworkResult<UserInterestsResponse>>
        get() = _userInterestsResponseLiveData

    suspend fun getKeywords(showFreshContentRequest: ShowFreshContentRequest) {
        try {
            _suggestKWResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.showFreshContent(token, xKey, showFreshContentRequest)
            handleSuggestKWREsponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleSuggestKWREsponse(response: Response<ShowFreshContentResponse>) {

        if (response.isSuccessful && response.body() != null) {
            Log.d("data","running mainrepo")
            _suggestKWResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _suggestKWResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _suggestKWResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    suspend fun getUserInterests(userRequest: UserInterestsRequest) {
        try {
            _userInterestsResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.userInterests(token, xKey, userRequest)
            handleUserInterestsResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleUserInterestsResponse(response: Response<UserInterestsResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _userInterestsResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()?.charStream()?.readText()
            _userInterestsResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _userInterestsResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

}