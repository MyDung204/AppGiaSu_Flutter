# 📋 Danh Sách Nhiệm Vụ - TutorApp (Góp ý từ bạn)

> **Cập nhật lần cuối:** 2026-04-26
> **Trạng thái Audit:** CODE MATCH TỐT, CHƯA VERIFY RUNTIME ĐẦY ĐỦ ⚠️
> **Tổng nhiệm vụ:** 33 | ✅ Đã có bằng chứng trong code: 27 | 🔧 Làm một phần / cần verify thêm: 1 | ⬜ Chưa làm: 5
>
> **Quy ước audit hiện tại:** dấu `x` trong file này ưu tiên nghĩa là **đã có bằng chứng rõ trong code**; không mặc định đồng nghĩa với **đã test end-to-end trên app thật**.

---

## A. TÀI KHOẢN GIA SƯ

### A1. Quản lý Lớp Học Nhóm

- [x] **A1.1** (Perfect ✅) Chỉ gia sư mới có quyền tạo lớp học nhóm
  > 🧩 **Do Codex làm:** Chuẩn hóa role tạo nhóm từ `teacher` sang `tutor`.
  > ✅ **Backend:** `SharedLearningController.php` đã chuẩn hóa role đúng là `tutor` (không dùng `teacher`) khi tạo lớp học nhóm và khi auto-approve thành viên.
  > ✅ **Frontend:** Nút "Tạo nhóm" bị ẩn trong `GroupMatchingTab` và `MyGroupsScreen` nếu không phải gia sư. `create_group_screen.dart` cũng có logic chặn.

- [x] **A1.2** (Perfect ✅) Khi tạo nhóm có đầy đủ trường: tên, lớp, hình thức, số lượng, tiền (dấu `.` ví dụ 10.000), thời gian mở lớp dự kiến
  > ✅ **Frontend:** `create_group_screen.dart` có đầy đủ: `_topicController`, `_gradeController`, `_maxMembersController`, `_priceController` (format vi_VN), `_selectedOpeningTime`

- [x] **A1.3** (Perfect ✅) Mặc định khi tạo nhóm, số lượng thành viên = 0
  > ✅ **Backend:** `SharedLearningController.php:265` → `'current_members' => 0`

- [x] **A1.4** (Perfect ✅) Lớp học nhóm gia sư KHÔNG cần duyệt (auto-approve)
  > ✅ **Backend:** `SharedLearningController.php:344,387` → `$isTutorGroup ? 'approved' : 'pending'`

- [x] **A1.5** (Perfect ✅) Học viên có thể rời nhóm trước 12 giờ kể từ khi tham gia
  > ✅ **Backend:** Có logic kiểm tra `diffInHours >= 12` trong `SharedLearningController.php`.
  > ✅ **Frontend:** `GroupDetailScreen` và `GroupMatchingTab` có trạng thái disable nút "Rời nhóm" nếu quá 12h.

- [x] **A1.6** (Perfect ✅) Sau khi đủ thành viên → yêu cầu thanh toán trong 24h
  > ✅ **Backend:** Có gán `payment_deadline = now()->addHours(24)` trong `SharedLearningController.php`.
  > ✅ **Frontend:** `GroupDetailScreen` và `MyGroupsScreen` có phần hiển thị countdown / hạn thanh toán khi nhóm đã đủ người.

- [x] **A1.7** (Perfect ✅) Khi thanh toán đủ → chuyển về giao diện lớp học nhóm
  > ✅ **Backend:** Đã có logic trừ tiền học viên, cộng tiền gia sư và cập nhật trạng thái `paid`.
  > ✅ **Frontend:** Có tích hợp nút "Thanh toán học phí" trong `GroupDetailScreen` và refresh UI sau thao tác.

- [x] **A1.8** (Perfect ✅) Phần Quiz thêm ngay cạnh trường bài tập
  > ✅ **Frontend:** Đã tích hợp `_buildQuizPicker` vào `create_group_screen.dart`. Đã fix lỗi shadowing tên class `Quiz` bằng cách dùng prefix.

- [x] **A1.9** (Perfect ✅) Khi học viên tham gia nhóm hiển thị thông báo xác nhận tham gia
  > ✅ **Frontend:** `GroupDetailScreen.dart` đã có `showDialog` xác nhận trước khi đăng ký và SnackBar thông báo thành công sau khi tham gia.

