# 📋 KẾ HOẠCH CẬP NHẬT TỔNG THỂ

**Ngày bắt đầu:** 28/12/2024  
**Mục tiêu:** Sửa lỗi, cập nhật và bổ sung chức năng cho tất cả tài khoản

---

## ✅ ĐÃ HOÀN THÀNH (Phase 1)

### 1. **Sửa Lỗi Đặt Lịch Ngay (BookingViewModel)**
- ✅ **Vấn đề:** ProviderException - Tried to use notifier in uninitialized state
- ✅ **Nguyên nhân:** Gọi `initialize()` trong factory function, truy cập `state` trước khi `build()` được gọi
- ✅ **Giải pháp:** 
  - Truyền tutor vào constructor thay vì gọi `initialize()`
  - Khởi tạo state với tutor trong `build()` method
  - Xóa method `initialize()` không cần thiết

**Files đã sửa:**
- `lib/features/booking/presentation/view_models/booking_view_model.dart`

---

### 2. **Sửa Lỗi Góc Hỏi Đáp (Community Screen)**
- ✅ **Vấn đề:** Tab "Tất cả" OK, các tab khác hiển thị "không có kết quả" dù có dữ liệu
- ✅ **Nguyên nhân:** So sánh subject không phân biệt hoa thường
- ✅ **Giải pháp:**
  - Sử dụng `toLowerCase()` khi so sánh subject
  - Cải thiện empty state với icon và message rõ ràng hơn
  - Thêm filter theo subject trong search text

**Files đã sửa:**
- `lib/features/community/presentation/community_screen.dart`

---

### 3. **Sửa Lỗi Đăng Ký Lớp Học**
- ✅ **Vấn đề:** Đăng ký thất bại hoặc "đã tham gia" dù chưa đăng ký
- ✅ **Nguyên nhân:** 
  - Không có bảng `course_students` trong database
  - Backend không có method `joinCourse`
  - Frontend check enrollment status sai

- ✅ **Giải pháp:**
  1. **Tạo Migration:** `2024_01_01_000011_create_course_students_table.php`
  2. **Backend:**
     - Thêm method `joinCourse()` trong `SharedLearningController`
     - Thêm method `leaveCourse()` trong `SharedLearningController`
     - Thêm method `myCourses()` trong `SharedLearningController`
     - Cập nhật `indexCourses()` để trả về enrollment status
     - Thêm routes: `/courses/{id}/join`, `/courses/{id}/leave`, `/my-courses`
  3. **Frontend:**
     - Thêm field `isEnrolled` vào Course model
     - Cập nhật `Course.fromJson()` để parse `is_enrolled`
     - Sửa logic check enrollment trong `class_listing_tab.dart` và `class_detail_screen.dart`
     - Cải thiện error handling và loading states

**Files đã sửa:**
- `laravel_setup/database/migrations/2024_01_01_000011_create_course_students_table.php` (mới)
- `laravel_setup/app/Http/Controllers/Api/SharedLearningController.php`
- `laravel_setup/routes/api.php`
- `laravel_setup/app/Models/Course.php`
- `lib/features/group/domain/models/course.dart`
- `lib/features/group/data/shared_learning_repository.dart`
- `lib/features/search/presentation/widgets/class_listing_tab.dart`
- `lib/features/tutor_dashboard/presentation/class_detail_screen.dart`

---

## 🔄 ĐANG THỰC HIỆN (Phase 2)

### 4. **Cập Nhật Tài Khoản Học Viên**

#### 4.1. Các Trang Cần Cập Nhật:
- [ ] Home Screen - Đã có section yêu cầu tìm gia sư
- [ ] Search Screen - Đã có filter và debounce
- [ ] Booking Screen - Đã sửa lỗi
- [ ] Schedule Screen - Cần kiểm tra và cập nhật
- [ ] My Requests Screen - Cần kiểm tra
- [ ] My Classes Screen - Cần kiểm tra
- [ ] My Study Groups Screen - Cần kiểm tra
- [ ] Profile Screen - Cần kiểm tra
- [ ] eKYC Screen - Đã sửa SafeArea

#### 4.2. Chức Năng Cần Bổ Sung:
- [ ] Xem lịch học đã đặt
- [ ] Hủy lịch học
- [ ] Đánh giá gia sư sau buổi học
- [ ] Xem lịch sử đặt lịch
- [ ] Thanh toán (tích hợp payment gateway)
- [ ] Xem thông báo
- [ ] Quản lý ví tiền

---

### 5. **Cập Nhật Tài Khoản Admin**

#### 5.1. Các Trang Cần Cập Nhật:
- [ ] Admin Dashboard - Thống kê tổng quan
- [ ] Admin Users Screen - Quản lý users
- [ ] Admin Tutor Approval Screen - Duyệt gia sư
- [ ] Admin Reports Screen - Xử lý báo cáo

#### 5.2. Chức Năng Cần Bổ Sung:
- [ ] Thống kê real-time (số users, tutors, bookings, revenue)
- [ ] Tìm kiếm và filter users
- [ ] Ban/Unban users
- [ ] Xem chi tiết tutor profile khi duyệt
- [ ] Xem và download giấy tờ eKYC
- [ ] Xử lý báo cáo (resolve, reject)
- [ ] Audit logs (lịch sử thao tác)
- [ ] Quản lý categories/subjects
- [ ] Quản lý hệ thống (settings)

---

### 6. **Cập Nhật Tài Khoản Gia Sư**

#### 6.1. Các Trang Cần Cập Nhật:
- [ ] Tutor Dashboard - Tổng quan
- [ ] Create Class Screen - Tạo lớp học
- [ ] Class Detail Screen - Chi tiết lớp học
- [ ] My Classes Screen - Danh sách lớp học
- [ ] Tutor Tuition Screen - Lịch dạy
- [ ] Tutor Profile Screen - Hồ sơ gia sư

#### 6.2. Chức Năng Cần Bổ Sung:
- [ ] Xem lịch dạy (calendar view)
- [ ] Quản lý học viên trong lớp
- [ ] Duyệt/từ chối học viên đăng ký lớp
- [ ] Xem doanh thu
- [ ] Xem đánh giá từ học viên
- [ ] Cập nhật hồ sơ gia sư
- [ ] Quản lý lịch dạy (thêm/sửa/xóa time slots)
- [ ] Xem thông báo đặt lịch mới
- [ ] Chat với học viên

---

## 📝 YÊU CẦU CHUNG

### Code Quality:
- [x] Code clean và dễ đọc
- [x] Comments bằng tiếng Việt
- [ ] Logic đúng giữa các tài khoản
- [ ] Kiểm tra và test tất cả chức năng
- [ ] Tối ưu hiệu suất

### Database:
- [x] Tạo migration cho course_students
- [ ] Tạo seeder dữ liệu ảo nếu thiếu
- [ ] Kiểm tra tất cả relationships

### Testing:
- [ ] Test đặt lịch học
- [ ] Test đăng ký lớp học
- [ ] Test góc hỏi đáp
- [ ] Test các chức năng admin
- [ ] Test các chức năng gia sư

---

## 🚀 NEXT STEPS

1. **Hoàn thành Phase 2:** Cập nhật tài khoản học viên
2. **Phase 3:** Cập nhật tài khoản admin
3. **Phase 4:** Cập nhật tài khoản gia sư
4. **Phase 5:** Tạo seeder và test
5. **Phase 6:** Tối ưu hiệu suất

---

**Status:** 🟡 Đang thực hiện Phase 2






