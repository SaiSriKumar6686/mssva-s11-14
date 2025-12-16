Title: Unbounded record_count trust
Flag: Design Assumption Broken
Location (file:function): parser.c:parse_header, main.c:main
Instrumentation Used: Deterministic logging via sec_log
Trigger Condition: Input file with record_count = 65535
Root Cause: record_count from input header is trusted without enforcing MAX_RECORDS.
Impact: Excessive allocation and undefined processing behavior.
Evidence: evidence/dynamic/flag1.log showing `[SEC]record_count:65535`.
