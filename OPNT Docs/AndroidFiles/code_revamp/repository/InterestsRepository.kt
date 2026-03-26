package com.opinito.social.code_revamp.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.facebook.FacebookSdk
import com.facebook.FacebookSdk.getApplicationContext
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.code_revamp.models.getUserCarts.GetUserCartsRequest
import com.opinito.social.code_revamp.models.getUserCarts.GetUserCartsResponse
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.network_layer.UserAPI
import retrofit2.Response
import javax.inject.Inject

class InterestsRepository @Inject constructor(private val userAPI: UserAPI) {


    val xKey = BuildConfig.APP_ID
    val token = Preference(getApplicationContext()).getPref(Constants.token)

    private val _userTopicResponseLiveData = MutableLiveData<NetworkResult<GetUserTopicResponse>>()
    val userTopicResponseLiveData: LiveData<NetworkResult<GetUserTopicResponse>>
        get() = _userTopicResponseLiveData

    private val _getUserCartsResponseLiveData =
        MutableLiveData<NetworkResult<GetUserCartsResponse>>()

    val getUserCartsResponseLiveData: LiveData<NetworkResult<GetUserCartsResponse>>
        get() = _getUserCartsResponseLiveData

    suspend fun getUserCarts(getUserCartsRequest: GetUserCartsRequest){
        try{
       _getUserCartsResponseLiveData.postValue(NetworkResult.Loading())
        val response = userAPI.getUserCarts(token,xKey,getUserCartsRequest)
        handleUserCartsResponse(response)
        }catch (e:Exception){e.printStackTrace()}
    }

    private fun handleUserCartsResponse(response: Response<GetUserCartsResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _getUserCartsResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _getUserCartsResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _getUserCartsResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    suspend fun getUserTopic(getUserTopicRequest: GetUserTopicRequest) {
        try{
        _userTopicResponseLiveData.postValue(NetworkResult.Loading())
        val response = userAPI.getUserTopics(token,xKey,getUserTopicRequest)
        handleUserTopicResponse(response)
        }catch (e:Exception){e.printStackTrace()}
    }

    private fun handleUserTopicResponse(response: Response<GetUserTopicResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _userTopicResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _userTopicResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _userTopicResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }
}