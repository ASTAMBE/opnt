package com.opinito.social.code_revamp.models.remove_bookmark

data class RemoveBookmarkRequest(
    val postid: Int,
    val userid: String
)