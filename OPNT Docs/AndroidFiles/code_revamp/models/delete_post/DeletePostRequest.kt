package com.opinito.social.code_revamp.models.delete_post

data class DeletePostRequest(
    val postid: Int? = null,
    val userid: String? = null
)