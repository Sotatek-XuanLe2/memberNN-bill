*> BILL-FIO.cpy - vung giao tiep giua BIZ va FILE
01  BILL-FIO.
    05  FIO-OP              PIC X(01).
        88  FIO-READ            VALUE "R".
        88  FIO-REWRITE         VALUE "U".
        88  FIO-ADD             VALUE "W".
        88  FIO-LOG             VALUE "L".
        88  FIO-HISTORY         VALUE "H".
    05  FIO-STATUS          PIC X(02).
        88  FIO-OK              VALUE "00" "05".
        88  FIO-DUPLICATE       VALUE "22".
        88  FIO-NOT-FOUND       VALUE "23".
    05  FIO-HIST-COUNT      PIC 9(02).
    05  FIO-HIST-LINE       PIC X(80) OCCURS 10 TIMES.
