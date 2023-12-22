class BookUIOrchestrator {
  BookUIOrchestrator();

  Map<BookUIOrchestratorAction, Set<Function()>> listeners = {};

  void registerListener(BookUIOrchestratorAction action, Function() callback) {
    // Callback already registered
    if (listeners[action]?.contains(callback) ?? false) return;

    listeners.putIfAbsent(action, () => <void Function()>{});
    listeners[action]!.add(callback);
  }

  void deregisterListener(BookUIOrchestratorAction action, Function() callback) {
    // Cannot deregister callback that was not registered
    if (!(listeners[action]?.contains(callback) ?? true)) return;

    listeners[action]?.remove(callback);
  }

  void dispatchAction(BookUIOrchestratorAction action) {
    listeners[action]?.forEach((callback) => callback());
  }
}

enum BookUIOrchestratorAction {
  leftPage,
  rightPage,
  ;

  String toJson() => name;
}
