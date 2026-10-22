*> BILL-MST.cpy - master record cua hoa don, dai co dinh 100 byte
01  MST-REC.
    05  MST-ID              PIC X(10).
    05  MST-NAME            PIC X(30).
    05  MST-TYPE            PIC X(01).
    05  MST-AMOUNT          PIC S9(13)V99.
    05  MST-SURCHARGE       PIC S9(13)V99.
    05  MST-DUE-DATE        PIC 9(08).
    05  MST-STATUS          PIC X(10).
        88  MST-UNPAID          VALUE "UNPAID".
        88  MST-PAID            VALUE "PAID".
        88  MST-OVERDUE         VALUE "OVERDUE".
    05  FILLER              PIC X(11).
