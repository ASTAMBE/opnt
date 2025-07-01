package com.opinito.social;


import io.reactivex.Observable;
import io.reactivex.subjects.PublishSubject;

public class EventsManager {

    public EventsManager() {
    }

    private PublishSubject<Object> eventPublisher = PublishSubject.create();

    public void publish(Object o) {
        eventPublisher.onNext(o);
    }

    public Observable<CartSelectionEvent> listen(Class<CartSelectionEvent> eventType) {
        return eventPublisher.ofType(eventType);
    }


    public void publishOptionEvent(Object o) {
        eventPublisher.onNext(o);
    }

    public Observable<OptionSelectionEvent> listenOptionEvent(Class<OptionSelectionEvent> eventType) {
        return eventPublisher.ofType(eventType);
    }

}



