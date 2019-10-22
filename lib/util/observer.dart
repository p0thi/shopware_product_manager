abstract class Observer {
  void action();
}

class Observable {
  List<Observer> observers = <Observer>[];

  void addObserver(Observer obs) {
    observers.add(obs);
  }

  void removeObserver(Observer obs) {
    observers.remove(obs);
  }

  void notify() {
    for (Observer obs in observers) {
      obs.action();
    }
  }
}
