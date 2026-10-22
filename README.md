# BILL — Quản lý hóa đơn điện nước

Bài tập Level 2, Đề 9 (COBOL 24h). Nhập hóa đơn, thanh toán, tra cứu, xem lịch sử thanh toán qua web.
Luồng: trình duyệt → Apache (CGI) → BILLWEB → BILLBIZ → BILLFILE → file .DAT

## Cần có

- GnuCOBOL (`cobc`) và Apache cài bằng Homebrew, CGI đã bật (`LoadModule cgi_module`).
- Trong `~/.zshrc` đã có các biến `HTTPD_CONF`, `PORT`, `WEB_DIR`, `CGI_DIR` (làm ở Step 0 của khóa).

## Thư mục

| Thư mục / file | Nội dung |
|---|---|
| `src/` | BILLLOAD, BILLFILE, BILLBIZ, BILLWEB, BILLCLI (test terminal) |
| `copy/` | 4 copybook: BILL-REQ, BILL-FIO, BILL-MST, BILL-TRN |
| `web/index.html` | Form nhập liệu |
| `data/MASTER-SEED.txt` | 5 hóa đơn mẫu, dạng text: `MÃ;TÊN;LOẠI;SỐ TIỀN;HẠN;TRẠNG THÁI` |
| `env.sh` | Đường dẫn file dữ liệu (DD_BILLMST, DD_BILLTRN, DD_BILLSEED) |
| `build.sh` | Compile tất cả chương trình vào `build/` |

## Chạy lần đầu

Đứng trong thư mục project, chạy lần lượt:

1. Build và tạo dữ liệu mẫu

```
source env.sh
./build.sh
./build/BILLLOAD
```

Ra `LOADED 00005 BILLS` là được.

2. Test thử từ terminal (chưa cần Apache). BILLCLI hỏi 6 câu: action, mã HĐ, số tiền, tên, loại, hạn. Câu nào không dùng thì để trống.

```
printf 'V\nBILL000001\n\n\n\n\n' | ./build/BILLCLI
```

Ra `RESULT : 00 OK`, trạng thái UNPAID, số phải trả 350000.00.

3. Khai báo đường dẫn dữ liệu cho Apache. Chỉ làm 1 lần, chạy 2 lần sẽ bị trùng block trong httpd.conf.

```
cat >> "$HTTPD_CONF" <<EOF
<Location "/cgi-bin/BILLWEB">
    SetEnv DD_BILLMST $HOME/Resource/Cobol-Training/cobol24h/memberNN-bill/data/BILLS.DAT
    SetEnv DD_BILLTRN $HOME/Resource/Cobol-Training/cobol24h/memberNN-bill/data/BILLTRAN.DAT
</Location>
EOF
```

Kiểm tra lại bằng `tail -n 4 "$HTTPD_CONF"`.

4. Deploy và khởi động lại Apache

```
cp build/BILLWEB "$CGI_DIR/"
mkdir -p "$WEB_DIR/bill" && cp web/index.html "$WEB_DIR/bill/"
brew services restart httpd
```

5. Mở web: http://localhost:8080/bill/

Không dùng `sudo` khi chạy Apache, nếu không Apache sẽ không ghi được vào thư mục `data/`.

## Sau khi sửa code

```
source env.sh
./build.sh && cp build/BILLWEB "$CGI_DIR/"
```

Không cần restart Apache. Chỉ restart khi sửa httpd.conf.
Sửa `web/index.html` thì copy lại vào `$WEB_DIR/bill/`.

## Đưa dữ liệu về ban đầu

- `./build/BILLLOAD`: tạo lại BILLS.DAT từ MASTER-SEED.txt (trạng thái, phụ phí về như cũ, hóa đơn nhập thêm bị mất).
- Log không bị xoá theo. Muốn xoá log thì `rm data/BILLTRAN.DAT`, lần ghi sau sẽ tự tạo lại.

Lưu ý: trạng thái OVERDUE phụ thuộc ngày hôm nay. Hóa đơn mẫu BILL000002 (hạn 10/10/2026) và BILL000005 (hạn 30/09/2026) đã quá hạn, BILL000001 và BILL000004 hạn 31/12/2026.

## Xem dữ liệu trong file

BILLS.DAT là file indexed (Berkeley DB), mở bằng VS Code hay `cat` chỉ ra ký tự rác. Dùng `db_dump` có sẵn khi cài GnuCOBOL:

```
/opt/homebrew/opt/berkeley-db/bin/db_dump -p data/BILLS.DAT
```

Phải dùng đúng đường dẫn `/opt/homebrew/...`, `db_dump` có sẵn của macOS là bản cũ, có thể không đọc được.

Mỗi hóa đơn ra 2 dòng, dòng đầu là key, dòng sau là cả record:

```
 BILL000001
 BILL000001NGUYEN VAN AN                 E00000003500000000000000000000020261231UNPAID
```

Sau tên khách hàng là các field viết liền nhau (xem BILL-MST.cpy):

| Đoạn | Field | Ý nghĩa |
|---|---|---|
| 1 ký tự `E` | MST-TYPE | E = điện, W = nước |
| 15 số `000000035000000` | MST-AMOUNT | tiền gốc 350000.00, 2 số cuối là phần lẻ |
| 15 số `000000000000000` | MST-SURCHARGE | phụ phí quá hạn, 0 = chưa quá hạn |
| 8 số `20261231` | MST-DUE-DATE | hạn thanh toán |
| 10 ký tự `UNPAID` | MST-STATUS | UNPAID / OVERDUE / PAID |

Log BILLTRAN.DAT là file text, xem thẳng được: `cat data/BILLTRAN.DAT`

## Lỗi hay gặp

| Hiện tượng | Nguyên nhân / cách xử lý |
|---|---|
| Web báo lỗi 500 hoặc trang trắng | Xem log Apache: `tail -n 20 /opt/homebrew/var/log/httpd/error_log` |
| Mã 09, không đọc được file | Chưa chạy BILLLOAD, hoặc thiếu block SetEnv trong httpd.conf |
| Có file lạ tên `BILLMST` trong thư mục | Quên `source env.sh` trước khi chạy |
| Nhập tên có dấu bị báo "ky tu khong hop le" | Tên khách hàng phải nhập không dấu |
| `curl` báo không kết nối được ngay sau restart | Apache chưa lên kịp, đợi vài giây rồi chạy lại |
| Sửa code mà web vẫn chạy bản cũ | Quên `cp build/BILLWEB "$CGI_DIR/"` |
