package com.opinito.social.code_revamp.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.facebook.FacebookSdk.getApplicationContext
import com.google.gson.Gson
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.code_revamp.models.change_country_code.ChangeCountryCodeRequest
import com.opinito.social.code_revamp.models.change_country_code.ChangeCountryCodeResponse
import com.opinito.social.code_revamp.models.inset_user_cart_by_topic.InsertUserCartByTopicRequest
import com.opinito.social.code_revamp.models.inset_user_cart_by_topic.InsertUserCartByTopicResponse
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.code_revamp.models.showInitialDiscussions.ShowInitialDiscussionsRequest
import com.opinito.social.code_revamp.models.showInitialDiscussions.ShowInitialDiscussionsResponse
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonRequest
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonResponse
import com.opinito.social.code_revamp.models.user_interests.request.SaveAllUserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.request.UserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.response.SaveAllUserInterestsResponse
import com.opinito.social.code_revamp.models.user_interests.response.UserInterestsResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.network_layer.UserAPI
import retrofit2.Response
import javax.inject.Inject

class UserRepository @Inject constructor(private val userAPI: UserAPI) {


    val xKey = BuildConfig.APP_ID
    val token = Preference(getApplicationContext()).getPref(Constants.token)

    private val _userInterestsResponseLiveData =
        MutableLiveData<NetworkResult<UserInterestsResponse>>()
    val userInterestsResponseLiveData: LiveData<NetworkResult<UserInterestsResponse>>
        get() = _userInterestsResponseLiveData


    private val _saveAllUserInterestsResponseLiveData =
        MutableLiveData<NetworkResult<SaveAllUserInterestsResponse>>()
    val saveAllUserInterestsResponseLiveData: LiveData<NetworkResult<SaveAllUserInterestsResponse>>
        get() = _saveAllUserInterestsResponseLiveData


    private val _showFreshContentResponseLiveData =
        MutableLiveData<NetworkResult<ShowFreshContentResponse>>()
    val showFreshContentResponseLiveData: LiveData<NetworkResult<ShowFreshContentResponse>>
        get() = _showFreshContentResponseLiveData


    private val _saveToCartResponseLiveData =
        MutableLiveData<NetworkResult<InsertUserCartByTopicResponse>>()

    val saveToCartResponseLiveData: LiveData<NetworkResult<InsertUserCartByTopicResponse>>
        get() = _saveToCartResponseLiveData

    private val _changeCountryCodeLiveData =
        MutableLiveData<NetworkResult<ChangeCountryCodeResponse>>()
    val changeCountryCodeLiveData: LiveData<NetworkResult<ChangeCountryCodeResponse>>
        get() = _changeCountryCodeLiveData

    private val _showInitialDiscussionsLiveData =
        MutableLiveData<NetworkResult<ShowInitialDiscussionsResponse>>()

    val showInitialDiscussionsliveData: LiveData<NetworkResult<ShowInitialDiscussionsResponse>>
        get() = _showInitialDiscussionsLiveData

    private val _userActionCommonLiveData =
        MutableLiveData<NetworkResult<UserActionCommonResponse>>()
    val userActionCommonLiveData: LiveData<NetworkResult<UserActionCommonResponse>>
        get() = _userActionCommonLiveData

    suspend fun userActionCommon(userActionCommonRequest: UserActionCommonRequest) {
        try {
            _userActionCommonLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.userActionCommon(token, xKey, userActionCommonRequest)
            handleUserActionCommonResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
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


    suspend fun showFreshContent(request: ShowFreshContentRequest){
        try {
            _showFreshContentResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.showFreshContent(token, xKey, request)
            handleShowFreshContentResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleShowFreshContentResponse(response: Response<ShowFreshContentResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _showFreshContentResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            try {
                val errorBody = response.errorBody()?.string()
                val errorResponse = Gson().fromJson(errorBody, ShowFreshContentResponse::class.java)
                _showFreshContentResponseLiveData.postValue(NetworkResult.Error(errorResponse.status ?: "Unknown Error"))
            } catch (e: Exception) {
                _showFreshContentResponseLiveData.postValue(NetworkResult.Error("Error parsing response"))
            }
        } else {
            _showFreshContentResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    suspend fun saveAllInterests(userRequest: SaveAllUserInterestsRequest) {
        try {
            _saveAllUserInterestsResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.saveAllInterests(token, xKey, userRequest)
            handleSaveAllInterestsResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleSaveAllInterestsResponse(response: Response<SaveAllUserInterestsResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _saveAllUserInterestsResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            try {
                val errorBody = response.errorBody()?.string()
                val errorResponse = Gson().fromJson(errorBody, SaveAllUserInterestsResponse::class.java)
                _saveAllUserInterestsResponseLiveData.postValue(NetworkResult.Error(errorResponse.status ?: "Unknown Error"))
            } catch (e: Exception) {
                _saveAllUserInterestsResponseLiveData.postValue(NetworkResult.Error("Error parsing response"))
            }
        } else {
            _saveAllUserInterestsResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }


    suspend fun showInitialDiscussions(showInitialDiscussionsRequest: ShowInitialDiscussionsRequest) {
        try {
            _showInitialDiscussionsLiveData.postValue(NetworkResult.Loading())
            val response =
                userAPI.showInitialDiscussions(token, xKey, showInitialDiscussionsRequest)
            handleShowInitialDiscussionsResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    suspend fun saveToCart(insertUserCartByTopicRequest: InsertUserCartByTopicRequest) {
        try {
            _userInterestsResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.insertUserCartByTopic(token, xKey, insertUserCartByTopicRequest)
            handleResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    suspend fun changeCountryCode(changeCountryCodeRequest: ChangeCountryCodeRequest) {
        try {
            _changeCountryCodeLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.changeCountryCode(token, xKey, changeCountryCodeRequest)
            handleCountryCodeResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    private fun handleCountryCodeResponse(response: Response<ChangeCountryCodeResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _changeCountryCodeLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()?.charStream()?.readText()
            _changeCountryCodeLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _changeCountryCodeLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
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

    private fun handleResponse(response: Response<InsertUserCartByTopicResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _saveToCartResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _saveToCartResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _saveToCartResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    private fun handleShowInitialDiscussionsResponse(response: Response<ShowInitialDiscussionsResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _showInitialDiscussionsLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _showInitialDiscussionsLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _showInitialDiscussionsLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    private fun handleUserActionCommonResponse(response: Response<UserActionCommonResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _userActionCommonLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _userActionCommonLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _userActionCommonLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

}