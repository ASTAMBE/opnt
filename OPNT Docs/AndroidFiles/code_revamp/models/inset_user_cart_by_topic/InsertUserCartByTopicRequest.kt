package com.opinito.social.code_revamp.models.inset_user_cart_by_topic

data class InsertUserCartByTopicRequest(
    val topiccarts: MutableList<String>? = null,
    val topicid: String? = null,
    val userid: String? = null
)