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
    - Đăng nhập bằng tài khoản Học viên -> Vào màn hình tìm kiếm/nhóm -> Xác nhận **KHÔNG** thấy nút "Tạo nhóm". [x]
    - Đăng nhập bằng tài khoản Gia sư -> Vào tab "Học tập" -> Chọn "Lớp học nhóm" -> Xác nhận thấy nút "Tạo nhóm". [x]
- **[A1.2] Các trường dữ liệu khi tạo nhóm:** [x]
    - Nhấn "Tạo nhóm".
    - Kiểm tra có đủ: Tên chủ đề, Môn học, Lớp, Hình thức (Online/Offline), Số lượng (Max), Học phí, Thời gian mở lớp dự kiến. [x]
    - **Quan trọng (Đã sửa):** Nhập học phí (vd: 1500000) -> Xác nhận ngay khi nhập xong hoặc chuyển ô, định dạng sẽ tự động hiển thị `1.500.000` (có dấu chấm). [x]
    - **Kiểm tra xóa (Đã sửa):** Thử xóa các chữ số. Xác nhận xóa bình thường, không bị kẹt hay không cho xóa sau khi thoát ra vào lại. [x]
- **[A1.3] Số lượng thành viên mặc định:**
    - Sau khi nhấn "Tạo" -> Xem chi tiết nhóm vừa tạo -> Xác nhận "Số thành viên: 0". [x]
- **[A1.4] Tự động duyệt & Đóng/Mở lớp:**
    - **Phía Gia sư:** Sau khi tạo nhóm, vào "Quản lý thành viên" hoặc chi tiết nhóm. [x]
    - **Nút Đóng/Mở:** Tìm switch/nút "Trạng thái hiển thị lớp học" -> Thử gạt sang "Mở". Xác nhận trạng thái đổi thành "Đang mở".[x] /đã hiểu cách để hiện nhóm học ghép, do Admin chưa duyệt đơn mở nhóm học ghép nên bị ẩn đi, nhưng sau khi duyệt thì phía học viên đã nhìn thấy lớp./
    - **Phía Học viên:** Quay lại màn hình tìm kiếm, vuốt xuống làm mới -> Xác nhận **CÓ** thấy nhóm vừa được mở. [x]
    - **Tham gia:** Học viên nhấn "Tham gia" -> Xác nhận có Dialog hỏi xác nhận. [x]
    - **Auto-approve:** Quay lại Gia sư -> Xem danh sách thành viên -> Xác nhận học viên đã ở trạng thái "Approved" mà không cần nhấn nút duyệt. [/] /Tôi không thấy trạng thái ở đâu, ngoài ra tôi nghĩ nên để thêm tag ví dụ như học thử (trial), chính thức(normal) để dễ phân biệt/
- **[A1.5] Rời nhóm (Quy tắc 12h):**
    - Học viên nhấn "Rời lớp học nhóm" ngay trong màn chi tiết nhóm -> Xác nhận rời được. [x] /Đã thêm nút rời rõ ràng trong phần thông tin nhóm và giữ icon rời ở AppBar./
    - (Nếu có thể mock thời gian hệ thống) Sau 12h kể từ lúc tham gia -> Nút "Rời nhóm" bị khóa và hiển thị lý do không thể rời. [x]
- **[A1.6] Đủ thành viên & Hạn thanh toán 24h:**
    - Thêm đủ số học viên tối đa vào nhóm. [x] Khi nhóm đủ thành viên thì không tham gia thêm được và có thẻ **Full** để học viên khác biết. [x]
    - Tài khoản học viên chưa tham gia vào mục tìm lớp học nhóm -> lớp đã đủ học viên phải hiện thẻ **Full** ở danh sách và trong chi tiết lớp, không còn hiện "Đang tuyển". [x]
    - Gia sư & Học viên vào xem chi tiết nhóm -> Xác nhận xuất hiện dòng thông báo "Hạn thanh toán còn lại: ... (countdown từ 24h)". [x]