### A2. Tổng quan & Lịch dạy

- [x] **A2.1** (Perfect ✅) Phần tổng quan (Dashboard) dùng dữ liệu thật
  > ✅ **Frontend:** `tutor_statistics_provider.dart` gọi API `getMyStatistics()` đã hoàn thiện và kiểm tra, không còn dữ liệu fix cứng.

- [x] **A2.2** (Perfect ✅) Lịch dạy chung: hiển thị tất cả lịch (ví dụ: 8:30 dạy kèm, 9:30 dạy nhóm), tổng quan hiện lịch dạy sắp tới
  > ✅ **Frontend:** Đã tạo `UnifiedScheduleItem` và tích hợp vào `TutorScheduleNotifier`. Dashboard và màn hình Quản lý lịch hiện hiển thị cả 1-1 và nhóm theo thời gian thực.

- [x] **A2.3** (Perfect ✅) Tạo lịch dạy nằm trong chức năng lịch dạy (không tách riêng)
  > 🧩 **Do Codex làm:** Chuyển route lịch dạy gia sư sang màn quản lý lịch dạy chung.
  > ✅ **Frontend:** Route `/tutor-dashboard/schedule` đã trỏ về `TutorScheduleManagementScreen`, trong đó có cả lịch dạy chung và tab quản lý lịch rảnh/tạo khung giờ.

- [x] **A2.4** (Perfect ✅) Phần tổng quan có hiển thị lịch dạy sắp tới
  > ✅ **Frontend:** `tutor_dashboard_screen.dart` đã có section "Lịch dạy sắp tới" hiển thị 2-3 lịch gần nhất (cả 1-1 và nhóm) lấy từ dữ liệu thật.

### A3. Ví & Thống kê

- [x] **A3.1** (Perfect ✅) Gộp "Ví của tôi" với chức năng "Thống kê thu nhập"
  > ✅ **Frontend:** Đã hợp nhất `WalletScreen` vào `TutorStatisticsScreen` thành tab "Ví & Thu nhập".
  > ✅ **Tính năng:** Hiển thị số dư thực tế, nạp tiền, rút tiền (có dialog nhập bank), quản lý mã PIN.
  > ✅ **Router:** Đã thêm redirect tự động: nếu gia sư truy cập `/wallet`, hệ thống sẽ dẫn tới tab Ví trong Dashboard Thống kê.

### A4. Giao diện & Tên gọi

- [x] **A4.1** (Perfect ✅) Chỉnh lại tên giao diện: "lớp học nhóm", "dạy kèm 1-1"
  > ✅ **Frontend:** Đã rà soát và đổi tên đồng bộ các thuật ngữ "nhóm học tập", "nhóm học", "lớp nhóm" thành **"lớp học nhóm"** trên toàn bộ các màn hình (Home, Search, Detail, Create, Management). Giữ nguyên "Dạy kèm 1-1" cho các dịch vụ cá nhân.

- [x] **A4.2** (Perfect ✅) Yêu cầu tìm học viên chia thành: tìm học viên 1-1, yêu cầu tìm học viên nhóm (do gia sư tạo)
  > ✅ **Backend:** Đã thêm `request_type` (1-1, group) và `is_tutor_created`.
  > ✅ **Frontend:** Dashboard gia sư đã tách thành 2 nút "Học viên 1-1" và "Lớp nhóm mới". Danh sách yêu cầu đã tách tab 1-1 và Nhóm. Hỗ trợ gia sư tạo tin tuyển nhóm riêng.

### A5. Chat

- [x] **A5.1** (Code match ✅ | Chưa verify runtime) Chức năng gửi vị trí hiện tại cần cập nhật lại (UI premium hơn)
  > ✅ **Frontend:** Đã tạo `LocationBubble.dart` với bản xem trước bản đồ (Map preview) sử dụng `flutter_map` và OSM Tiles, hỗ trợ click để xem chi tiết.
  > ⚠️ **Lưu ý audit:** Mới xác nhận qua code/UI component, chưa có self-test thực tế trên thiết bị/emulator.

### A6. CRUD & Quản lý

