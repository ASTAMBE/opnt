package com.opinito.social.code_revamp.view_models

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.opinito.social.code_revamp.models.getUserCarts.GetUserCartsRequest
import com.opinito.social.code_revamp.models.getUserCarts.GetUserCartsResponse
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.repository.InterestsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class InterestsViewModel @Inject constructor(private val interestsRepository: InterestsRepository) :
    ViewModel() {

    private var apiJob: Job? = null
    val userTopicResponseLiveData: LiveData<NetworkResult<GetUserTopicResponse>>
        get() = interestsRepository.userTopicResponseLiveData

    val userCartsResponseLiveData: LiveData<NetworkResult<GetUserCartsResponse>>
        get() = interestsRepository.getUserCartsResponseLiveData

    fun getUserCarts(getUserCartsRequest: GetUserCartsRequest) {
        apiJob?.cancel()
        apiJob = viewModelScope.launch {
            interestsRepository.getUserCarts(getUserCartsRequest)
        }
    }

    fun getUserTopic(getUserTopicRequest: GetUserTopicRequest) {
        viewModelScope.launch {
            interestsRepository.getUserTopic(getUserTopicRequest)
        }
    }

}