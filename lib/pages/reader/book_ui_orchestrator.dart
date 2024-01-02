class BookUIOrchestrator {
  BookUIOrchestrator();

  /// Listeners
  /// This system allows components to subscribe to events that are dispatched by other components
  /// via [dispatchAction]. An example of this event is page turning: the controller widget dispatches
  /// a page-turn event, which the renderer widget listens for using [registerListener] and responds to
  /// by turning the page (by providing a callback).

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

  /// State Listeners
  /// In the case where a signal represents the a change in the state of the component, the dispatcher
  /// must provide the new state as an argument to the callback when dispatching with [dispatchStateAction].
  /// As such, state listener callbacks must accept a parameter with the state and must be registered with
  /// [registerStateListener]. The receiver can also ask for the state from the orchestrator directly by
  /// using [retrieveState]. As such, each [BookUIOrchestratorStateAction] can only have one state.

  Map<BookUIOrchestratorStateAction, Set<Function(dynamic)>> stateListeners = {};
  Map<BookUIOrchestratorStateAction, dynamic> states = {};

  void registerStateListener(BookUIOrchestratorStateAction action, Function(dynamic) callback) {
    // Callback already registered
    if (stateListeners[action]?.contains(callback) ?? false) return;

    stateListeners.putIfAbsent(action, () => <void Function(dynamic)>{});
    stateListeners[action]!.add(callback);
  }

  void deregisterStateListener(BookUIOrchestratorStateAction action, Function(dynamic) callback) {
    // Cannot deregister callback that was not registered
    if (!(stateListeners[action]?.contains(callback) ?? true)) return;

    stateListeners[action]?.remove(callback);
  }

  void dispatchStateAction(BookUIOrchestratorStateAction action, dynamic state) {
    stateListeners[action]?.forEach((callback) => callback(state));
    states[action] = state;
  }

  dynamic retrieveState(BookUIOrchestratorStateAction action) {
    return states[action] ?? action.state;
  }
}

enum BookUIOrchestratorAction {
  leftPage,
  rightPage,
  ;

  String toJson() => name;
}

enum BookUIOrchestratorStateAction {
  updateLocationNumber(state: 0),
  setPageCount(state: 1), // not expected to change, but is placed for consistency
  setTitle(state: ""), // not expected to change, but is placed for consistency
  setMenuVisibility(state: true),
  ;

  const BookUIOrchestratorStateAction({required this.state});

  final dynamic state;

  String toJson() => name;
}
