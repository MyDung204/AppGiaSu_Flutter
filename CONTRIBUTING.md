# Hướng Dẫn Đóng Góp

Cảm ơn bạn đã đóng góp cho TutorApp. Dự án này là monorepo gồm:

- `Doantotnghiep/`: ứng dụng Flutter.
- `api-tutor/`: backend Laravel API.

## Quy Trình Làm Việc

1. Cập nhật nhánh chính trước khi làm việc:
   ```bash
   git checkout main
   git pull
   ```
2. Tạo nhánh mới theo phạm vi thay đổi:
   ```bash
   git checkout -b feature/ten-tinh-nang
   git checkout -b fix/ten-loi
   ```
3. Commit theo từng nhóm thay đổi nhỏ, message rõ nội dung.
4. Trước khi push, kiểm tra `git status` để chắc chắn không có file local, build artifact hoặc secret bị đưa vào commit.
5. Push nhánh và tạo Pull Request vào `main`.

## Quy Tắc Commit

Nên commit:

- Source code Flutter trong `Doantotnghiep/lib/`.
- Source code Laravel trong `api-tutor/app/`, `api-tutor/routes/`, `api-tutor/database/migrations/`.
- File cấu hình mẫu như `.env.example`.
- Gradle wrapper của Android:
  - `Doantotnghiep/android/gradlew`
  - `Doantotnghiep/android/gradlew.bat`
  - `Doantotnghiep/android/gradle/wrapper/gradle-wrapper.jar`

Không commit:

- `.env`, key, token, credential, file Firebase service account.
- `build/`, `.dart_tool/`, `.gradle/`, `.kotlin/`, `vendor/`, `node_modules/`.
- APK/AAB, log, cache, SQLite local database.
- File upload/test runtime trong `api-tutor/storage/app/public/`.
- Thư mục tạm `/scratch/`.

## Kiểm Tra Trước Khi Push

Chạy các lệnh sau ở root repo:

```bash
git status --short --ignored
git ls-files -ci --exclude-standard
```

Kỳ vọng:

- `git status --short` chỉ hiện source code, migration, tài liệu, hoặc file cấu hình cần commit.
- `git ls-files -ci --exclude-standard` không in ra gì. Nếu có file hiện ở đây, nghĩa là file đã tracked nhưng lại đang bị `.gitignore` bỏ qua, cần kiểm tra kỹ trước khi push.

## Kiểm Tra Flutter

Trong thư mục `Doantotnghiep/`:

```bash
flutter pub get
dart format lib test
flutter analyze
```

Nếu chỉ sửa một file nhỏ, có thể format file đó:

```bash
dart format lib/path/to/file.dart
```

## Kiểm Tra Laravel

Trong thư mục `api-tutor/`:

```bash
composer install
php artisan migrate
php artisan test
```

Kiểm tra nhanh cú pháp file PHP vừa sửa:

```bash
php -l app/Http/Controllers/Api/SomeController.php
```

## Quy Tắc Bảo Mật

- Không đưa file `.env` thật lên GitHub.
- Không commit `api-tutor/storage/app/firebase_credentials.json`.
- Không commit ảnh CCCD/eKYC, file bài nộp, ảnh chat hoặc dữ liệu người dùng trong `storage/app/public/`.
- Nếu lỡ commit secret, phải thu hồi secret đó ngay và tạo secret mới.

## Pull Request

PR nên có:

- Mô tả ngắn gọn thay đổi.
- Cách kiểm thử đã chạy.
- Ảnh chụp màn hình nếu thay đổi UI.
- Ghi chú migration nếu backend có migration mới.

Trước khi merge, hãy đảm bảo app chạy được ở môi trường local và không có file rác trong danh sách commit.
