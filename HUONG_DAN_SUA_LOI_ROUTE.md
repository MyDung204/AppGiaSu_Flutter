# 🔧 HƯỚNG DẪN SỬA LỖI ROUTE

## Lỗi: "The POST method is not supported for route api/course"

### Nguyên nhân:
- Route cache của Laravel chưa được clear
- Hoặc có vấn đề với route registration

### Giải pháp:

#### 1. Clear route cache (trong terminal Laravel):
```bash
cd laravel_setup
php artisan route:clear
php artisan route:cache
```

Hoặc nếu không có route cache:
```bash
php artisan route:clear
```

#### 2. Kiểm tra route đã được đăng ký:
```bash
php artisan route:list | grep courses
```

Bạn sẽ thấy:
```
POST   api/courses ................ SharedLearningController@storeCourse
```

#### 3. Nếu vẫn lỗi, kiểm tra:
- **Base URL trong frontend:** Đảm bảo đang gọi `/api/courses` (có prefix `/api`)
- **Authentication:** Đảm bảo đã đăng nhập và có token
- **Route file:** Kiểm tra `routes/api.php` có route `POST /courses`

### Route đã được đăng ký:
```php
// File: laravel_setup/routes/api.php
Route::middleware('auth:sanctum')->post('/courses', [SharedLearningController::class, 'storeCourse']);
```

### Kiểm tra frontend:
File: `lib/features/group/data/shared_learning_repository.dart`
```dart
final response = await _client.post('/courses', data: data);
```

Đảm bảo `_client` có base URL là `/api` hoặc endpoint đầy đủ là `/api/courses`.