- **[A1.7] Sau khi thanh toán:**
    - Học viên đã tham gia lớp do Gia sư tạo -> Vào chi tiết lớp -> Xác nhận có khối **"Học phí lớp học nhóm"** hiển thị trạng thái `Đang học thử 7 ngày`/`Đến hạn thanh toán` và nút **"Thanh toán học phí"** khi chưa đóng. [x]
    - Học viên nhấn "Thanh toán học phí" -> Trừ tiền ví.[x]/đã thanh toán được, có thể thanh toán trước dù đang học thử (nên hiện nút đã thanh toán cho dẽ nhìn hơn thay vì thanh toán học phí)/ /
    - Xác nhận giao diện nhóm của cả 2 bên chuyển sang chế độ "Lớp học" (Có tab Bài tập, Tài liệu, Chat nhóm).[x] /Đã sửa lỗi tab Bài tập loading liên tục do provider dùng Map key không ổn định; tab phải hiện danh sách bài tập hoặc trạng thái chưa có bài tập./
- **[A1.8] Giao diện Quiz khi tạo nhóm:** Trong màn hình tạo nhóm, kiểm tra xem có nút chọn Bài kiểm tra (Quiz) bên cạnh phần Bài tập không. [x] /Tôi không thấy mục tên là Quiz nhưng thấy có phần trắc nghiệm/
    - Gia sư vào chi tiết lớp học nhóm -> Tab "Trắc nghiệm" -> Tạo bài mới thành công -> Quay lại tab phải thấy bài Quiz vừa tạo trong danh sách, không còn trạng thái trống. [x]
    - Gia sư nhấn vào bài trắc nghiệm đã tạo -> Phải thấy thời gian, số câu, danh sách học viên đã làm/chưa làm, menu Sửa/Xóa; không được chuyển sang màn làm bài. [x]
    - Học viên nhấn vào bài trắc nghiệm -> Thấy màn giới thiệu có nút "Bắt đầu làm bài"; sau khi nộp phải thấy điểm, đáp án đã chọn, đáp án đúng/sai và nút quay lại lớp học. [x]
- **[A1.9] Xác nhận tham gia:** Đăng nhập tài khoản Học viên, vào xem chi tiết một lớp nhóm, nhấn "Tham gia". App phải hiện Dialog hỏi xác nhận. Sau khi nhấn "Đăng ký", phải có SnackBar thông báo thành công. [x] /nhiệm vụ này bị lặp với A1.4/

### A2. Tổng quan & Lịch dạy
- **[A2.1] Dashboard Dữ liệu thật:** Đăng nhập Gia sư, kiểm tra các con số (Tổng thu nhập, Số lớp...) xem có thay đổi khi có hoạt động mới không (không được là số ảo cố định). [x] /Đã sửa API thống kê để cộng cả transaction `earning` từ thanh toán học phí lớp học nhóm; đã kiểm tra emulator sau refresh dashboard: Thu nhập từ 0đ lên 765 N đ, Lớp đang dạy 10, Học viên 2./
- **[A2.2] Lịch dạy chung:** Vào Tab "Lịch dạy", kiểm tra xem có hiển thị cả lịch dạy kèm 1-1 và lịch dạy lớp nhóm không. [x] /Đã sửa API `/tutors/my-tuitions` trả đủ `student` + `tutor` và sắp xếp theo `start_time`, nên lịch chung không còn mất lịch dạy kèm 1-1. Đã sửa trạng thái booking: buổi `confirmed` nhưng `end_time` đã qua sẽ hiển thị `Completed` thay vì `Upcoming`. Đã thêm tab **Lịch sử dạy** để chuyển các buổi đã hoàn thành/đã qua sang lịch sử, tab **Lịch sắp tới** chỉ còn buổi chưa diễn ra. Đã thêm pull to refresh cho Lịch sắp tới, Lịch sử dạy và Lịch rảnh./
- **[A2.3] Tạo lịch trong màn quản lý:**
    - Tại tab "Lịch dạy", vào phần "Quản lý khung giờ rảnh" -> Thử tạo một khung giờ mới.
    - Xác nhận lịch mới tạo hiển thị ngay tại đây. [x] /Đã sửa lỗi chọn giờ rảnh hoặc thêm khung giờ khác bị reset do màn hình sync lại availability ở mỗi lần build; giờ chỉ sync lại khi dữ liệu API thật sự thay đổi./