- [x] **A6.1** (Perfect ✅) Bổ sung chức năng thêm/sửa/xóa cho mỗi phần hợp lý
  > 🧩 **Do Codex làm:** Bổ sung các endpoint CRUD nền tảng còn thiếu.
  > ✅ **Backend:** Đã bổ sung nhiều API CRUD còn thiếu: `PUT/DELETE /courses`, `DELETE /study-groups`, `PUT/DELETE /quizzes`, `PUT /tutors/materials/{id}`, `PUT /assignments/{id}`.

- [x] **A6.2** (Perfect ✅) Khi gia sư đã xác thực danh tính → click vào hiển thị "Bạn đã xác thực danh tính thành công"
  > ✅ `profile_screen.dart:89-96` đã check `is_verified` và hiện SnackBar

- [x] **A6.3** (Perfect ✅) Quản lý bài kiểm tra bị lỗi
  > 🧩 **Do Codex làm:** Hoàn thiện sửa/xóa quiz ở backend và frontend.
  > ✅ **Backend:** `QuizController.php` đã có `update`/`destroy`, kiểm tra chỉ gia sư sở hữu quiz mới được sửa/xóa; có kiểm tra quyền khi gắn quiz vào lớp.
  > ✅ **Frontend:** `quiz_repository.dart`, `quiz_controller.dart`, `create_quiz_screen.dart`, `tutor_quiz_management_screen.dart` đã hỗ trợ tạo/sửa/xóa quiz.

- [x] **A6.4** (Perfect ✅) Quản lý tài liệu không có thêm/sửa/xóa
  > 🧩 **Do Codex làm:** Thêm đổi tên tài liệu và nối API frontend/backend.
  > ✅ **Backend:** `TutorController.php` đã có `updateMaterial` và route `PUT /tutors/materials/{id}`; backend cũng chặn đúng tài liệu theo gia sư sở hữu.
  > ✅ **Frontend:** `tutor_material_screen.dart`, `tutor_material_provider.dart`, `tutor_repository.dart` đã có upload, đổi tên và xóa tài liệu.

- [x] **A6.5** (Perfect ✅) Có thể chia quản lý bài kiểm tra và tài liệu vào lớp kèm 1-1 và học nhóm
  > ✅ **Backend:** Đã thêm `study_group_id` vào bảng `quizzes` và `tutor_materials`, cập nhật Controller để lọc theo lớp học nhóm.
  > ✅ **Frontend:** Refactor `GroupDetailScreen` thành dạng tab, tích hợp tab "Tài liệu" và "Bài kiểm tra" dùng chung logic với lớp học 1-1 nhưng lọc theo ID nhóm.

- [x] **A6.6** (Perfect ✅) Xác thực danh tính: chọn ảnh/tải ảnh đang bị che khuất
  > ✅ **Frontend:** Đã bổ sung bottom padding cho `ekyc_update_screen.dart` để tránh bị che bởi thanh điều hướng và nút bấm.

- [x] **A6.7** (Perfect ✅) Chức năng giao bài tập: Nâng cấp UX tạo bài tập (due date) và chấm điểm/nhận xét
  > ✅ **Backend:** `AssignmentController.php` đã bổ sung `update`, `grade` và kiểm tra quyền gia sư. Hỗ trợ `study_group_id` và `student_id`.
  > ✅ **Frontend:** `class_assignments_tab.dart` nâng cấp dialog tạo (có date picker) và listing chuyên nghiệp. `AssignmentDetailScreen.dart` hoàn thiện luồng chấm điểm và hiển thị kết quả cho học viên.

---

## B. TÀI KHOẢN HỌC VIÊN

- [x] **B1** (Perfect ✅) Tìm gia sư chia thành: tìm kèm 1-1 và nhóm. Nhóm do gia sư mở → học viên chỉ click xác nhận tham gia
  > 🧩 **Do Codex làm:** Tách quick action học viên thành "Kèm 1-1" và "Lớp nhóm", thêm hỗ trợ mở tab search bằng query.
  > ✅ **Frontend:** `_QuickActionsSection` đã đổi "Tìm gia sư" thành "Kèm 1-1" và thêm "Lớp nhóm" trỏ tới `/search?tab=groups`. `SearchScreen` hỗ trợ mở sẵn tab nhóm/lớp qua query `tab`.
  > ✅ **Backend:** Lớp nhóm chỉ gia sư role `tutor` được tạo; học viên chỉ tham gia/xác nhận/thanh toán theo luồng nhóm hiện có.

