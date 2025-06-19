package com.opinito.social.code_revamp.models.get_discussions_nw

data class GetDiscussionsNwRequest(
    val from: Int? = null,
    val to: Int? = null,
    val topicid: Int? = null,
    val userid: String? = null
)