- **[A2.4] Lịch sắp tới trên Dashboard:** Tại màn hình chính Gia sư, kiểm tra phần "Lịch dạy sắp tới" có hiển thị đúng các buổi học sắp diễn ra không. [x] /Đã sửa dashboard Gia sư từ chỉ hiển thị lịch hôm nay sang hiển thị 3 buổi dạy sắp tới gần nhất, gồm cả dạy 1-1 và lớp học nhóm open/ongoing. Refresh dashboard, polling và notification giờ cũng cập nhật lại `tutorScheduleProvider` để lịch không bị cũ./

### A3. Ví & Thống kê
- **[A3.1] Gộp Ví & Thống kê:**
    - Vào Tab "Tài khoản" -> Chọn "Ví & Thu nhập".
    - Xác nhận: Thấy biểu đồ thu nhập ở trên và các nút Nạp/Rút/Mã PIN ở dưới. [x] /Đã thêm biểu đồ thu nhập 7 ngày gần nhất ngay dưới thẻ ví./
    - Thử nhấn "Rút tiền" -> Nhập số tiền, ngân hàng, số tài khoản và tên chủ tài khoản -> Xác nhận gửi được yêu cầu rút tiền. [x] /Đã sửa frontend gửi thêm `account_name` đúng với validation backend, tránh lỗi rút tiền thất bại./

### A4. Giao diện & Tên gọi
- **[A4.1] Đồng bộ thuật ngữ:**
    - Đi dạo quanh app (Search, Detail, Create) -> Xác nhận dùng đúng từ **"lớp học nhóm"** (không phải "nhóm học", "lớp nhóm"). [x] /Đã sửa các text hiển thị còn sót: "Xem lớp nhóm", "Tạo lớp nhóm", badge "Lớp nhóm" và validate "tên lớp nhóm" sang "lớp học nhóm"./
- **[A4.2] Tách yêu cầu tìm học viên:**
    - Dashboard Gia sư -> Nhấn "Tìm học viên" -> Xác nhận có 2 tab/nút riêng: "Học viên 1-1" và "Yêu cầu tuyển nhóm". [x] /Dashboard và màn tìm học viên đã có 2 lối riêng; tab nhóm được đổi từ "Học viên Nhóm" thành "Yêu cầu tuyển nhóm"./

### A5. Chat
- **[A5.1] Gửi vị trí Premium:**
    - Trong chat -> Nhấn dấu `+` -> "Gửi vị trí".
    - Xác nhận: Tin nhắn hiện ra là một khung bản đồ (Map preview) đẹp mắt, không chỉ là dòng text tọa độ. [x] /Đã kiểm tra chat 1-1 có `LocationBubble` dùng `flutter_map` + OpenStreetMap; đã sửa để tin vị trí không render thêm bubble text tọa độ bên dưới map preview./

### A6. CRUD & Quản lý
- **[A6.1] Chức năng Thêm/Sửa/Xóa:**
    - Thử Sửa/Xóa một Lớp học nhóm (Group). [x] /Đã thêm menu "Sửa lớp học nhóm" trong màn quản lý lớp học nhóm, mở lại form tạo/sửa và gọi API update; xóa/giải tán đã gọi API delete./
    - Thử Sửa/Xóa một Lớp học 1-1 (Course). [x] /Dạy kèm 1-1 hiện có cụm "Quản lý dạy kèm 1-1" trong chi tiết học viên: "Cập nhật 1-1" áp dụng cách học online/offline, link/địa chỉ và ghi chú cho toàn bộ buổi sắp tới của học viên đó; "Hủy 1-1" hủy toàn bộ buổi sắp tới. Từng buổi vẫn có nút cập nhật/hủy riêng khi cần xử lý lẻ./
