package com.opinito.social.code_revamp.models.showFreshContent

data class ShowFreshContentResponse(
    val `data`: List<Data?>? = null,
    val status: String?
) {
    data class Data(
        val KEYID: String? = null,
        val POSTOR_COUNTRY_CODE: String? = null,
        val POST_CONTENT: String? = null,
        val POST_ID: String? = null,
        val SHOW_CONTENT: String? = null,
        val TOPICID: String? = null,
        val USERCOUNT: String? = null,
        var ACTION: String? = null
    )
}
