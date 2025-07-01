package com.opinito.social.code_revamp.view_models

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.opinito.social.code_revamp.models.delete_post.DeletePostRequest
import com.opinito.social.code_revamp.models.delete_post.DeletePostResponse
import com.opinito.social.code_revamp.models.get_instream_nw.GetInstreamNwRequest
import com.opinito.social.code_revamp.models.get_instream_nw.GetInstreamNwResponse
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
import com.opinito.social.code_revamp.repository.NewsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class NewsViewModel @Inject constructor(private val newsRepository: NewsRepository) : ViewModel() {
    private var apiJob: Job? = null
    val userTopicResponseLiveData: LiveData<NetworkResult<GetUserTopicResponse>>
        get() = newsRepository.userTopicResponseLiveData

    val deletePostLiveData: LiveData<NetworkResult<DeletePostResponse>>
        get() = newsRepository.deletePostResponseLiveData

    val getInstrteamNwLiveData: LiveData<NetworkResult<GetInstreamNwResponse>>
        get() = newsRepository.getInstreamNwResponseLiveData

    val postBookmarkLiveData: LiveData<NetworkResult<PostBookmarkResponse>>
        get() = newsRepository.postBookmarkLiveData

    val getPostCountLivedata: LiveData<NetworkResult<GetPostCountsResponse>>
        get() = newsRepository.getPostCountResponseLiveData
    val removeBookmarkLiveData: LiveData<NetworkResult<RemoveBookmarkResponse>>
        get() = newsRepository.removeBookmarkLiveData
    val userActionCommonLiveData: LiveData<NetworkResult<UserActionCommonResponse>>
        get() = newsRepository.userActionCommonLiveData

    fun userActionCommon(userActionCommonRequest: UserActionCommonRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            newsRepository.userActionCommon(userActionCommonRequest)
        }
    }


    fun removeBookmark(removeBookmarkRequest: RemoveBookmarkRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            newsRepository.removeBookMark(removeBookmarkRequest)
        }
    }

    fun getPostCount(getPostCountsRequest: GetPostCountsRequest) {
        viewModelScope.launch {
            newsRepository.getPostCount(getPostCountsRequest)
        }
    }

    fun postBookmark(postBookmarkRequest: PostBookmarkRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            newsRepository.postBookMark(postBookmarkRequest)
        }
    }

    fun getInstreamNW(getInstreamNwRequest: GetInstreamNwRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            newsRepository.getInstreamNW(getInstreamNwRequest)
        }
    }

    fun getInstreamAnti(getInstreamNwRequest: GetInstreamNwRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            newsRepository.getInstreamNWAnti(getInstreamNwRequest)
        }
    }

    fun deletePost(deletePostRequest: DeletePostRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            newsRepository.deletePost(deletePostRequest)
        }
    }

    fun getUserTopic(getUserTopicRequest: GetUserTopicRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            newsRepository.getUserTopic(getUserTopicRequest)
        }
    }

}