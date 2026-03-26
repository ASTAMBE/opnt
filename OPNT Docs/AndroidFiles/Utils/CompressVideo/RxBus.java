package com.opinito.social.Utils.CompressVideo;

import com.jakewharton.rxrelay2.BehaviorRelay;
import com.jakewharton.rxrelay2.Relay;

import io.reactivex.BackpressureStrategy;
import io.reactivex.Flowable;

public class RxBus {

    public RxBus() {
    }
    private final Relay<Object> _bus = BehaviorRelay.create();

    public void send(Object o) {
        _bus.accept(o);
    }

    public Flowable<Object> asFlowable() {
        return _bus.toFlowable(BackpressureStrategy.LATEST);
    }

    public boolean hasObservers() {
        return _bus.hasObservers();
    }
}