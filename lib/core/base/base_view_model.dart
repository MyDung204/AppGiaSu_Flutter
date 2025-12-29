import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for ViewModels using AsyncNotifier pattern (Riverpod 2.x)
/// 
/// **Purpose:**
/// - Provides common functionality for ViewModels that manage async data
/// - Handles loading, error, and data states automatically
/// - Simplifies async operations with built-in state management
/// 
/// **When to use:**
/// - When your ViewModel manages async data (API calls, database queries)
/// - When you need automatic loading/error states
/// - When state is `AsyncValue<T>` (loading/data/error pattern)
/// 
/// **State Pattern:**
/// - `AsyncValue.loading()`: Operation in progress
/// - `AsyncValue.data(T)`: Operation succeeded with data
/// - `AsyncValue.error(e, stackTrace)`: Operation failed
/// 
/// **Example:**
/// ```dart
/// class TutorListViewModel extends BaseViewModel<List<Tutor>> {
///   @override
///   Future<List<Tutor>> build() async {
///     return await ref.read(tutorRepositoryProvider).getAllTutors();
///   }
/// }
/// ```
/// Base class for ViewModels with AsyncValue state (Riverpod 2.x)
/// 
/// **Note:** Riverpod 2.x không có AsyncNotifier, nên dùng StateNotifier với AsyncValue
abstract class BaseViewModel<T> extends StateNotifier<AsyncValue<T>> {
  BaseViewModel() : super(const AsyncValue.loading());
  /// Initialize method - must be called by provider factory
  /// 
  /// **Purpose:**
  /// - Called when provider is first accessed
  /// - Should return the initial data for this ViewModel
  /// - Typically contains async operations (API calls, database queries)
  /// 
  /// **Returns:**
  /// - `Future<T>`: The initial data for this ViewModel
  /// 
  /// **Example:**
  /// ```dart
  /// Future<List<Tutor>> initialize() async {
  ///   return await repository.getTutors();
  /// }
  /// ```
  Future<T> initialize() async {
    throw UnimplementedError('initialize() must be implemented by subclass');
  }

