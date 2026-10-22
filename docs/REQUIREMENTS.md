# REQUIREMENTS — Quản lý hóa đơn điện nước (BILL)

Mỗi hóa đơn có 1 mã (10 ký tự), thuộc 1 khách hàng, là hóa đơn điện (E) hoặc nước (W).

## Chức năng

| Action | Mô tả | Input |
|---|---|---|
| C | Nhập hóa đơn mới | Mã HĐ, tên khách hàng, loại (E/W), số tiền, hạn thanh toán (YYYYMMDD) |
| P | Thanh toán hóa đơn | Mã HĐ, số tiền |
| V | Tra cứu hóa đơn (trạng thái, số phải trả) | Mã HĐ |
| H | Xem lịch sử thanh toán của hóa đơn | Mã HĐ |

## Trạng thái

| Trạng thái | Khi nào |
|---|---|
| UNPAID | Mới nhập, chưa thanh toán |
| OVERDUE | Chưa thanh toán và đã quá hạn |
| PAID | Đã thanh toán, không đổi nữa |

## Business rule

| ID | Rule | Mã trả về khi vi phạm |
|---|---|---|
| BR01 | Mã HĐ không được để trống | 03 |
| BR02 | Action chỉ nhận C, P, V, H | 03 |
| BR03 | Nhập HĐ: tên không trống, loại là E hoặc W, số tiền > 0, hạn thanh toán là ngày hợp lệ | 03 |
| BR04 | Nhập HĐ: mã HĐ chưa có trong BILLS.DAT | 05 |
| BR05 | P/V/H: mã HĐ phải có trong BILLS.DAT | 02 |
| BR06 | Khi tra cứu (V) hoặc thanh toán (P): hôm nay > hạn thanh toán và chưa PAID thì chuyển OVERDUE, cộng phụ phí 5% | - |
| BR07 | Phụ phí 5% chỉ cộng 1 lần | - |
| BR08 | Không cho thanh toán hóa đơn đã PAID | 04 |
| BR09 | Số tiền thanh toán phải bằng đúng số phải trả (tiền gốc + phụ phí), không trả một phần | 01 |
| BR10 | Mọi lần thanh toán đều ghi log vào BILLTRAN.DAT, kể cả bị lỗi | - |

BR06/BR07: phụ phí lưu riêng trong field MST-SURCHARGE. Chỉ tính khi chuyển từ UNPAID sang OVERDUE, mà đã OVERDUE thì không chuyển lại nữa nên không bị cộng lần 2. Số phải trả = MST-AMOUNT + MST-SURCHARGE.

## Mã kết quả

| Mã | Ý nghĩa | Ví dụ |
|---|---|---|
| 00 | Thành công | Nhập HĐ, thanh toán, tra cứu xong |
| 01 | Số tiền thanh toán không khớp số phải trả | Phải trả 126,000 mà nhập 120,000 |
| 02 | Không tìm thấy hóa đơn | Mã HĐ không có trong BILLS.DAT |
| 03 | Input không hợp lệ | Mã trống, action X, loại khác E/W, ngày 20261332 |
| 04 | Hóa đơn đã thanh toán | Thanh toán lại HĐ đã PAID |
| 05 | Mã hóa đơn đã tồn tại (mã riêng) | Nhập HĐ trùng mã |
| 09 | Lỗi hệ thống | Không mở được file |

## Giả định đã được mentor duyệt

Chưa duyệt:

- Ngày hôm nay lấy từ FUNCTION CURRENT-DATE. Đúng ngày hạn thanh toán thì chưa quá hạn, từ hôm sau mới OVERDUE.
- Phụ phí = 5% tiền gốc, làm tròn 2 số lẻ.
- Trạng thái OVERDUE chỉ được cập nhật khi có người tra cứu hoặc thanh toán (theo đề). Hóa đơn chưa ai đụng tới thì trong file vẫn để UNPAID dù đã quá hạn.
- Thứ tự kiểm tra khi thanh toán: input (03) → có HĐ không (02) → cập nhật OVERDUE → đã PAID chưa (04) → số tiền có khớp không (01).
- Thanh toán lỗi vẫn giữ việc chuyển OVERDUE (vì đề yêu cầu chuyển khi tra cứu hoặc thanh toán).
- Nhập HĐ cho phép hạn thanh toán ở quá khứ, lần tra cứu đầu tiên sẽ chuyển OVERDUE.
- Chỉ thanh toán (P) ghi log. C, V, H không ghi.
- Lịch sử là lịch sử thanh toán của 1 hóa đơn (gồm cả lần thất bại), tối đa 10 dòng gần nhất.
- Tên khách hàng nhập không dấu.
