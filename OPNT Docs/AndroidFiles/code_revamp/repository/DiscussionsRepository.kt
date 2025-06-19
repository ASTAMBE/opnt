package com.opinito.social.code_revamp.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.facebook.FacebookSdk
import com.facebook.FacebookSdk.getApplicationContext
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.code_revamp.models.delete_post.DeletePostRequest
import com.opinito.social.code_revamp.models.delete_post.DeletePostResponse
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwRequest
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwResponse
import com.opinito.social.code_revamp.models.get_post_counts.GetPostCountsRequest
import com.opinito.social.code_revamp.models.get_post_counts.GetPostCountsResponse
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponse
import com.opinito.social.code_revamp.models.post_bookmark.PostBookmarkRequest
import com.opinito.social.code_revamp.models.post_bookmark.PostBookmarkResponse
import com.opinito.social.code_revamp.models.remove_bookmark.RemoveBookmarkRequest
import com.opinito.social.code_revamp.models.remove_bookmark.RemoveBookmarkResponse
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonRequest
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.network_layer.UserAPI
import retrofit2.Response
import javax.inject.Inject

class DiscussionsRepository @Inject constructor(private val userAPI: UserAPI) {

    val xKey = BuildConfig.APP_ID
    val token = Preference(getApplicationContext()).getPref(Constants.token)

    private val _userTopicResponseLiveData = MutableLiveData<NetworkResult<GetUserTopicResponse>>()
    val userTopicResponseLiveData: LiveData<NetworkResult<GetUserTopicResponse>>
        get() = _userTopicResponseLiveData


    private val _deletePostResponseLivedata = MutableLiveData<NetworkResult<DeletePostResponse>>()
    val deletePostResponseLiveData: LiveData<NetworkResult<DeletePostResponse>>
        get() = _deletePostResponseLivedata

    private val _userActionCommonLiveData =
        MutableLiveData<NetworkResult<UserActionCommonResponse>>()
    val userActionCommonLiveData: LiveData<NetworkResult<UserActionCommonResponse>>
        get() = _userActionCommonLiveData

    private val _getPostCountResponseLiveData =
        MutableLiveData<NetworkResult<GetPostCountsResponse>>()
    val getPostCountResponseLiveData: LiveData<NetworkResult<GetPostCountsResponse>>
        get() = _getPostCountResponseLiveData

    private val _postBookmarkLiveData = MutableLiveData<NetworkResult<PostBookmarkResponse>>()
    val postBookmarkLiveData: LiveData<NetworkResult<PostBookmarkResponse>>
        get() = _postBookmarkLiveData

    private val _getDiscussionNwResponseLiveData =
        MutableLiveData<NetworkResult<GetDiscussionsNwResponse>>()
    val getDiscussionNwResponseLiveData: LiveData<NetworkResult<GetDiscussionsNwResponse>>
        get() = _getDiscussionNwResponseLiveData

    suspend fun getDiscussionNW(getDiscussionsNwRequest: GetDiscussionsNwRequest) {
        try {
            _getDiscussionNwResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.getDiscussionNw(token, xKey, getDiscussionsNwRequest)
            handleGetDiscussionNwResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleGetDiscussionNwResponse(response: Response<GetDiscussionsNwResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _getDiscussionNwResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _getDiscussionNwResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _getDiscussionNwResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    suspend fun postBookMark(postBookmarkRequest: PostBookmarkRequest) {
        try {
            _postBookmarkLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.postBookmark(token, xKey, postBookmarkRequest)
            handlePostBookmarkResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    private val _removeBookmarkLiveData = MutableLiveData<NetworkResult<RemoveBookmarkResponse>>()
    val removeBookmarkLiveData: LiveData<NetworkResult<RemoveBookmarkResponse>>
        get() = _removeBookmarkLiveData

    suspend fun removeBookMark(removeBookmarkRequest: RemoveBookmarkRequest) {
        try {
            _removeBookmarkLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.removeBookmark(removeBookmarkRequest)
            handleRemoveBookmarkResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleRemoveBookmarkResponse(response: Response<RemoveBookmarkResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _removeBookmarkLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _removeBookmarkLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _removeBookmarkLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    private fun handlePostBookmarkResponse(response: Response<PostBookmarkResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _postBookmarkLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _postBookmarkLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _postBookmarkLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    suspend fun getPostCount(getPostCountsRequest: GetPostCountsRequest) {
        try {
            _getPostCountResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.getPostCounts(token, xKey, getPostCountsRequest)
            handleGetPostCountResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleGetPostCountResponse(response: Response<GetPostCountsResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _getPostCountResponseLiveData.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _getPostCountResponseLiveData.postValue(NetworkResult.Error(errorObj))
        } else {
            _getPostCountResponseLiveData.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    suspend fun userActionCommon(userActionCommonRequest: UserActionCommonRequest) {
        try {
            _userActionCommonLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.userActionCommon(token, xKey, userActionCommonRequest)
            handleUserActionCommonResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
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

    suspend fun deletePost(deletePostRequest: DeletePostRequest) {
        try {
            _deletePostResponseLivedata.postValue(NetworkResult.Loading())
            val response = userAPI.deletePost(token, xKey, deletePostRequest)
            handleDeletePostResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleDeletePostResponse(response: Response<DeletePostResponse>) {
        if (response.isSuccessful && response.body() != null) {
            _deletePostResponseLivedata.postValue(NetworkResult.Success(response.body()!!))
        } else if (response.errorBody() != null) {
            val errorObj = response.errorBody()!!.charStream().readText()
            _deletePostResponseLivedata.postValue(NetworkResult.Error(errorObj))
        } else {
            _deletePostResponseLivedata.postValue(NetworkResult.Error("Something Went Wrong"))
        }
    }

    suspend fun getUserTopic(getUserTopicRequest: GetUserTopicRequest) {
        try {
            _userTopicResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.getUserTopics(token, xKey, getUserTopicRequest)
            handleUserTopicResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
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

    suspend fun getDiscussionNWAnti(getDiscussionsNwRequest: GetDiscussionsNwRequest) {
        try {
            _getDiscussionNwResponseLiveData.postValue(NetworkResult.Loading())
            val response = userAPI.getDiscussionAnti(token, xKey, getDiscussionsNwRequest)
            handleGetDiscussionNwResponse(response)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

}