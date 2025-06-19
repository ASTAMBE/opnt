package com.opinito.social.Activity

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.os.CountDownTimer
import android.provider.Telephony
import android.telephony.SmsMessage
import android.text.Editable
import android.text.SpannableString
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.TextWatcher
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.text.style.StyleSpan
import android.view.KeyEvent
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.content.res.AppCompatResources
import com.google.android.gms.auth.api.phone.SmsRetriever
import com.opinito.social.R
import java.util.Locale
import java.util.regex.Pattern

class OTPActivity : AppCompatActivity() {
//    Command to generate = keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
//    Hash Key = VzSiQcXRmi2kyjzcA+mYLEtbGVs=
    private var phoneNumberTextView: TextView? = null
    private var termsAndConditions: TextView? = null
    private var otpDigit1: EditText? = null
    private var otpDigit2: EditText? = null
    private var otpDigit3: EditText? = null
    private var otpDigit4: EditText? = null
    private var submit: Button? = null
    private var smsReceiver: BroadcastReceiver? = null
    private var retryTimerTextView: TextView? = null
    private var countDownTimer: CountDownTimer? = null
    private var timeLeftInMillis: Long = 30000 // 30 seconds
    private var timerRunning = false
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_otpactivity2)
        initializeViews()
        setupListeners()
        startSmsRetriever()
        startTimer()
    }

    private fun initializeViews() {
        val phoneNumber = intent.getStringExtra("phoneNumber")
        phoneNumberTextView = findViewById(R.id.otp_info)
        submit = findViewById(R.id.submit)
        termsAndConditions = findViewById(R.id.termsandconditions)
        retryTimerTextView = findViewById(R.id.retry_in_00)
        retryTimerTextView?.text = getString(R.string.timer_text)
        otpDigit1 = findViewById(R.id.otp_digit1)
        otpDigit2 = findViewById(R.id.otp_digit2)
        otpDigit3 = findViewById(R.id.otp_digit3)
        otpDigit4 = findViewById(R.id.otp_digit4)
        phoneNumberTextView?.text =
            getString(R.string.sent_verification_code, phoneNumber)
    }

    private fun setupListeners() {
        submit?.setOnClickListener { validateAndEnableSubmit() }
        setOtpTextWatcher()
        setBackspaceListener()
        customTCTextView(termsAndConditions)
    }

    private fun startSmsRetriever() {
        val client = SmsRetriever.getClient(this)
        client.startSmsRetriever()

        smsReceiver = object : BroadcastReceiver() {
            //            override fun onReceive(context: Context, intent: Intent) {
//                if (SmsRetriever.SMS_RETRIEVED_ACTION == intent.action) {
//                    val extras = intent.extras
//                    val status = extras?.get(SmsRetriever.EXTRA_STATUS) as? Status
//                    if (status?.statusCode == CommonStatusCodes.SUCCESS) {
//                        val smsMessage = extras.getString(SmsRetriever.EXTRA_SMS_MESSAGE)
//                        smsMessage?.let {
//                            extractOtpFromMessage(it)
//                        } ?: run {
//                            Log.e("YourActivity", "Failed to extract SMS message")
//                        }
//                    }
//                }
//            }
            override fun onReceive(context: Context, intent: Intent) {
                if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION == intent.action) {
                    val bundle: Bundle? = intent.extras
                    bundle?.let {
                        val pdus = bundle.get("pdus") as Array<Any>?
                        pdus?.forEach { pdu ->
                            val smsMessage = SmsMessage.createFromPdu(pdu as ByteArray)
                            val messageBody: String = smsMessage.messageBody
                            extractOtpFromMessage(messageBody)
                        }
                    }
                }
            }
        }

