package com.opinito.social.code_revamp.view_models

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.code_revamp.models.suggest_kw.SuggestKWRequest
import com.opinito.social.code_revamp.models.suggest_kw.SuggestKWResponse
import com.opinito.social.code_revamp.models.user_interests.request.UserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.response.UserInterestsResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.repository.MainRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(private val mainRepository: MainRepository) : ViewModel() {
    val suggestWKResponseLiveData: LiveData<NetworkResult<ShowFreshContentResponse>>
        get() = mainRepository.suggestKWResponseLiveData

    fun getLatestKW(showFreshContentRequest: ShowFreshContentRequest) {
        viewModelScope.launch {
            mainRepository.getKeywords(showFreshContentRequest)
        }
    }

    ///
    val userInterestsResponseLiveData: LiveData<NetworkResult<UserInterestsResponse>>
        get() = mainRepository.userInterestsResponseLiveData


    fun getInterests(userRequest: UserInterestsRequest) {
        viewModelScope.launch{
            mainRepository.getUserInterests(userRequest)
        }
    }
}