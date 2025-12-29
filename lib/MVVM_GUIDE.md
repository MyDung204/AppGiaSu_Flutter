# 📘 HƯỚNG DẪN MVVM PATTERN TRONG DỰ ÁN

## 🎯 Tổng quan

Dự án đã được refactor để sử dụng **MVVM (Model-View-ViewModel)** pattern với **Riverpod** làm state management.

## 🏗️ Kiến trúc

```
lib/features/[feature]/
  ├── data/                    # Data layer
  │   ├── [feature]_repository.dart
  │   └── [feature]_provider.dart
  ├── domain/                  # Domain layer
  │   ├── models/
  │   │   ├── [model].dart
  │   │   └── [feature]_state.dart  # State class
  │   └── use_cases/           # (Future: Use cases)
  └── presentation/            # Presentation layer
      ├── view_models/         # ViewModel layer
      │   └── [feature]_view_model.dart
      ├── views/               # View layer (Widgets)
      │   └── [feature]_screen.dart
      └── widgets/              # Reusable widgets
```

## 📋 Components

### 1. Base Classes

#### `BaseViewModel<T>` và `BaseStateNotifier<T>`

```dart
// lib/core/base/base_view_model.dart

// Cho AsyncValue state
abstract class BaseViewModel<T> extends StateNotifier<AsyncValue<T>>

// Cho custom state
abstract class BaseStateNotifier<T> extends StateNotifier<T>
```

**Sử dụng:**
- `BaseViewModel`: Khi state là `AsyncValue<T>` (loading/data/error)
- `BaseStateNotifier`: Khi state là custom class

### 2. State Classes

State classes chứa tất cả state của feature:

```dart
// lib/features/booking/domain/models/booking_state.dart

class BookingState {
  final BookingStatus status;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String? bookingId;
  final String? errorMessage;
  final bool isLoading;

  // Factory constructor
  factory BookingState.initial() => ...;

  // CopyWith method
  BookingState copyWith({...}) => ...;
}

enum BookingStatus {
  idle, processing, locking, confirming, success, error
}
```

**Best practices:**
- ✅ Immutable state (final fields)
- ✅ Factory constructor cho initial state
- ✅ `copyWith` method cho state updates
- ✅ Computed properties (getters) cho derived state

### 3. ViewModels

ViewModels chứa business logic và quản lý state:

```dart
// lib/features/booking/presentation/view_models/booking_view_model.dart

class BookingViewModel extends BaseStateNotifier<BookingState> {
  final Ref ref;
  final Tutor tutor;

  BookingViewModel(this.ref, this.tutor) 
    : super(BookingState.initial());

  // Actions
  void selectDate(DateTime date) { ... }
  void selectTimeSlot(String timeSlot) { ... }
  Future<void> confirmBooking() async { ... }
}
```

**Provider:**
```dart
final bookingViewModelProvider = 
  StateNotifierProvider.autoDispose
    .family<BookingViewModel, BookingState, Tutor>(
  (ref, tutor) => BookingViewModel(ref, tutor),
);
```

**Best practices:**
- ✅ ViewModel extends `BaseStateNotifier<StateClass>`
- ✅ Business logic trong ViewModel, không trong Widget
- ✅ State updates qua `state = state.copyWith(...)`
- ✅ Async operations với proper error handling

### 4. Views (Widgets)

Views chỉ render UI và gọi ViewModel methods:

```dart
// lib/features/booking/presentation/booking_screen.dart

class BookingScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(bookingViewModelProvider(widget.tutor));
    final viewModelNotifier = ref.read(bookingViewModelProvider(widget.tutor).notifier);

    // Handle state changes
    if (viewModel.status == BookingStatus.success) {
      // Show success dialog
    }

    // Render UI
    return Scaffold(
      body: ...,
      // Call ViewModel methods on user actions
      onPressed: () => viewModelNotifier.confirmBooking(),
    );
  }
}
```

**Best practices:**
- ✅ Widget chỉ render UI
- ✅ Watch ViewModel state để rebuild
- ✅ Read ViewModel notifier để call actions
- ✅ Handle state changes (success/error) trong `build` hoặc callbacks

