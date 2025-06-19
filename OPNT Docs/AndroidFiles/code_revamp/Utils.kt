package com.opinito.social.code_revamp

import android.graphics.Color
import android.text.Spannable
import android.text.SpannableString
import android.text.style.ForegroundColorSpan
import android.widget.TextView

class Utils {

    object MakeTextViewResizable {
        fun makeTextViewResizable(
            textView: TextView, maxLine: Int, expandText: String, viewMore: Boolean
        ) {
            if (textView.tag == null) {
                textView.tag = textView.text
            }
            val viewLessText = "Less"
            var isExpanded = !viewMore // Set initial toggle state based on `viewMore`

            textView.post {
                val layout = textView.layout
                if (layout != null && textView.lineCount > maxLine) {
                    val lineEndIndex = if (maxLine <= textView.lineCount) {
                        layout.getLineEnd(maxLine - 1)
                    } else {
                        layout.getLineEnd(textView.lineCount - 1)
                    }

                    // Display truncated text with "See More" in blue
                    val displayedText = textView.text.subSequence(0, lineEndIndex).toString()
                    val spannableExpand = SpannableString("$displayedText $expandText").apply {
                        setSpan(
                            ForegroundColorSpan(Color.BLUE),
                            displayedText.length + 1,
                            length,
                            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                        )
                    }

                    val spannableCollapse = SpannableString("${textView.tag} $viewLessText").apply {
                        setSpan(
                            ForegroundColorSpan(Color.BLUE),
                            length - viewLessText.length,
                            length,
                            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                        )
                    }

                    textView.text = spannableExpand
                    textView.maxLines = maxLine

                    // Toggle between expanded and collapsed states
                    textView.setOnClickListener {
                        if (isExpanded) {
                            // Collapse to maxLine with "See More"
                            textView.text = spannableExpand
                            textView.maxLines = maxLine
                        } else {
                            // Expand to show full text with "See Less"
                            textView.text = spannableCollapse
                            textView.maxLines = Int.MAX_VALUE
                        }
                        isExpanded = !isExpanded // Toggle the state
                    }
                }
            }
        }
    }
}