//        registerReceiver(
//            smsReceiver,
//            IntentFilter(SmsRetriever.SMS_RETRIEVED_ACTION)
//        )
    }

    private fun extractOtpFromMessage(message: String?) {
        val pattern = Pattern.compile("(\\d{4})")
        val matcher = pattern.matcher(message ?: "")
        if (matcher.find()) {
            val otp = matcher.group(1)
            if (otp != null) {
                fillOtpFields(otp)
            }
        } else {
            Toast.makeText(this, "Failed to extract OTP from SMS", Toast.LENGTH_SHORT).show()
        }
    }

    private fun fillOtpFields(otp: String) {
        if (otp.length == 4) {
            otpDigit1?.setText(otp[0].toString())
            otpDigit2?.setText(otp[1].toString())
            otpDigit3?.setText(otp[2].toString())
            otpDigit4?.setText(otp[3].toString())
        } else {
            Toast.makeText(this, "Invalid OTP format", Toast.LENGTH_SHORT).show()
        }
    }

    private fun setOtpTextWatcher() {
        otpDigit1?.addTextChangedListener(GenericTextWatcher(otpDigit1))
        otpDigit2?.addTextChangedListener(GenericTextWatcher(otpDigit2))
        otpDigit3?.addTextChangedListener(GenericTextWatcher(otpDigit3))
        otpDigit4?.addTextChangedListener(GenericTextWatcher(otpDigit4))
    }

    private inner class GenericTextWatcher(private val editText: EditText?) : TextWatcher {
        override fun beforeTextChanged(charSequence: CharSequence, i: Int, i1: Int, i2: Int) {}
        override fun onTextChanged(charSequence: CharSequence, i: Int, i1: Int, i2: Int) {
            if (charSequence.length == 1) {
                if (editText === otpDigit4 && otpDigit4?.getText()?.length == 1) {
                    moveForward(editText)
                    checkOtpCompletion() // Check if OTP is complete after each digit entry
                } else if (editText !== otpDigit4) {
                    moveForward(editText)
                    checkOtpCompletion() // Check if OTP is complete after each digit entry
                }
            } else if (charSequence.length > 1) {
                // If the user enters more than one digit, only take the first digit
                editText?.setText(charSequence.subSequence(0, 1))
                editText?.setSelection(1)
            } else if (charSequence.isEmpty()) {
                submit?.setEnabled(false)
                submit?.background = AppCompatResources.getDrawable(
                    this@OTPActivity,
                    R.drawable.button_round_gray
                )
            }
        }

        override fun afterTextChanged(editable: Editable) {}
    }

    private fun setBackspaceListener() {
        otpDigit1?.setOnKeyListener(backspaceListener)
        otpDigit2?.setOnKeyListener(backspaceListener)
        otpDigit3?.setOnKeyListener(backspaceListener)
        otpDigit4?.setOnKeyListener(backspaceListener)
    }

    private val backspaceListener = View.OnKeyListener { view, keyCode, event ->
        if (keyCode == KeyEvent.KEYCODE_DEL && event.action == KeyEvent.ACTION_DOWN) {
            val editText = view as EditText
            if (editText.getText().toString().isEmpty()) {
                moveBack(editText)
            }
        }
        false
    }

    private fun moveBack(editText: EditText) {
        if (editText === otpDigit4) {
            editText.setText("")
            otpDigit3?.requestFocus()
        } else if (editText === otpDigit3) {
            editText.setText("")
            otpDigit2?.requestFocus()
        } else if (editText === otpDigit2) {
            editText.setText("")
            otpDigit1?.requestFocus()
        }
    }

    private fun moveForward(editText: EditText?) {
        if (editText === otpDigit1) {
            otpDigit2?.requestFocus()
        } else if (editText === otpDigit2) {
            otpDigit3?.requestFocus()
        } else if (editText === otpDigit3) {
            otpDigit4?.requestFocus()
        }
    }

    private fun checkOtpCompletion() {
        val otp1 = otpDigit1?.getText().toString()
        val otp2 = otpDigit2?.getText().toString()
        val otp3 = otpDigit3?.getText().toString()
        val otp4 = otpDigit4?.getText().toString()
        if (!otp1.isEmpty() && !otp2.isEmpty() && !otp3.isEmpty() && !otp4.isEmpty()) {
            submit?.setEnabled(true)
            submit?.background = AppCompatResources.getDrawable(
                this@OTPActivity,
                R.drawable.button_round_corner
            )
        } else {
            submit?.setEnabled(false)
            submit?.background = AppCompatResources.getDrawable(
                this@OTPActivity,
                R.drawable.button_round_gray
            )
        }
    }

    private fun customTCTextView(view: TextView?) {
        val spanTxt =
            SpannableStringBuilder("By logging in to Opinito, you express your consent to agreement with and understanding of the ")
        spanTxt.append("terms and conditions")
        spanTxt.setSpan(object : ClickableSpan() {
            override fun onClick(widget: View) {
                val termsIntent = Intent(this@OTPActivity, TermsandConditions::class.java)
                startActivity(termsIntent)
            }
        }, spanTxt.length - "terms and conditions".length, spanTxt.length, 0)
        spanTxt.append(" and ")
        spanTxt.append("privacy policy")
        spanTxt.setSpan(object : ClickableSpan() {
            override fun onClick(widget: View) {
                val termsIntent = Intent(this@OTPActivity, TermsandConditions::class.java)
                termsIntent.putExtra(
                    getString(R.string.privacy_policy),
                    getString(R.string.privacy_policy)
                )
                startActivity(termsIntent)
            }
        }, spanTxt.length - "privacy policy".length, spanTxt.length, 0)
        spanTxt.append(" of Opinito usage and user responsibilities")
        view!!.movementMethod = LinkMovementMethod.getInstance()
        view.setText(spanTxt, TextView.BufferType.SPANNABLE)
    }

    private fun validateAndEnableSubmit() {
        val otp = otpDigit1?.getText().toString() + otpDigit2?.getText()
            .toString() + otpDigit3?.getText().toString() + otpDigit4?.getText().toString()
        if (otp == VALID_OTP) {
            Toast.makeText(this, "Valid OTP.", Toast.LENGTH_SHORT).show()
            // Enable submit button or perform further actions
        } else {
            Toast.makeText(this, "Invalid OTP. Please try again.", Toast.LENGTH_SHORT).show()
        }
    }

    private fun startTimer() {
        countDownTimer = object : CountDownTimer(timeLeftInMillis, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                timeLeftInMillis = millisUntilFinished
                updateTimerText()
            }

            override fun onFinish() {
                timerRunning = false
                val spannableString = SpannableString("Resend OTP")
                spannableString.setSpan(
                    StyleSpan(Typeface.BOLD),
                    0,
                    spannableString.length,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                )
                retryTimerTextView?.text = spannableString
                retryTimerTextView?.isClickable = true // Enable click after timer finishes
                retryTimerTextView?.setOnClickListener {
                    timeLeftInMillis = 30000
                    startTimer() // Restart timer when Resend OTP is clicked
                    resendOtp()
                    retryTimerTextView?.isClickable = false // Disable click during timer
                }
            }
        }.start()
        timerRunning = true
        retryTimerTextView?.isClickable = false // Disable click while timer is running
    }

    private fun resendOtp() {
        Toast.makeText(this, "OTP sent", Toast.LENGTH_SHORT).show()
    }

    private fun updateTimerText() {
        val seconds = (timeLeftInMillis / 1000).toInt()
        val timeFormatted =
            String.format(Locale.getDefault(), "Retry in %02d:%02d", seconds / 60, seconds % 60)
        retryTimerTextView?.text = timeFormatted
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(smsReceiver)
    }

    companion object {
        private const val VALID_OTP = "1234"
    }
}
