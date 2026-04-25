# 📋 Danh Sách Nhiệm Vụ - TutorApp (Góp ý từ bạn)

> **Cập nhật lần cuối:** 2026-04-25
> **Tổng nhiệm vụ:** 27 | ✅ Đã xong: 12 | 🔧 Làm một phần: 1 | ⬜ Chưa làm: 14

---

## A. TÀI KHOẢN GIA SƯ

### A1. Quản lý Lớp Học Nhóm

- [x] **A1.1** Chỉ gia sư mới có quyền tạo lớp học nhóm
  > ✅ **Backend:** `SharedLearningController.php:247` kiểm tra `role !== 'teacher'` → trả 403
  > ✅ **Frontend:** Nút "Tạo nhóm" bị ẩn trong `GroupMatchingTab` và `MyGroupsScreen` nếu không phải gia sư. `create_group_screen.dart` cũng có logic chặn.

- [x] **A1.2** Khi tạo nhóm có đầy đủ trường: tên, lớp, hình thức, số lượng, tiền (dấu `.` ví dụ 10.000), thời gian mở lớp dự kiến
  > ✅ **Frontend:** `create_group_screen.dart` có đầy đủ: `_topicController`, `_gradeController`, `_maxMembersController`, `_priceController` (format vi_VN), `_selectedOpeningTime`

- [x] **A1.3** Mặc định khi tạo nhóm, số lượng thành viên = 0
  > ✅ **Backend:** `SharedLearningController.php:265` → `'current_members' => 0`

- [x] **A1.4** Lớp học nhóm gia sư KHÔNG cần duyệt (auto-approve)
  > ✅ **Backend:** `SharedLearningController.php:344,387` → `$isTutorGroup ? 'approved' : 'pending'`

- [x] **A1.5** Học viên có thể rời nhóm trước 12 giờ kể từ khi tham gia
  > ✅ **Backend:** `SharedLearningController.php:570-573` → kiểm tra `diffInHours >= 12`
  > ✅ **Frontend:** `GroupDetailScreen` và `GroupMatchingTab` đã disable nút "Rời nhóm" nếu quá 12h.

- [x] **A1.6** Sau khi đủ thành viên → yêu cầu thanh toán trong 24h
  > ✅ **Backend:** `SharedLearningController.php:353,397` → `'payment_deadline' => now()->addHours(24)`
  > ✅ **Frontend:** `GroupDetailScreen` và `MyGroupsScreen` hiển thị countdown / hạn thanh toán khi nhóm đã đủ người.

- [x] **A1.7** Khi thanh toán đủ → chuyển về giao diện lớp học nhóm
  > ✅ **Backend:** Đã có logic trừ tiền học viên, cộng tiền gia sư và cập nhật trạng thái `paid`.
  > ✅ **Frontend:** Tích hợp nút "Thanh toán học phí" trong `GroupDetailScreen`, tự động cập nhật UI sau khi thanh toán.

- [x] **A1.8** Phần Quiz thêm ngay cạnh trường bài tập
  > ✅ **Frontend:** Đã tích hợp `_buildQuizPicker` vào `create_group_screen.dart`. Đã fix lỗi shadowing tên class `Quiz` bằng cách dùng prefix.

### A2. Tổng quan & Lịch dạy

- [x] **A2.1** Phần tổng quan (Dashboard) dùng dữ liệu thật
  > ✅ **Frontend:** `tutor_statistics_provider.dart` gọi API `getMyStatistics()` đã hoàn thiện và kiểm tra, không còn dữ liệu fix cứng.

- [x] **A2.2** Lịch dạy chung: hiển thị tất cả lịch (ví dụ: 8:30 dạy kèm, 9:30 dạy nhóm), tổng quan hiện lịch dạy sắp tới
  > ✅ **Frontend:** Đã tạo `UnifiedScheduleItem` và tích hợp vào `TutorScheduleNotifier`. Dashboard và màn hình Quản lý lịch hiện hiển thị cả 1-1 và nhóm theo thời gian thực.

- [ ] **A2.3** Tạo lịch dạy nằm trong chức năng lịch dạy (không tách riêng)
  > ⬜ Chưa triển khai

### A3. Ví & Thống kê

- [ ] **A3.1** Gộp "Ví của tôi" với chức năng "Thống kê thu nhập"
  > ⬜ Hiện tại `wallet_screen.dart` và `tutor_statistics_screen.dart` là 2 màn hình riêng biệt

### A4. Giao diện & Tên gọi

- [ ] **A4.1** Chỉnh lại tên giao diện: "lớp học nhóm", "dạy kèm 1-1"
  > ⬜ Chưa rà soát và đổi tên đồng bộ

- [ ] **A4.2** Yêu cầu tìm học viên chia thành: tìm học viên 1-1, yêu cầu tìm học viên nhóm (do gia sư tạo)
  > ⬜ Chưa tách

### A5. Chat

- [x] **A5.1** Chức năng gửi vị trí hiện tại cần cập nhật lại (UI premium hơn)
  > ✅ **Frontend:** Đã tạo `LocationBubble.dart` với bản xem trước bản đồ (Map preview) sử dụng `flutter_map` và OSM Tiles, hỗ trợ click để xem chi tiết.

### A6. CRUD & Quản lý

- [ ] **A6.1** Bổ sung chức năng thêm/sửa/xóa cho mỗi phần hợp lý
  > ⬜ Cần rà soát toàn bộ

