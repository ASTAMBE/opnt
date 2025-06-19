package com.opinito.social.Fragment

import android.app.Dialog
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ProgressBar
import android.widget.RadioButton
import android.widget.TextView
import android.widget.Toast
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import com.facebook.FacebookSdk.getApplicationContext
import com.opinito.social.Activity.Login
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.R
import com.opinito.social.Utils.UserUtils
import com.opinito.social.code_revamp.models.delete_user.DeleteUserRequest
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.databinding.FragmentDeleteAccountBinding
import com.opinito.social.code_revamp.view_models.DeleteUserViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class DeleteAccount : Fragment() {
    private var binding: FragmentDeleteAccountBinding? = null
    var progressBar: ProgressBar? = null
    private val deleteUserViewModel by viewModels<DeleteUserViewModel>()
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentDeleteAccountBinding.inflate(inflater, container, false)
        return binding!!.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding?.conformbtn?.isClickable = false
        binding?.conformbtn?.isEnabled = false
        progressBar = view.findViewById(R.id.progress_delete)

        binding?.radioG?.setOnCheckedChangeListener { radioGroup, i ->
            val radioButton = view.findViewById<RadioButton>(i)
            if (radioButton.isChecked) {
                binding?.conformbtn?.setBackgroundColor(resources.getColor(R.color.colorPrimary))
                binding?.conformbtn?.isClickable = true
                binding?.conformbtn?.isEnabled = true
            } else {
                Toast.makeText(context, "Please Select Something", Toast.LENGTH_SHORT).show()
            }
        }
        binding?.conformbtn?.setOnClickListener {
            deleteUserViewModel.deleteUser(
                DeleteUserRequest(
                    Preference(getApplicationContext()).getPref(
                        Constants.USERID
                    ),
                    Preference(getApplicationContext()).getPref(Constants.USERNAME),
                    Preference(getApplicationContext()).getPref(
                        Constants.PROVIDERTYPE
                    ) + "-android"
                )
            )
        }
        bindObservers()
    }



    private fun bindObservers() {

        deleteUserViewModel.deleteUserResponseLiveData.observe(viewLifecycleOwner) {
            //   binding.progressBar.isVisible = false
            when (it) {
                is NetworkResult.Success -> {
                    Log.d("delete observer", "Deletion Successful")
                    UserUtils.logOutUser(activity)
                    val topicPopup = Dialog(requireActivity())
                    topicPopup.setContentView(R.layout.delete_successful_dialog)
                    val ok = topicPopup.findViewById<TextView>(R.id.btnyes)
                    topicPopup.setCancelable(false)
                    ok.setOnClickListener {
                        Preference(activity).saveIntPref(Constants.TOPICID, 0)
                        Preference(activity).saveIntPref(Constants.TOPICCARTID, 0)
                        Preference(activity).savePref(Constants.USERNAME, "")
                        Preference(activity).savePref(Constants.PROVIDERTYPE, "")
                        Preference(activity).savePref(Constants.PROFILEIMAGE, "")
                        val intent = Intent(activity, Login::class.java)
                        startActivity(intent)
                        requireActivity().finish()
                        topicPopup.dismiss()
                    }
                    topicPopup.window
                        ?.setLayout(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                        )
                    topicPopup.show()

                }

                is NetworkResult.Error -> {
                    Toast.makeText(requireContext(), it.message.toString(), Toast.LENGTH_SHORT)
                        .show()
                }

                is NetworkResult.Loading -> {
                    binding?.progressDelete?.isVisible = true
                }

            }
        }

    }

}