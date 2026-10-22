*> BILL-REQ.cpy - vung giao tiep giua WEB va BIZ
01  BILL-REQ.
    05  REQ-ACTION          PIC X(01).
        88  REQ-CREATE          VALUE "C".
        88  REQ-PAY             VALUE "P".
        88  REQ-VIEW            VALUE "V".
        88  REQ-HISTORY         VALUE "H".
        88  REQ-ACTION-OK       VALUE "C" "P" "V" "H".
    05  REQ-ID              PIC X(10).
    05  REQ-AMOUNT          PIC S9(13)V99.
    05  REQ-AMOUNT-FLAG     PIC X(01).
        88  REQ-AMOUNT-VALID    VALUE "Y".
    05  REQ-NAME            PIC X(30).
    05  REQ-TYPE            PIC X(01).
        88  REQ-TYPE-OK         VALUE "E" "W".
    05  REQ-DUE-DATE        PIC X(08).

01  BILL-RES.
    05  RES-CODE            PIC X(02).
        88  RES-OK              VALUE "00".
        88  RES-WRONG-AMOUNT    VALUE "01".
        88  RES-NOT-FOUND       VALUE "02".
        88  RES-BAD-INPUT       VALUE "03".
        88  RES-ALREADY-PAID    VALUE "04".
        88  RES-DUPLICATE       VALUE "05".
        88  RES-SYS-ERROR       VALUE "09".
    05  RES-MESSAGE         PIC X(80).
    05  RES-NAME            PIC X(30).
    05  RES-TYPE            PIC X(01).
    05  RES-STATUS          PIC X(10).
    05  RES-AMOUNT          PIC S9(13)V99.
    05  RES-SURCHARGE       PIC S9(13)V99.
    05  RES-TOTAL           PIC S9(13)V99.
    05  RES-DUE-DATE        PIC 9(08).
    05  RES-HIST-COUNT      PIC 9(02).
    05  RES-HIST-LINE       PIC X(80) OCCURS 10 TIMES.
