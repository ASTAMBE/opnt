package com.opinito.social.code_revamp.view_models

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.opinito.social.code_revamp.models.change_country_code.ChangeCountryCodeRequest
import com.opinito.social.code_revamp.models.change_country_code.ChangeCountryCodeResponse
import com.opinito.social.code_revamp.models.inset_user_cart_by_topic.InsertUserCartByTopicRequest
import com.opinito.social.code_revamp.models.inset_user_cart_by_topic.InsertUserCartByTopicResponse
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.code_revamp.models.showInitialDiscussions.ShowInitialDiscussionsRequest
import com.opinito.social.code_revamp.models.showInitialDiscussions.ShowInitialDiscussionsResponse
import com.opinito.social.code_revamp.models.user_interests.request.SaveAllUserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.request.UserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.response.Data
import com.opinito.social.code_revamp.models.user_interests.response.SaveAllUserInterestsResponse
import com.opinito.social.code_revamp.models.user_interests.response.UserInterestsResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.repository.UserRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ProfileViewModel @Inject constructor(private val userRepository: UserRepository) :
    ViewModel() {

    val userInterestsResponseLiveData: LiveData<NetworkResult<UserInterestsResponse>>
        get() = userRepository.userInterestsResponseLiveData

    val saveToCartResponseLiveData: LiveData<NetworkResult<InsertUserCartByTopicResponse>>
        get() = userRepository.saveToCartResponseLiveData

    val changeCountryCodeLiveData: LiveData<NetworkResult<ChangeCountryCodeResponse>>
        get() = userRepository.changeCountryCodeLiveData

    val showInitialDiscussionsLiveData: LiveData<NetworkResult<ShowInitialDiscussionsResponse>>
        get() = userRepository.showInitialDiscussionsliveData

    val saveAllUserInterestsResponseLiveData: LiveData<NetworkResult<SaveAllUserInterestsResponse>>
        get() = userRepository.saveAllUserInterestsResponseLiveData

    val showFreshContentResponseLiveData: LiveData<NetworkResult<ShowFreshContentResponse>>
        get() = userRepository.showFreshContentResponseLiveData


    fun showFreshContent(showFreshContentRequest: ShowFreshContentRequest) {
        viewModelScope.launch {
            userRepository.showFreshContent(showFreshContentRequest)
        }
    }

    fun showInitialDiscussions(showInitialDiscussionsRequest: ShowInitialDiscussionsRequest) {
        viewModelScope.launch {
            userRepository.showInitialDiscussions(showInitialDiscussionsRequest)
        }
    }

    fun getInterests(userRequest: UserInterestsRequest) {
        viewModelScope.launch{
            userRepository.getUserInterests(userRequest)
        }
    }

    fun saveAllInterests(userRequest: SaveAllUserInterestsRequest){
        viewModelScope.launch{
            userRepository.saveAllInterests(userRequest)
        }
    }

    fun saveToCart(insertUserCartByTopicRequest: InsertUserCartByTopicRequest) {
        viewModelScope.launch {
            userRepository.saveToCart(insertUserCartByTopicRequest)
        }
    }

    fun changeCountryCode(changeCountryCodeRequest: ChangeCountryCodeRequest) {
        viewModelScope.launch {
            userRepository.changeCountryCode(changeCountryCodeRequest)
        }
    }



}