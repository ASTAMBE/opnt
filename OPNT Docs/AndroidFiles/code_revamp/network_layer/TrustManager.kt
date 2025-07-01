package com.opinito.social.code_revamp.network_layer

import java.security.cert.X509Certificate
import javax.net.ssl.X509TrustManager

 class TrustManager: X509TrustManager {
     override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {
         TODO("Not yet implemented")
     }

     override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {
         TODO("Not yet implemented")
     }

     override fun getAcceptedIssuers(): Array<X509Certificate> {
         return arrayOf()
     }
 }