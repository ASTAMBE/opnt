package com.opinito.social;

public class CartSelectionEvent {

    private int selectedOption;

    public int getSelectedOption() {
        return selectedOption;
    }

    public CartSelectionEvent(int selectedOption) {
        this.selectedOption = selectedOption;
    }
}
