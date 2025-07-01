package com.opinito.social.code_revamp

import android.app.Activity
import android.os.Bundle

abstract class BaseActivity: Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initUI()
    }

    abstract fun initUI()

}