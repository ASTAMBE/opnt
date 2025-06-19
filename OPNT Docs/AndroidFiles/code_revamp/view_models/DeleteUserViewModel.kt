package com.opinito.social.code_revamp.view_models

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.opinito.social.code_revamp.models.delete_user.DeleteUserRequest
import com.opinito.social.code_revamp.models.delete_user.DeleteUserResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.repository.DeleteUserRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class DeleteUserViewModel @Inject constructor(private val deleteUserRepository: DeleteUserRepository) : ViewModel() {

    val deleteUserResponseLiveData: LiveData<NetworkResult<DeleteUserResponse>>
        get() = deleteUserRepository.deleteUserResponseLiveData


    fun deleteUser(userRequest: DeleteUserRequest){
        viewModelScope.launch {
            deleteUserRepository.deleteUser(userRequest)
        }
    }

}