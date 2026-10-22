IDENTIFICATION DIVISION.
PROGRAM-ID. BILLWEB.

DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "BILL-REQ.cpy".
01  WS-NL                PIC X(01) VALUE X"0A".
01  WS-METHOD            PIC X(10).
01  WS-POST-DATA         PIC X(1000).
01  WS-PAIRS.
    05  WS-PAIR          PIC X(200) OCCURS 6 TIMES.
01  WS-I                 PIC 9(02).
01  WS-KEY               PIC X(20).
01  WS-VAL               PIC X(100).
01  WS-PCT-COUNT         PIC 9(04).
01  WS-AMOUNT-TXT        PIC X(30).
01  WS-MONEY-OUT         PIC -(13)9.99.

PROCEDURE DIVISION.
0000-MAIN.
    *> header + dong trong
    DISPLAY "Content-Type: text/html; charset=utf-8" WS-NL
    DISPLAY "<!DOCTYPE html><html><head><meta charset='utf-8'>"
    DISPLAY "<title>BILL</title></head><body><h1>Hóa đơn điện nước</h1>"

    INITIALIZE BILL-REQ BILL-RES
    SET RES-OK TO TRUE
    PERFORM 1000-READ-REQUEST
    IF RES-OK
        CALL "BILLBIZ" USING BILL-REQ BILL-RES
    END-IF
    PERFORM 3000-SHOW-RESULT

    DISPLAY "<p><a href='/bill/'>Quay lại</a></p></body></html>"
    STOP RUN.

*> doc request: dung lai khung DEMOWEB
1000-READ-REQUEST.
    ACCEPT WS-METHOD FROM ENVIRONMENT "REQUEST_METHOD"
    IF WS-METHOD NOT = "POST"
        SET RES-BAD-INPUT TO TRUE
        MOVE "Chi ho tro POST" TO RES-MESSAGE
        EXIT PARAGRAPH
    END-IF

    ACCEPT WS-POST-DATA
    MOVE 0 TO WS-PCT-COUNT
    INSPECT WS-POST-DATA TALLYING WS-PCT-COUNT FOR ALL "%"
    IF WS-PCT-COUNT > 0
        SET RES-BAD-INPUT TO TRUE
        MOVE "Du lieu chua ky tu khong hop le (ten nhap khong dau)" TO RES-MESSAGE
        EXIT PARAGRAPH
    END-IF

    INSPECT WS-POST-DATA REPLACING ALL "+" BY SPACE
    UNSTRING WS-POST-DATA DELIMITED BY "&"
        INTO WS-PAIR(1) WS-PAIR(2) WS-PAIR(3)
             WS-PAIR(4) WS-PAIR(5) WS-PAIR(6)
    END-UNSTRING
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
        PERFORM 1100-PARSE-PAIR
    END-PERFORM
    PERFORM 1200-CHECK-AMOUNT.

1100-PARSE-PAIR.
    IF WS-PAIR(WS-I) = SPACES
        EXIT PARAGRAPH
    END-IF

    MOVE SPACES TO WS-KEY WS-VAL
    UNSTRING WS-PAIR(WS-I) DELIMITED BY "="
        INTO WS-KEY WS-VAL
    END-UNSTRING
    EVALUATE WS-KEY
        WHEN "id"
            IF FUNCTION LENGTH(FUNCTION TRIM(WS-VAL)) > 10
                SET RES-BAD-INPUT TO TRUE
                MOVE "MA HOA DON TOI DA 10 KY TU" TO RES-MESSAGE
            ELSE
                MOVE FUNCTION UPPER-CASE(WS-VAL) TO REQ-ID
            END-IF
        WHEN "action"
            MOVE FUNCTION UPPER-CASE(WS-VAL) TO REQ-ACTION
        WHEN "amount"
            MOVE WS-VAL TO WS-AMOUNT-TXT
        WHEN "name"
            MOVE FUNCTION UPPER-CASE(WS-VAL) TO REQ-NAME
        WHEN "type"
            MOVE FUNCTION UPPER-CASE(WS-VAL) TO REQ-TYPE
        WHEN "due"
            MOVE WS-VAL TO REQ-DUE-DATE
        WHEN OTHER
            CONTINUE
    END-EVALUATE.

1200-CHECK-AMOUNT.
    IF WS-AMOUNT-TXT NOT = SPACES
       AND FUNCTION TEST-NUMVAL(WS-AMOUNT-TXT) = 0
        COMPUTE REQ-AMOUNT = FUNCTION NUMVAL(WS-AMOUNT-TXT)
        SET REQ-AMOUNT-VALID TO TRUE
    END-IF.

3000-SHOW-RESULT.
    IF RES-OK
        DISPLAY "<h2>Thành công</h2>"
    ELSE
        DISPLAY "<h2>Không thành công</h2>"
    END-IF
    DISPLAY "<p>Mã kết quả: " RES-CODE " - " FUNCTION TRIM(RES-MESSAGE) "</p>"

    IF RES-NAME NOT = SPACES
        DISPLAY "<p>Khách hàng: " FUNCTION TRIM(RES-NAME) "</p>"
        IF RES-TYPE = "E"
            DISPLAY "<p>Loại: Điện</p>"
        ELSE
            DISPLAY "<p>Loại: Nước</p>"
        END-IF
        DISPLAY "<p>Trạng thái: " FUNCTION TRIM(RES-STATUS) "</p>"
        DISPLAY "<p>Hạn thanh toán: " RES-DUE-DATE(7:2) "/"
                RES-DUE-DATE(5:2) "/" RES-DUE-DATE(1:4) "</p>"
        MOVE RES-AMOUNT TO WS-MONEY-OUT
        DISPLAY "<p>Tiền gốc: " FUNCTION TRIM(WS-MONEY-OUT) "</p>"
        MOVE RES-SURCHARGE TO WS-MONEY-OUT
        DISPLAY "<p>Phụ phí quá hạn: " FUNCTION TRIM(WS-MONEY-OUT) "</p>"
        MOVE RES-TOTAL TO WS-MONEY-OUT
        DISPLAY "<p><b>Số phải trả: " FUNCTION TRIM(WS-MONEY-OUT) "</b></p>"
    END-IF

    IF RES-HIST-COUNT > 0
        DISPLAY "<p>Lịch sử thanh toán (ngày;giờ;mã HĐ;P;số tiền;mã;trạng thái sau):</p><pre>"
        PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RES-HIST-COUNT
            DISPLAY FUNCTION TRIM(RES-HIST-LINE(WS-I))
        END-PERFORM
        DISPLAY "</pre>"
    END-IF.
