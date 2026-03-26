package com.opinito.social;

public class OptionSelectionEvent {

    private boolean selectedOption;

    public boolean getSelectedOption() {
        return selectedOption;
    }

    public OptionSelectionEvent(boolean selectedOption) {
        this.selectedOption = selectedOption;
    }
}
