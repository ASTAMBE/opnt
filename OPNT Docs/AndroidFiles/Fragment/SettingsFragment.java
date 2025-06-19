package com.opinito.social.Fragment;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.opinito.social.Activity.TermsandConditions;
import com.opinito.social.R;
import com.opinito.social.Utils.UserUtils;


public class SettingsFragment extends Fragment {
    Button logout, privacy;

    public SettingsFragment() {
        // Required empty public constructor
    }

    public static SettingsFragment newInstance() {
        SettingsFragment fragment = new SettingsFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_setitngs, container, false);

    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        logout = view.findViewById(R.id.one);
        privacy = view.findViewById(R.id.two);
        if (UserUtils.isGuestUser(requireActivity())) {
            logout.setVisibility(View.GONE);
        }else {
            logout.setVisibility(View.VISIBLE);
        }
        privacy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), TermsandConditions.class);
                intent.putExtra(getString(R.string.privacy_policy), getString(R.string.privacy_policy));
                startActivity(intent);
            }
        });

        logout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Fragment fragment =  new DeleteAccount();
                FragmentManager fragmentManager = requireActivity().getSupportFragmentManager();
                FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
                fragmentTransaction.replace(R.id.fragmentContainerView, fragment);
                fragmentTransaction.addToBackStack(null).commit();
            }
        });
    }
}
