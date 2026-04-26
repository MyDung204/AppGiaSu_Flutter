# 📘 Hướng Dẫn Kiểm Thử Thủ Công Chi Tiết (Full Manual Test Guide)

Tài liệu này được đồng bộ 100% với file `mission.md` để giúp bạn kiểm tra toàn bộ các tính năng đã triển khai.

---

## 🔐 Thông Tin Đăng Nhập
- **Gia sư:** `tutor@gmail.com` / `123456`
- **Học viên:** `student@gmail.com` / `123456`
- **Admin:** `admin@gmail.com` / `123456`

---

## 👨‍🏫 A. TÀI KHOẢN GIA SƯ

### A1. Quản lý Lớp Học Nhóm
- **[A1.1] Kiểm tra quyền tạo nhóm:**
    - Đăng nhập bằng tài khoản Học viên -> Vào màn hình tìm kiếm/nhóm -> Xác nhận **KHÔNG** thấy nút "Tạo nhóm".
    - Đăng nhập bằng tài khoản Gia sư -> Vào tab "Học tập" -> Chọn "Lớp học nhóm" -> Xác nhận thấy nút "Tạo nhóm".
- **[A1.2] Các trường dữ liệu khi tạo nhóm:**
    - Nhấn "Tạo nhóm".
    - Kiểm tra có đủ: Tên chủ đề, Môn học, Lớp, Hình thức (Online/Offline), Số lượng (Max), Học phí, Thời gian mở lớp dự kiến.
    - **Quan trọng:** Nhập học phí (vd: 1500000) -> Xác nhận hiển thị định dạng `1.500.000` (có dấu chấm).
- **[A1.3] Số lượng thành viên mặc định:**
    - Sau khi nhấn "Tạo" -> Xem chi tiết nhóm vừa tạo -> Xác nhận "Số thành viên: 0".
- **[A1.4] Tự động duyệt (Auto-approve):**
    - Dùng máy khác/Trình duyệt ẩn danh đăng nhập Học viên -> Nhấn "Tham gia" nhóm của Gia sư vừa tạo.
    - Quay lại Gia sư -> Xem danh sách thành viên -> Xác nhận học viên đã ở trạng thái "Đã duyệt" (Approved) mà không cần nhấn nút duyệt.
- **[A1.5] Rời nhóm (Quy tắc 12h):**
    - Học viên nhấn "Rời nhóm" ngay sau khi tham gia -> Xác nhận rời được.
    - (Nếu có thể mock thời gian hệ thống) Sau 12h kể từ lúc tham gia -> Nút "Rời nhóm" phải bị ẩn hoặc báo lỗi không cho rời.
- **[A1.6] Đủ thành viên & Hạn thanh toán 24h:**
    - Thêm đủ số học viên tối đa vào nhóm.
    - Gia sư & Học viên vào xem chi tiết nhóm -> Xác nhận xuất hiện dòng thông báo "Hạn thanh toán còn lại: ... (countdown từ 24h)".
- **[A1.7] Sau khi thanh toán:**
    - Học viên nhấn "Thanh toán học phí" -> Trừ tiền ví.
    - Xác nhận giao diện nhóm của cả 2 bên chuyển sang chế độ "Lớp học" (Có tab Bài tập, Tài liệu, Chat nhóm).
- **[A1.8] Giao diện Quiz khi tạo nhóm:** Trong màn hình tạo nhóm, kiểm tra xem có nút chọn Bài kiểm tra (Quiz) bên cạnh phần Bài tập không.
- **[A1.9] Xác nhận tham gia:** Đăng nhập tài khoản Học viên, vào xem chi tiết một lớp nhóm, nhấn "Tham gia". App phải hiện Dialog hỏi xác nhận. Sau khi nhấn "Đăng ký", phải có SnackBar thông báo thành công.

### A2. Tổng quan & Lịch dạy
- **[A2.1] Dashboard Dữ liệu thật:** Đăng nhập Gia sư, kiểm tra các con số (Tổng thu nhập, Số lớp...) xem có thay đổi khi có hoạt động mới không (không được là số ảo cố định).
- **[A2.2] Lịch dạy chung:** Vào Tab "Lịch dạy", kiểm tra xem có hiển thị cả lịch dạy kèm 1-1 và lịch dạy lớp nhóm không.
- **[A2.3] Tạo lịch trong màn quản lý:**
    - Tại tab "Lịch dạy", vào phần "Quản lý khung giờ rảnh" -> Thử tạo một khung giờ mới.
    - Xác nhận lịch mới tạo hiển thị ngay tại đây.
- **[A2.4] Lịch sắp tới trên Dashboard:** Tại màn hình chính Gia sư, kiểm tra phần "Lịch dạy sắp tới" có hiển thị đúng các buổi học sắp diễn ra không.

### A3. Ví & Thống kê
- **[A3.1] Gộp Ví & Thống kê:**
    - Vào Tab "Tài khoản" -> Chọn "Ví & Thu nhập".
    - Xác nhận: Thấy biểu đồ thu nhập ở trên và các nút Nạp/Rút/Mã PIN ở dưới.
    - Thử nhấn "Rút tiền" -> Nhập số tài khoản ngân hàng -> Xác nhận lưu được thông tin.