  /// Execute an async action with automatic loading/error handling
  /// 
  /// **Purpose:**
  /// - Wraps async operations with automatic state management
  /// - Sets loading state before execution
  /// - Sets data state on success
  /// - Sets error state on failure
  /// 
  /// **Parameters:**
  /// - `action`: Async function that returns data of type T
  /// 
  /// **State Transitions:**
  /// - Before: Current state
  /// - During: `AsyncValue.loading()`
  /// - Success: `AsyncValue.data(result)`
  /// - Error: `AsyncValue.error(e, stackTrace)`
  /// 
  /// **Example:**
  /// ```dart
  /// await execute(() async {
  ///   return await repository.refreshData();
  /// });
  /// ```
  /// 
  /// **Note:** This method automatically handles state transitions.
  /// No need to manually set loading/error states.
  Future<void> execute(Future<T> Function() action) async {
    state = const AsyncValue.loading();
    try {
      final result = await action();
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Reset state to loading (useful for refresh operations)
  /// 
  /// **Purpose:**
  /// - Resets ViewModel state to loading
  /// - Useful when you want to trigger a rebuild/refetch
  /// - Typically called before refreshing data
  /// 
  /// **Example:**
  /// ```dart
  /// void refresh() {
  ///   reset();
  ///   // build() will be called again automatically
  /// }
  /// ```
  void reset() {
    state = const AsyncValue.loading();
  }

  /// Check if current state is loading
  /// 
  /// **Returns:**
  /// - `bool`: true if state is loading, false otherwise
  /// 
  /// **Usage:**
  /// ```dart
  /// if (viewModel.isLoading) {
  ///   return CircularProgressIndicator();
  /// }
  /// ```
  bool get isLoading => state.isLoading;

  /// Check if current state has an error
  /// 
  /// **Returns:**
  /// - `bool`: true if state has error, false otherwise
  /// 
  /// **Usage:**
  /// ```dart
  /// if (viewModel.hasError) {
  ///   return ErrorWidget(viewModel.errorMessage);
  /// }
  /// ```
  bool get hasError => state.hasError;

  /// Get error message if state has error
  /// 
  /// **Returns:**
  /// - `String?`: Error message string, or null if no error
  /// 
  /// **Usage:**
  /// ```dart
  /// if (viewModel.hasError) {
  ///   showError(viewModel.errorMessage ?? 'Unknown error');
  /// }
  /// ```
  String? get errorMessage => state.hasError ? state.error.toString() : null;

  /// Get data from current state if available
  /// 
  /// **Returns:**
  /// - `T?`: Data value if state is data, null otherwise
  /// 
  /// **Usage:**
  /// ```dart
  /// final tutors = viewModel.data;
  /// if (tutors != null) {
  ///   return TutorList(tutors: tutors);
  /// }
  /// ```
  /// 
  /// **Note:** Returns null if state is loading or error.
  /// Use `state.when()` for more control over different states.
  T? get data {
    return state.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
  }
}

/// Base class for ViewModels with custom state (not AsyncValue)
/// 
/// **Purpose:**
/// - Provides base for ViewModels that manage custom state classes
/// - Uses Riverpod 3.x Notifier pattern
/// - State is managed manually (not automatic like AsyncValue)
/// 
/// **When to use:**
/// - When you need custom state class (e.g., `BookingState`, `SearchState`)
/// - When you want full control over state transitions
/// - When state is not just loading/data/error pattern
/// 
/// **State Management:**
/// - State is accessed via `state` getter/setter
/// - State changes trigger UI rebuilds automatically
/// - Use `copyWith()` pattern for immutable state updates
/// 
/// **Example:**
/// ```dart
/// class BookingViewModel extends BaseStateNotifier<BookingState> {
///   @override
///   BookingState build() => BookingState.initial();
///   
///   void selectDate(DateTime date) {
///     state = state.copyWith(selectedDate: date);
///   }
/// }
/// ```
/// 
/// **Resource Cleanup:**
/// - Use `ref.onDispose()` in `build()` method to cleanup resources
/// - Called automatically when provider is disposed (autoDispose)
/// 
/// **Example cleanup:**
/// ```dart
/// @override
/// SearchState build() {
///   ref.onDispose(() {
///     _debounceTimer?.cancel(); // Cleanup timer
///   });
///   return SearchState.initial();
/// }
/// ```
/// Base class for ViewModels with custom state (Riverpod 2.x)
/// 
/// **Purpose:**
/// - Provides base for ViewModels that manage custom state classes
/// - Uses Riverpod 2.x StateNotifier pattern
/// - State is managed manually
/// 
/// **When to use:**
/// - When you need custom state class (e.g., `BookingState`, `SearchState`)
/// - When you want full control over state transitions
/// - When state is not just loading/data/error pattern
/// 
/// **State Management:**
/// - State is accessed via `state` getter/setter
/// - State changes trigger UI rebuilds automatically
/// - Use `copyWith()` pattern for immutable state updates
/// 
/// **Example:**
/// ```dart
/// class BookingViewModel extends BaseStateNotifier<BookingState> {
///   final Ref ref;
///   
///   BookingViewModel(this.ref) : super(BookingState.initial());
///   
///   void selectDate(DateTime date) {
///     state = state.copyWith(selectedDate: date);
///   }
/// }
/// ```
abstract class BaseStateNotifier<T> extends StateNotifier<T> {
  /// Ref for accessing other providers
  /// 
  /// **Purpose:**
  /// - Allows ViewModel to read other providers
  /// - Required for Riverpod 2.x StateNotifier
  /// 
  /// **Usage:**
  /// ```dart
  /// ref.read(someProvider)
  /// ref.invalidate(someProvider)
  /// ```
  final Ref ref;
  
  /// Constructor - must call super with initial state
  /// 
  /// **Parameters:**
  /// - `ref`: Ref for accessing providers
  /// - `initialState`: Initial state value
  /// 
  /// **Example:**
  /// ```dart
  /// BookingViewModel(Ref ref) : this.ref = ref, super(BookingState.initial());
  /// ```
  BaseStateNotifier(this.ref, T initialState) : super(initialState);
}