- **[A6.2] Thông báo xác thực:**
    - Vào Tab "Tài khoản" -> Nếu tài khoản đã eKYC thành công -> Nhấn vào mục định danh.
    - Xác nhận hiện thông báo "Bạn đã xác thực danh tính thành công". [x] /Đã sửa để mục eKYC trong Tab Tài khoản gọi trạng thái mới nhất từ `/verification/status`, không phụ thuộc dữ liệu đăng nhập cũ. Backend cũng cho cả học viên và gia sư gửi yêu cầu eKYC; khi admin duyệt thì user có `identity_verified_at`, gia sư vẫn được cập nhật `tutors.is_verified`. Với gia sư chưa xác thực, màn eKYC chỉ bắt buộc CCCD/CMND/Hộ chiếu; bằng cấp và chứng chỉ là tùy chọn. Sau khi đã gửi hồ sơ, vào lại eKYC sẽ hiện "Đang chờ duyệt" và có nút làm mới trạng thái. Màn eKYC mở bằng root navigator nên không còn bị menu/bottom navigation của app che trong lúc nộp hồ sơ./
- **[A6.3] Quản lý bài kiểm tra (Quiz):**
    - Vào "Quản lý bài kiểm tra" -> Thử Sửa nội dung câu hỏi, Xóa bài kiểm tra.
    - Xác nhận hoạt động bình thường, không báo lỗi "Sẽ cập nhật sau". [x] /Đã kiểm tra luồng quản lý Quiz có API sửa/xóa thật (`PUT/DELETE /quizzes/{id}`). Đã sửa màn quản lý để khi bấm Sửa luôn tải chi tiết Quiz trước, nên form sửa có đầy đủ câu hỏi/đáp án thay vì chỉ metadata từ danh sách. Sau khi lưu quay lại sẽ refresh danh sách; nếu backend lưu lỗi sẽ hiện thông báo lỗi, không báo thành công giả./
- **[A6.4] Quản lý tài liệu:**
    - Vào "Quản lý tài liệu" -> Thử Tải lên file mới, Đổi tên file đã có, Xóa file. [x] /Đã kiểm tra màn Quản lý tài liệu đang gọi API thật: upload `POST /tutors/upload-material`, đổi tên `PUT /tutors/materials/{id}`, xóa `DELETE /tutors/materials/{id}`. Đã bổ sung guard dữ liệu tên/ngày/kích thước file để danh sách không crash nếu backend trả thiếu trường./
- **[A6.5] Phân loại theo loại lớp:**
    - Vào "Lớp học nhóm A" -> Tab "Tài liệu" -> Tải file X.
    - Vào "Lớp học 1-1 B" -> Tab "Tài liệu" -> Xác nhận **KHÔNG** thấy file X của lớp A. [x] /Đã kiểm tra luồng tài liệu theo context: lớp học nhóm gửi `study_group_id`, lớp 1-1 gửi `student_id`, lớp/course gửi `course_id`; backend lọc tiếp theo đúng tham số nên tài liệu nhóm không lẫn sang 1-1. Đã bổ sung quyền xem cho học viên thuộc nhóm bằng `study_group_members`, để học viên trong nhóm cũng thấy tài liệu `study_group_id` nhưng vẫn không thấy ở tab 1-1 khác./
- **[A6.6] UI Xác thực danh tính:**
    - Vào màn hình "Xác thực danh tính" (eKYC) -> Kiểm tra các nút "Chọn ảnh", "Gửi" ở dưới cùng.
    - Xác nhận: Các nút không bị thanh điều hướng che mất, có khoảng trống (padding) hợp lý. [x] /Màn eKYC đã mở bằng root navigator để không bị menu/bottom navigation che. Nút gửi nằm trong SafeArea và có padding dưới màn hình./
- **[A6.7] Giao bài tập & Chấm điểm:**
    - Gia sư vào lớp -> Tab "Bài tập" -> "Giao bài tập" -> Chọn "Hạn nộp" bằng lịch.
    - Học viên nộp bài.
    - Gia sư vào xem bài nộp -> Nhập điểm, Nhập lời nhắn -> Lưu.
    - Học viên vào xem bài tập -> Xác nhận thấy điểm và lời nhắn hiển thị trong khung Gradient. [x] /Đã kiểm tra luồng có API thật: tạo bài `POST /assignments`, nộp bài `POST /assignments/{id}/submit`, xem bài nộp `GET /assignments/{id}/submissions`, chấm điểm `POST /assignments/submissions/{id}/grade`. Màn học viên đã hiển thị điểm và feedback trong khung gradient khi `my_submission.grade` có dữ liệu. Đã sửa backend để danh sách bài tập của học viên vẫn lọc đúng theo tab hiện tại (`course_id`, `study_group_id`, `student_id`), chỉ lấy nhóm đã approved/member, và chặn nộp/xem bài nộp ngoài phạm vi lớp/nhóm/1-1 hợp lệ./

