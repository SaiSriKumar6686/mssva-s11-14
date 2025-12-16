nano investigation/findings.md
Title: Unbounded record_count trust
Flag: Design Assumption Broken
Location (file:function): parser.c:parse_header, main.c:main
Instrumentation Used: Deterministic logging via sec_log
Trigger Condition: Input file with record_count = 65535
Root Cause: record_count from input header is trusted without enforcing MAX_RECORDS.
Impact: Excessive allocation and undefined processing behavior.
Evidence: evidence/dynamic/flag1.log showing `[SEC]record_count:65535`.

Title: Silent partial record parsing without telemetry
Flag: Telemetry Gap Identified
Location (file:function): record.c:parse_records
Instrumentation Used: Default sec_log output and execution logs
Trigger Condition: Input file declares more records than are actually present
Root Cause: The record parsing loop breaks on fread or allocation failure
           without emitting a warning or returning an error to the caller.
Impact: Truncated or corrupted input files are processed without detection,
        preventing operators from identifying data loss or corruption.
Evidence: evidence/dynamic/flag2.log showing normal execution despite
          record_count mismatch and missing telemetry.

Title: Inconsistent ownership and freeing of processed record buffers
Flag: Memory Ownership Violation
Location (file:function): memory.c:process_record, main.c:main
Instrumentation Used: Execution logs and code-path analysis
Trigger Condition: Multiple valid records processed in a single input file
Root Cause: process_record allocates memory for every record, but the caller
           frees the returned buffer only for even-indexed records, leaving
           ownership undefined and inconsistent.
Impact: Deterministic memory leaks that grow with input size, leading to
        resource exhaustion in long-running or batch processing scenarios.
Evidence: evidence/dynamic/flag3.log demonstrating normal execution despite
          leaked allocations.

Title: Invalid records skipped without logging or alerting
Flag: Silent Failure Detected
Location (file:function): validate.c:validate_record, main.c:main
Instrumentation Used: Statistics counters and execution logs
Trigger Condition: Record with zero-length payload
Root Cause: Validation failures cause the processing loop to silently
           skip records without emitting telemetry or warnings.
Impact: Invalid or corrupted data is dropped without operator awareness,
        leading to silent data loss and incorrect processing results.
Evidence: evidence/dynamic/flag4.log showing invalid_records increment
          without corresponding security warnings.

Title: FAST_MODE off-by-one heap buffer overflow
Flag: Fuzzer-Only Bug Explained
Location (file:function): memory.c:process_record
Instrumentation Used: AddressSanitizer (ASan)
Trigger Condition: FAST_MODE enabled with payload length exactly equal to
                  allocated buffer size
Root Cause: In FAST_MODE, memcpy copies rec->length + 1 bytes from the
           payload buffer, causing an out-of-bounds read.
Impact: Heap memory corruption and potential information disclosure.
Evidence: evidence/fuzzing/flag5.log containing ASan heap-buffer-overflow
          error signature.

