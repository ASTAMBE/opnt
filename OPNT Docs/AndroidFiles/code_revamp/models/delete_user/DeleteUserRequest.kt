package com.opinito.social.code_revamp.models.delete_user

data class DeleteUserRequest(
    val userid: String,
    val username: String,
    val login_type_os: String
)