---

## 👨‍🎓 B. TÀI KHOẢN HỌC VIÊN

- **[B1] Tìm kiếm phân loại:**
    - Trang chủ Học viên -> Nhấn nút "Kèm 1-1" -> Tự động chuyển màn Search với tab "Dạy kèm".[x]
    - Nhấn nút "Lớp học nhóm" -> Tự động chuyển màn Search với tab "Lớp học nhóm".[x]
    - Học viên chọn Gia sư 1-1 -> Chọn lịch -> Xác nhận & thanh toán bằng PIN ví mặc định `000000` -> Phải tạo lịch thành công; nếu nhập sai PIN phải hiện lỗi ngay trong form PIN, không báo chung chung "đăng ký thất bại". [x] /Đã thêm migration `bookings.address` và chạy migrate để sửa lỗi server 500 sau khi nhập đúng PIN. Đã sửa nút thanh toán tự chờ tải ví và mở nhập PIN ngay trong lần bấm đầu tiên./
- **[B2] Lớp của tôi:**
    - Trang chủ Học viên -> Tìm mục "Lớp của tôi".
    - Xác nhận có 2 ô rõ ràng: "Dạy kèm 1-1" (mở lịch học 1-1) và "Lớp học nhóm" (mở danh sách lớp học nhóm đã đăng ký).
    - Nhấn ô **"Lớp học nhóm"** -> Phải mở màn **"Lớp học nhóm của tôi"** và hiển thị các lớp do Gia sư tạo mà Học viên đã đăng ký; không được chuyển sang trang "Nhóm học tập" trống. [x]
    - Xác nhận 2 ô trong mục "Lớp của tôi" không bị lỗi overflow/chữ tràn trên màn hình nhỏ. [x]

---

## 🛠️ C & D. BUG UI & ADMIN

- **[C1] Nút Back (Lùi về):**
    - Vào tất cả các trang con trong tab "Tài khoản" (Ví, Định danh, Đổi pass, Cài đặt...).
    - Xác nhận: Mọi trang đều có nút "<-" ở góc trên bên trái để quay lại. [x] /Đã kiểm tra các trang con chính từ Tab Tài khoản: Ví & Thu nhập, Cài đặt, Đổi mật khẩu, eKYC, Gia sư yêu thích. Các màn đều dùng AppBar; eKYC có leading back tùy chỉnh để quay lại đúng cả khi mở bằng root navigator./
- **[C2] Gia sư yêu thích:**
    - Đăng nhập Gia sư -> Tab "Tài khoản" -> Xác nhận **KHÔNG** thấy mục "Gia sư yêu thích".
    - Đăng nhập Học viên -> Tab "Tài khoản" -> Xác nhận **CÓ** thấy mục "Gia sư yêu thích". [x] /Đã kiểm tra mục này là chức năng danh sách gia sư yêu thích, không phải đánh giá học viên. ProfileScreen chỉ hiển thị "Gia sư yêu thích" khi user không phải gia sư; gia sư không thấy mục này. Route `/favorite-tutors` và màn FavoriteTutorsScreen đã tồn tại./
- **[D1] Admin Đăng xuất:**
    - Đăng nhập Admin -> AppBar -> Nhấn Logout.
    - Xác nhận: Hiện dialog "Bạn có chắc chắn muốn đăng xuất?". Nhấn "Hủy" thì ở lại, nhấn "Đồng ý" thì thoát. [x] /Đã kiểm tra AdminDashboard có nút logout trên AppBar. Đã chỉnh dialog xác nhận đúng nội dung guide, nút "Hủy" trả `false` nên ở lại, nút "Đồng ý" trả `true` rồi gọi `authViewModel.logout()` và điều hướng về `/login`. Đã bổ sung cùng dialog xác nhận cho nút Đăng xuất trong Tab Tài khoản của Gia sư và Học viên./
