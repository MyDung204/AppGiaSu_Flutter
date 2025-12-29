# 🔄 HƯỚNG DẪN KHÔI PHỤC DỮ LIỆU

## ⚠️ Lưu ý quan trọng

**`php artisan migrate:fresh` đã XÓA TẤT CẢ dữ liệu và không thể khôi phục nếu không có backup!**

Tuy nhiên, bạn có thể **seed lại dữ liệu mẫu** từ seeders.

---

## ✅ Cách khôi phục dữ liệu mẫu

### Bước 1: Chạy seeders để tạo lại dữ liệu mẫu

```bash
cd D:\api-tutor
php artisan db:seed
```

**Lưu ý:** Nếu gặp lỗi "Duplicate entry", nghĩa là dữ liệu đã được seed rồi. Điều này là bình thường!

Hoặc seed từng seeder cụ thể:

```bash
# Seed tất cả (khuyến nghị)
php artisan db:seed

# Hoặc seed DatabaseSeeder riêng (tạo 3 users mặc định)
php artisan db:seed --class=DatabaseSeeder

# Hoặc seed từng phần
php artisan db:seed --class=TutorSeeder
php artisan db:seed --class=StudentSeeder
php artisan db:seed --class=WalletSeeder
php artisan db:seed --class=DataPopulationSeeder
```

### Bước 2: Kiểm tra dữ liệu đã được tạo

```bash
php artisan tinker
```

Sau đó:
```php
\App\Models\User::count();  // Đếm số users
\App\Models\Tutor::count(); // Đếm số tutors
\App\Models\User::all(['id', 'name', 'email', 'role']); // Xem danh sách users
```

---

## 📋 Dữ liệu sẽ được tạo lại

Sau khi chạy `php artisan db:seed`, bạn sẽ có:

### Users mặc định:
- ✅ `admin@gmail.com` / `123456` (Admin)
- ✅ `tutor@gmail.com` / `123456` (Tutor)
- ✅ `student@gmail.com` / `123456` (Student)

### Tutors được tạo tự động:
- ✅ 30 tutors: `tutor1@example.com` → `tutor30@example.com` / `123456`
- ✅ 5 pending tutors: `pending_tutor1@example.com` → `pending_tutor5@example.com` / `123456`

### Students được tạo tự động:
- ✅ 20 students: `student1@gmail.com` → `student20@gmail.com` / `123456`

### Dữ liệu khác:
- ✅ Wallets cho tất cả users (5,000,000 VND mỗi user)
- ✅ Transactions mẫu
- ✅ Bookings mẫu (upcoming, completed)
- ✅ Conversations và Messages
- ✅ Courses và Study Groups
- ✅ Questions và Answers
- ✅ Reviews
- ✅ Reports và Audit Logs

---

## 🔄 Nếu muốn reset hoàn toàn và seed lại

```bash
cd D:\api-tutor
php artisan migrate:fresh --seed
```

Lệnh này sẽ:
1. Xóa tất cả tables
2. Chạy lại migrations
3. Chạy tất cả seeders

---

## 💾 Backup trong tương lai

Để tránh mất dữ liệu, hãy backup database trước khi chạy `migrate:fresh`:

### Cách 1: Export database (MySQL)

```bash
# Windows (nếu có MySQL trong PATH)
mysqldump -u root -p api_tutor > backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# Hoặc dùng full path (XAMPP)
"C:\xampp\mysql\bin\mysqldump.exe" -u root -p api_tutor > backup.sql
```

### Cách 2: Export từ phpMyAdmin

1. Mở phpMyAdmin (http://localhost/phpmyadmin)
2. Chọn database `api_tutor`
3. Click tab "Export"
4. Chọn "Quick" hoặc "Custom"
5. Click "Go" để download file `.sql`

### Cách 3: Dùng Laravel Backup Package

```bash
composer require spatie/laravel-backup
php artisan vendor:publish --provider="Spatie\Backup\BackupServiceProvider"
php artisan backup:run
```

---

## 🔧 Khôi phục từ backup

### Nếu có file backup SQL:

```bash
# MySQL command line
mysql -u root -p api_tutor < backup.sql

# Hoặc từ phpMyAdmin:
# 1. Chọn database api_tutor
# 2. Click tab "Import"
# 3. Chọn file backup.sql
# 4. Click "Go"
```

---

## ⚠️ Lưu ý

1. **Không thể khôi phục dữ liệu thực tế** nếu không có backup
2. **Chỉ có thể seed lại dữ liệu mẫu** từ seeders
3. **Luôn backup trước** khi chạy `migrate:fresh` trong tương lai
4. **Dữ liệu được seed lại** sẽ là dữ liệu mẫu, không phải dữ liệu thực tế của bạn

---

## 🚀 Lệnh nhanh để seed lại

```bash
cd D:\api-tutor
php artisan db:seed
```

Sau đó test login với:
- Email: `admin@gmail.com`
- Password: `123456`

---

## ✅ Kết quả sau khi seed

Bạn sẽ có:
- **~58 users** (3 mặc định + 30 tutors + 5 pending tutors + 20 students)
- **35 tutors** (30 active + 5 pending)
- **Wallets** cho tất cả users
- **Bookings, Chats, Courses, Questions, Reviews** mẫu
