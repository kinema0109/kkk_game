# Vibe-Token-Manager (VTM) Guide

Chào bạn! Đây là hướng dẫn sử dụng framework **Vibe-Token-Manager (VTM)** để giúp bạn quản lập trình theo phong cách "vibe code" một cách hiệu quả, giữ cho AI luôn hiểu đúng ngữ cảnh và giảm thiểu tối đa lượng token tiêu thụ (giúp tiết kiệm chi phí và tăng tốc độ phản hồi).

## 🚀 1. Cấu trúc Framework

Framework này sử dụng một thư mục ẩn `.vibe/` để lưu trữ "bộ nhớ" và "ngữ cảnh" của dự án:

```text
/project-root
├── .vibe/
│   ├── blueprint.md      # Bản thiết kế tổng thể (Kiến trúc, Tech stack)
│   ├── activeContext.md  # Ngữ cảnh hiện tại (Đang làm gì? File nào liên quan?)
│   └── progress.md       # Nhật ký công việc (Đã xong gì? Tiếp theo là gì?)
├── vibe_framework_guide.md # File hướng dẫn này
└── repomix.config.json   # Cấu hình nén code cho AI
```

## 🛠️ 2. Cách sử dụng

### 💡 Bước 1: Khởi tạo Ngữ cảnh
Trước khi bắt đầu một tính năng mới, hãy cập nhật file `.vibe/activeContext.md`. 
*AI sẽ đọc file này để biết nó chỉ nên tập trung vào phần nào của Codebase, thay vì đọc toàn bộ.*

### 📦 Bước 2: Nén Code với Repomix
Khi bạn cần AI hiểu một lượng lớn code, hãy sử dụng **Repomix** (đã cấu hình sẵn trong `repomix.config.json`).
Chạy lệnh: `npx repomix`
Lệnh này sẽ tạo ra một file `repomix-output.txt` cực kỳ gọn nhẹ, loại bỏ các file rác (node_modules, logs, etc.) để nạp vào AI.

### 🔄 Bước 3: Cập nhật Tiến độ
Sau mỗi lần xong một phần việc, hãy bảo AI cập nhật `.vibe/progress.md`. Điều này giúp AI ca làm việc sau không bị "mất trí nhớ".

## 🎯 3. Lời khuyên để giảm Token

1. **Keep it Small**: Đừng đưa toàn bộ project vào prompt. Chỉ đưa những file cần thiết được liệt kê trong `activeContext.md`.
2. **Session Reset**: Nếu cuộc hội thoại quá dài, hãy copy nội dung từ `.vibe/` sang một chat mới để reset lại context window.
3. **Use Blueprint**: Luôn nhắc AI tuân thủ `blueprint.md` để tránh việc AI tự ý thay đổi kiến trúc gây "nát" code.

---
*Chúc bạn có những trải nghiệm vibe coding tuyệt vời!*