- **[D2] Admin phê duyệt Gia sư:**
    - Vào màn "Duyệt Gia sư" -> Danh sách gia sư chờ duyệt không còn nút "AI Soi Chiếu" hoặc "Duyệt ngay" trên card.
    - Nhấn "Kiểm tra" -> Xác nhận hiện thông tin cơ bản của gia sư và ảnh bằng chứng eKYC gần nhất.
    - Trong dialog kiểm tra, Admin có thể nhấn "Duyệt" hoặc "Từ chối"; nếu từ chối bắt buộc nhập lý do. [x] /Đã đổi luồng duyệt gia sư từ AI giả lập sang dialog kiểm tra hồ sơ thật. API `/admin/tutor-requests` trả kèm `verification_request`; reject gửi `reason` và cập nhật hồ sơ eKYC gần nhất sang `rejected` với lý do. Ảnh CCCD/eKYC hiện được upload file thật lên Laravel thay vì URL giả `example.com`, và admin preview tự resolve URL `/api/verification/file/...` để xem được ảnh./
    - Kéo xuống để làm mới danh sách gia sư chờ duyệt. [x] /Đã thêm pull to refresh cho cả trạng thái có dữ liệu và danh sách trống./
- **[D3] Admin duyệt eKYC:**
    - Gia sư gửi hồ sơ eKYC mới -> Admin vào "Duyệt KYC" -> Xác nhận thấy hồ sơ pending mới. [x] /Đã xác nhận DB và HTTP API `/verification/pending` đều có record pending của gia sư "Cấn Huệ". Đã sửa model `VerificationRequest.user()` để API pending load được user, thêm nút refresh trên AppBar và pull to refresh cho danh sách Duyệt KYC; lỗi API không còn bị nuốt thành danh sách rỗng. Đã đổi mục điều hướng Admin từ "Kiểm duyệt" mở `/admin/tutors` sang "Duyệt KYC" mở `/admin/verification`, vì hồ sơ eKYC nằm ở Duyệt KYC chứ không phải danh sách Duyệt Gia sư./
    - Nếu gia sư chỉ upload CCCD/CMND/Hộ chiếu, ảnh phải nằm ở mục giấy tờ tùy thân, không hiện nhầm sang "Bằng cấp / bổ sung". [x] /Đã sửa app chỉ gửi `front_image` khi chưa chọn bằng cấp; backend cho `back_image_url` nullable và không tự copy CCCD sang ảnh bổ sung. Dialog kiểm tra chỉ hiển thị "Bằng cấp / ảnh bổ sung" khi có ảnh riêng./

---

## 🧪 E. KIỂM TRA TỔNG THỂ (VERIFICATION)

- **[E1] Hiển thị tên Chat:**
    - Học viên nhắn tin cho Gia sư.
    - Gia sư vào danh sách chat -> Xác nhận tên hiển thị là tên Học viên (không phải UID hay tên Gia sư). [x] /Đã kiểm tra luồng chat Firebase; danh sách chat lấy người đối thoại từ `users` và `user_data`. Đã sửa so sánh ID về chuỗi để không bị hiển thị nhầm `User`/UID, và prefix tin cuối "Bạn:" hoạt động khi người gửi là user hiện tại./
- **[E2] Sự liên kết dữ liệu:**
    - Tạo một Lớp 1-1 (Course) -> Giao bài tập cho lớp đó -> Xác nhận chỉ học viên trong lớp đó mới nhận được thông báo bài tập. [x] /Đã thêm backend notification khi tạo assignment: nếu giao cho 1 học viên thì chỉ user đó nhận; nếu giao theo Course thì chỉ các `course_students.status = approved` của course đó nhận; nếu giao theo StudyGroup thì chỉ member `approved/member` nhận. Gia sư/học viên ngoài lớp không nằm trong recipient list./
