package com.opinito.social.code_revamp.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.facebook.FacebookSdk
import com.facebook.FacebookSdk.getApplicationContext
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.code_revamp.models.delete_user.DeleteUserRequest
import com.opinito.social.code_revamp.models.delete_user.DeleteUserResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.network_layer.UserAPI
import retrofit2.Response
import javax.inject.Inject

class DeleteUserRepository @Inject constructor(private val userAPI: UserAPI) {

    val xKey = BuildConfig.APP_ID
    val token = Preference(getApplicationContext()).getPref(Constants.token)

    private val _deleteUserResponseLiveData = MutableLiveData<NetworkResult<DeleteUserResponse>>()
    val deleteUserResponseLiveData: LiveData<NetworkResult<DeleteUserResponse>>
        get() = _deleteUserResponseLiveData

    suspend fun deleteUser(userRequest: DeleteUserRequest) {
        try {
            _deleteUserResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.deleteUser(token, xKey, userRequest)
            handleResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleResponse(response: Response<DeleteUserResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _deleteUserResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _deleteUserResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _deleteUserResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }
}