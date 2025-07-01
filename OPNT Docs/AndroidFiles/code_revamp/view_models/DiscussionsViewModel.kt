package com.opinito.social.code_revamp.view_models

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.opinito.social.code_revamp.models.delete_post.DeletePostRequest
import com.opinito.social.code_revamp.models.delete_post.DeletePostResponse
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwRequest
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwResponse
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
import com.opinito.social.code_revamp.network_layer.UserAPI
import com.opinito.social.code_revamp.repository.DiscussionsRepository
import com.opinito.social.code_revamp.repository.NewsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import retrofit2.Response
import javax.inject.Inject

@HiltViewModel
class DiscussionsViewModel @Inject constructor(private val discussionsRepository: DiscussionsRepository) :
    ViewModel() {
    private var apiJob: Job? = null
    val userTopicResponseLiveData: LiveData<NetworkResult<GetUserTopicResponse>>
        get() = discussionsRepository.userTopicResponseLiveData

    val deletePostLiveData: LiveData<NetworkResult<DeletePostResponse>>
        get() = discussionsRepository.deletePostResponseLiveData

    val getDiscussionNwLiveData: LiveData<NetworkResult<GetDiscussionsNwResponse>>
        get() = discussionsRepository.getDiscussionNwResponseLiveData

    val postBookmarkLiveData: LiveData<NetworkResult<PostBookmarkResponse>>
        get() = discussionsRepository.postBookmarkLiveData

    val getPostCountLivedata: LiveData<NetworkResult<GetPostCountsResponse>>
        get() = discussionsRepository.getPostCountResponseLiveData
    val removeBookmarkLiveData: LiveData<NetworkResult<RemoveBookmarkResponse>>
        get() = discussionsRepository.removeBookmarkLiveData
    val userActionCommonLiveData: LiveData<NetworkResult<UserActionCommonResponse>>
        get() = discussionsRepository.userActionCommonLiveData

    fun userActionCommon(userActionCommonRequest: UserActionCommonRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            discussionsRepository.userActionCommon(userActionCommonRequest)
        }
    }


    fun removeBookmark(removeBookmarkRequest: RemoveBookmarkRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            discussionsRepository.removeBookMark(removeBookmarkRequest)
        }
    }

    fun getPostCount(getPostCountsRequest: GetPostCountsRequest) {
        viewModelScope.launch {
            discussionsRepository.getPostCount(getPostCountsRequest)
        }
    }

    fun postBookmark(postBookmarkRequest: PostBookmarkRequest) {
        viewModelScope.launch {
            discussionsRepository.postBookMark(postBookmarkRequest)
        }
    }

    fun getDiscussionNW(getDiscussionsNwRequest: GetDiscussionsNwRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            discussionsRepository.getDiscussionNW(getDiscussionsNwRequest)
        }
    }

    fun getDiscussionAnti(getDiscussionsNwRequest: GetDiscussionsNwRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            discussionsRepository.getDiscussionNWAnti(getDiscussionsNwRequest)
        }
    }

    fun deletePost(deletePostRequest: DeletePostRequest) {
        viewModelScope.launch {
            discussionsRepository.deletePost(deletePostRequest)
        }
    }

    fun getUserTopic(getUserTopicRequest: GetUserTopicRequest) {
        viewModelScope.launch {
            discussionsRepository.getUserTopic(getUserTopicRequest)
        }
    }

}