### A4. Giao diện & Tên gọi
- **[A4.1] Đồng bộ thuật ngữ:**
    - Đi dạo quanh app (Search, Detail, Create) -> Xác nhận dùng đúng từ **"lớp học nhóm"** (không phải "nhóm học", "lớp nhóm").
- **[A4.2] Tách yêu cầu tìm học viên:**
    - Dashboard Gia sư -> Nhấn "Tìm học viên" -> Xác nhận có 2 tab/nút riêng: "Học viên 1-1" và "Yêu cầu tuyển nhóm".

### A5. Chat
- **[A5.1] Gửi vị trí Premium:**
    - Trong chat -> Nhấn dấu `+` -> "Gửi vị trí".
    - Xác nhận: Tin nhắn hiện ra là một khung bản đồ (Map preview) đẹp mắt, không chỉ là dòng text tọa độ.

### A6. CRUD & Quản lý
- **[A6.1] Chức năng Thêm/Sửa/Xóa:**
    - Thử Sửa/Xóa một Lớp học nhóm (Group).
    - Thử Sửa/Xóa một Lớp học 1-1 (Course).
- **[A6.2] Thông báo xác thực:**
    - Vào Tab "Tài khoản" -> Nếu tài khoản đã eKYC thành công -> Nhấn vào mục định danh.
    - Xác nhận hiện thông báo "Bạn đã xác thực danh tính thành công".
- **[A6.3] Quản lý bài kiểm tra (Quiz):**
    - Vào "Quản lý bài kiểm tra" -> Thử Sửa nội dung câu hỏi, Xóa bài kiểm tra.
    - Xác nhận hoạt động bình thường, không báo lỗi "Sẽ cập nhật sau".
- **[A6.4] Quản lý tài liệu:**
    - Vào "Quản lý tài liệu" -> Thử Tải lên file mới, Đổi tên file đã có, Xóa file.
- **[A6.5] Phân loại theo loại lớp:**
    - Vào "Lớp học nhóm A" -> Tab "Tài liệu" -> Tải file X.
    - Vào "Lớp học 1-1 B" -> Tab "Tài liệu" -> Xác nhận **KHÔNG** thấy file X của lớp A.
- **[A6.6] UI Xác thực danh tính:**
    - Vào màn hình "Xác thực danh tính" (eKYC) -> Kiểm tra các nút "Chọn ảnh", "Gửi" ở dưới cùng.
    - Xác nhận: Các nút không bị thanh điều hướng che mất, có khoảng trống (padding) hợp lý.
- **[A6.7] Giao bài tập & Chấm điểm:**
    - Gia sư vào lớp -> Tab "Bài tập" -> "Giao bài tập" -> Chọn "Hạn nộp" bằng lịch.
    - Học viên nộp bài.
    - Gia sư vào xem bài nộp -> Nhập điểm, Nhập lời nhắn -> Lưu.
    - Học viên vào xem bài tập -> Xác nhận thấy điểm và lời nhắn hiển thị trong khung Gradient.

---

## 👨‍🎓 B. TÀI KHOẢN HỌC VIÊN

- **[B1] Tìm kiếm phân loại:**
    - Trang chủ Học viên -> Nhấn nút "Kèm 1-1" -> Tự động chuyển màn Search với tab "Dạy kèm".
    - Nhấn nút "Lớp học nhóm" -> Tự động chuyển màn Search với tab "Lớp học nhóm".
- **[B2] Lớp của tôi:**
    - Trang chủ Học viên -> Tìm mục "Lớp của tôi".
    - Xác nhận có 2 ô rõ ràng: "Lớp kèm 1-1" (hiện số lượng lớp đang học) và "Lớp học nhóm" (hiện số nhóm đang tham gia).

---

## 🛠️ C & D. BUG UI & ADMIN

- **[C1] Nút Back (Lùi về):**
    - Vào tất cả các trang con trong tab "Tài khoản" (Ví, Định danh, Đổi pass, Cài đặt...).
    - Xác nhận: Mọi trang đều có nút "<-" ở góc trên bên trái để quay lại.
- **[C2] Gia sư yêu thích:**
    - Đăng nhập Gia sư -> Tab "Tài khoản" -> Xác nhận **KHÔNG** thấy mục "Gia sư yêu thích".
    - Đăng nhập Học viên -> Tab "Tài khoản" -> Xác nhận **CÓ** thấy mục "Gia sư yêu thích".
- **[D1] Admin Đăng xuất:**
    - Đăng nhập Admin -> AppBar -> Nhấn Logout.
    - Xác nhận: Hiện dialog "Bạn có chắc chắn muốn đăng xuất?". Nhấn "Hủy" thì ở lại, nhấn "Đồng ý" thì thoát.

---

## 🧪 E. KIỂM TRA TỔNG THỂ (VERIFICATION)

- **[E1] Hiển thị tên Chat:**
    - Học viên nhắn tin cho Gia sư.
    - Gia sư vào danh sách chat -> Xác nhận tên hiển thị là tên Học viên (không phải UID hay tên Gia sư).
- **[E2] Sự liên kết dữ liệu:**
    - Tạo một Lớp 1-1 (Course) -> Giao bài tập cho lớp đó -> Xác nhận chỉ học viên trong lớp đó mới nhận được thông báo bài tập.