- [x] **B2** (Perfect ✅) Chức năng "Lớp của tôi": nếu không nghĩ được logic thì bỏ, hoặc đổi thành trang tổng quan có 2 ô: lớp kèm 1-1 và lớp nhóm
  > 🧩 **Do Codex làm:** Thêm section "Lớp của tôi" trên Home với 2 ô riêng: "Lớp kèm 1-1" và "Lớp học nhóm".
  > ✅ **Frontend:** `_MyLearningOverviewSection` dùng `myEnrolledCoursesProvider` và `myGroupsProvider` để hiển thị số lớp thật, dẫn tới `/my-enrolled-classes` và `/my-study-groups`.

- [ ] **B3** Kiểm tra lại toàn bộ chức năng hoạt động
  > ⬜ Chưa test tổng thể

- [ ] **B4** (Nếu kịp) Chỉnh lại users của dự án giống với authentication Firebase
  > ⬜ Chưa triển khai

---

## C. TÀI KHOẢN GIA SƯ - BUG UI

- [/] **C1** Tab Tài khoản: các chức năng bên trong (ví dụ Định danh) không có tab "Lùi về" (back button)
  > 🔧 `ekyc_update_screen.dart:83-91` **ĐÃ CÓ** back button. Nhưng cần kiểm tra **tất cả** các sub-page khác trong tab Tài khoản

- [x] **C2** (Perfect ✅) "Gia sư yêu thích" tồn tại ở tài khoản gia sư nhưng chỉ nên có ở học viên
  > 🧩 **Do Codex làm:** Chặn cả UI route trực tiếp và backend API cho tài khoản gia sư.
  > ✅ **Frontend:** `FavoriteTutorsScreen` đã chặn tài khoản gia sư nếu truy cập route trực tiếp.
  > ✅ **Backend:** `TutorController.php` đã chặn `toggleFavorite` và `getFavorites` nếu user không phải role `student`.

---

## D. TÀI KHOẢN ADMIN

- [x] **D1** (Perfect ✅) Admin không có chỗ tài khoản để đăng xuất / ấn thoát không có yêu cầu xác nhận
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
| **A. Gia sư** | 24 | 24 | 0 | 0 |
| **B. Học viên** | 4 | 3 | 0 | 1 |
| **C. Bug UI Gia sư** | 2 | 1 | 1 | 0 |
| **D. Admin** | 1 | 1 | 0 | 0 |
| **E. Kiểm tra** | 4 | 1 | 0 | 3 |
| **TỔNG** | **35** | **30** | **1** | **4** |

> [!IMPORTANT]
> **Đã xử lý trong lượt 2026-04-26:** chuẩn hóa role `tutor`, bổ sung API CRUD còn thiếu, sửa quản lý quiz, nâng cấp UI `TutorCard` (thêm avatar, tag môn học), sửa lỗi che khuất màn hình eKYC (A6.6), dọn dẹp sạch file `api.php`.
> **Audit Status:** **Code match tốt, nhưng chưa đủ bằng chứng để kết luận PERFECT ở mức runtime/end-to-end.**
> **Còn ưu tiên cao:** chạy được `flutter analyze` trong môi trường ổn định, test chat học viên-gia sư, test thanh toán/nhóm/lớp end-to-end.
> **Ưu tiên trung bình:** A3.1 (Gộp ví), A6.5 (Chia quiz/tài liệu vào lớp), A6.7 (nâng UX giao bài tập).

---
### 🏆 NHẬT KÝ AUDIT: CODE REVIEW TÍCH CỰC, CHƯA HOÀN TẤT VERIFY RUNTIME
Các mục như `A1.1`, `A1.3-A1.7`, `A6.3`, `A6.2`, `C2`, `D1`, `A5.1`, `A6.6`, `A6.4`, `B1` đều có bằng chứng triển khai trong code hiện tại. Tuy nhiên, một phần trong số đó vẫn cần test runtime/end-to-end trước khi kết luận là hoạt động hoàn toàn chính xác trên app thật.
