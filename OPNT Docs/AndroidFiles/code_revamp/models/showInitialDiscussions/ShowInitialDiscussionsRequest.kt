package com.opinito.social.code_revamp.models.showInitialDiscussions

data class ShowInitialDiscussionsRequest(
    val fromIndex: Int? = null,
    val toIndex: Int? = null,
    val topicid: Int? = null,
    val userid: String? = null
)