*> BILL-TRN.cpy - mot dong log thanh toan, cac truong cach nhau bang dau ;
01  TRN-LINE.
    05  TRN-DATE            PIC 9(08).
    05  FILLER              PIC X(01) VALUE ";".
    05  TRN-TIME            PIC 9(06).
    05  FILLER              PIC X(01) VALUE ";".
    05  TRN-ID              PIC X(10).
    05  FILLER              PIC X(01) VALUE ";".
    05  TRN-ACTION          PIC X(01).
    05  FILLER              PIC X(01) VALUE ";".
    05  TRN-AMOUNT          PIC -(13)9.99.
    05  FILLER              PIC X(01) VALUE ";".
    05  TRN-RESULT          PIC X(02).
    05  FILLER              PIC X(01) VALUE ";".
    05  TRN-STATUS          PIC X(10).
