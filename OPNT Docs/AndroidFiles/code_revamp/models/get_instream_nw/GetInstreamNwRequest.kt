package com.opinito.social.code_revamp.models.get_instream_nw

data class GetInstreamNwRequest(
    val from: Int? = null,
    val to: Int? = null,
    val topicid: Int? = null,
    val userid: String? = null
)