## 🔄 Data Flow

```
User Action
    ↓
View (Widget)
    ↓
ViewModel (Business Logic)
    ↓
Repository (Data Access)
    ↓
API/Database
    ↓
Repository
    ↓
ViewModel (Update State)
    ↓
View (Rebuild)
```

## 📝 Examples

### Example 1: Booking Feature

**State:**
```dart
class BookingState {
  final BookingStatus status;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  // ...
}
```

**ViewModel:**
```dart
class BookingViewModel extends BaseStateNotifier<BookingState> {
  Future<void> confirmBooking() async {
    state = state.copyWith(status: BookingStatus.processing);
    try {
      // Business logic
      await _repository.lockSlot(...);
      await _repository.confirmBooking(...);
      state = state.copyWith(status: BookingStatus.success);
    } catch (e) {
      state = state.copyWith(status: BookingStatus.error, errorMessage: e.toString());
    }
  }
}
```

**View:**
```dart
class BookingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(bookingViewModelProvider(tutor));
    
    return ElevatedButton(
      onPressed: () => ref.read(bookingViewModelProvider(tutor).notifier).confirmBooking(),
      child: viewModel.isLoading ? CircularProgressIndicator() : Text('Confirm'),
    );
  }
}
```

### Example 2: Search Feature

**State:**
```dart
class SearchState {
  final String query;
  final SearchFilter? filter;
  final bool isFilterInitialized;
}
```

**ViewModel:**
```dart
class SearchViewModel extends BaseStateNotifier<SearchState> {
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }
  
  void applyFilter({...}) {
    final newFilter = SearchFilter(...);
    state = state.copyWith(filter: newFilter);
  }
}
```

## ✅ Migration Checklist

Khi migrate một feature sang MVVM:

- [ ] Tạo State class với tất cả state fields
- [ ] Tạo ViewModel extends `BaseStateNotifier<StateClass>`
- [ ] Di chuyển business logic từ Widget sang ViewModel
- [ ] Tạo Provider cho ViewModel
- [ ] Refactor Widget để chỉ render UI
- [ ] Handle state changes (success/error) trong Widget
- [ ] Test ViewModel với unit tests
- [ ] Update documentation

## 🧪 Testing

### Unit Test ViewModel:

```dart
void main() {
  test('confirmBooking should update state to success', () async {
    final viewModel = BookingViewModel(mockRef, mockTutor);
    
    await viewModel.confirmBooking();
    
    expect(viewModel.state.status, BookingStatus.success);
  });
}
```

## 🚫 Anti-patterns (Tránh)

❌ **Business logic trong Widget:**
```dart
// ❌ SAI
void _onConfirm() async {
  await apiClient.post(...);
  await chatRepository.sendMessage(...);
}

// ✅ ĐÚNG
void _onConfirm() {
  viewModel.confirmBooking();
}
```

❌ **State trong Widget:**
```dart
// ❌ SAI
class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate; // State trong Widget
}

// ✅ ĐÚNG
class BookingViewModel extends BaseStateNotifier<BookingState> {
  // State trong ViewModel
}
```

❌ **Direct repository calls từ Widget:**
```dart
// ❌ SAI
ref.read(bookingRepositoryProvider).lockSlot(...);

// ✅ ĐÚNG
ref.read(bookingViewModelProvider.notifier).confirmBooking();
```

## 📚 Resources

- [Riverpod Documentation](https://riverpod.dev/)
- [StateNotifier Pattern](https://riverpod.dev/docs/concepts/about_state_notifier)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

## 🎯 Kết luận

MVVM pattern giúp:
- ✅ Tách biệt concerns rõ ràng
- ✅ Dễ test hơn (test ViewModel thay vì Widget)
- ✅ Code maintainable và scalable
- ✅ Reusable business logic

**Lưu ý:** Không phải tất cả screens đều cần ViewModel. Screens đơn giản (chỉ hiển thị data) có thể giữ nguyên.



