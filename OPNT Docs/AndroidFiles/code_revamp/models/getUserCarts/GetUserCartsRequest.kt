package com.opinito.social.code_revamp.models.getUserCarts

data class GetUserCartsRequest(
    val fromIndex: Int? = null,
    val sortOrder: String? = null,
    val toIndex: Int? = null,
    val topicid: Int? = null,
    val userid: String? = null
)