- [x] **A6.2** Khi gia sư đã xác thực danh tính → click vào hiển thị "Bạn đã xác thực danh tính thành công"
  > ✅ `profile_screen.dart:89-96` đã check `is_verified` và hiện SnackBar

- [/] **A6.3** Quản lý bài kiểm tra bị lỗi
  > 🔧 `tutor_quiz_management_screen.dart` tồn tại nhưng **edit quiz hiện show SnackBar "sẽ cập nhật sau"** (L128). Cần fix build errors trong `create_group_screen.dart` liên quan đến Quiz

- [ ] **A6.4** Quản lý tài liệu không có thêm/sửa/xóa
  > ⬜ `tutor_material_screen.dart` chỉ có upload (`_pickFile`), **không tìm thấy chức năng sửa/xóa**

- [ ] **A6.5** Có thể chia quản lý bài kiểm tra và tài liệu vào lớp kèm 1-1 và học nhóm
  > ⬜ Chưa triển khai (hiện chúng là trang riêng biệt)

- [ ] **A6.6** Xác thực danh tính: chọn ảnh/tải ảnh đang bị che khuất
  > ⬜ Cần kiểm tra UI `ekyc_update_screen.dart` trên thiết bị thật

- [ ] **A6.7** Chức năng giao bài tập còn sơ sài, cần cập nhật
  > ⬜ `class_assignments_tab.dart` và `assignment_list_widget.dart` tồn tại nhưng **cần nâng cấp UX**

---

## B. TÀI KHOẢN HỌC VIÊN

- [ ] **B1** Tìm gia sư chia thành: tìm kèm 1-1 và nhóm. Nhóm do gia sư mở → học viên chỉ click xác nhận tham gia
  > ⬜ Hiện tại `_QuickActionsSection` (`home_screen.dart:1079-1083`) có chung 1 nút "Tìm gia sư" → chưa tách

- [ ] **B2** Chức năng "Lớp của tôi": nếu không nghĩ được logic thì bỏ, hoặc đổi thành trang tổng quan có 2 ô: lớp kèm 1-1 và lớp nhóm
  > ⬜ Chưa có tính năng "Lớp của tôi" (search "lớp của tôi" → 0 kết quả)

- [ ] **B3** Kiểm tra lại toàn bộ chức năng hoạt động
  > ⬜ Chưa test tổng thể

- [ ] **B4** (Nếu kịp) Chỉnh lại users của dự án giống với authentication Firebase
  > ⬜ Chưa triển khai

---

## C. TÀI KHOẢN GIA SƯ - BUG UI

- [/] **C1** Tab Tài khoản: các chức năng bên trong (ví dụ Định danh) không có tab "Lùi về" (back button)
  > 🔧 `ekyc_update_screen.dart:83-91` **ĐÃ CÓ** back button. Nhưng cần kiểm tra **tất cả** các sub-page khác trong tab Tài khoản

- [ ] **C2** "Gia sư yêu thích" tồn tại ở tài khoản gia sư nhưng chỉ nên có ở học viên
  > ⬜ `profile_screen.dart:77-78` chỉ show cho `!isTutor` → **ĐÃ ĐÚNG logic**. Nhưng cần kiểm tra xem có route nào cho phép gia sư truy cập trực tiếp không

---

## D. TÀI KHOẢN ADMIN

- [x] **D1** Admin không có chỗ tài khoản để đăng xuất / ấn thoát không có yêu cầu xác nhận
  > ✅ `admin_dashboard_screen.dart:46-73` ĐÃ CÓ: nút logout trên AppBar với dialog xác nhận "Bạn có chắc chắn muốn đăng xuất?"

---

## E. KIỂM TRA TỔNG THỂ

- [ ] **E1** Test học viên 1 nhắn cho gia sư 1 xem tên hiển thị chat có đúng không
  > ⬜ Chưa test

- [ ] **E2** Đảm bảo sự liên kết: học kèm 1-1 → gia sư và học viên phải có, lớp nhóm cũng thế
  > ⬜ Chưa test

- [ ] **E3** Kiểm tra toàn bộ chức năng phải hoạt động, có liên kết
  > ⬜ Chưa test

- [ ] **E4** Self-test trên trình duyệt/emulator
  > ⬜ Chưa thực hiện

---

## 📊 Tóm Tắt Trạng Thái

| Nhóm | Tổng | ✅ Xong | 🔧 Một phần | ⬜ Chưa |
|------|------|---------|-------------|--------|
| **A. Gia sư** | 18 | 8 | 3 | 7 |
| **B. Học viên** | 4 | 0 | 0 | 4 |
| **C. Bug UI Gia sư** | 2 | 0 | 1 | 1 |
| **D. Admin** | 1 | 1 | 0 | 0 |
| **E. Kiểm tra** | 4 | 0 | 0 | 4 |
| **TỔNG** | **29** | **9** | **4** | **16** |

> [!IMPORTANT]
> **Ưu tiên cao nhất:** A1.8 (Fix lỗi compile Quiz), A5.1 (Chat location UI), B1 (Tách tìm gia sư 1-1/nhóm)
> **Ưu tiên trung bình:** A2.1-A2.3 (Dashboard & Lịch dạy), A3.1 (Gộp ví), A6.4 (CRUD tài liệu)
> **Ưu tiên thấp / tùy chọn:** B4 (Sync Firebase users), A6.5 (Chia quiz/tài liệu vào lớp)
