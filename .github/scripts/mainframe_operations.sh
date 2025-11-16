#!/bin/bash
# mainframe_operations.sh

echo "Starting COBOL Test-Driven Development..."

ZOWE_USERNAME="$ZOWE_OPT_USER"
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
echo "Working with username: $ZOWE_USERNAME"

# Function for Test-Driven Development
test_driven_development() {
  program=$1
  echo "🧪 TEST-DRIVEN DEVELOPMENT: $program"
  
  # Step 1: Upload tests FIRST (TDD principle)
  echo "1. Uploading tests FIRST (TDD)..."
  if [ -f "src/test/cobol/$program.cut" ]; then
    zowe zos-files upload file-to-data-set "src/test/cobol/$program.cut" "$ZOWE_USERNAME.CUT($program)" --response-timeout 30
    echo "✓ Tests uploaded"
    
    # Display test cases
    echo "Test Cases:"
    cat "src/test/cobol/$program.cut"
  else
    echo "✗ No test cases found for $program"
    return 1
  fi
  
  # Step 2: Upload the program (written to pass tests)
  echo "2. Uploading $program program..."
  if [ -f "src/main/cobol/$program.CBL" ]; then
    zowe zos-files upload file-to-data-set "src/main/cobol/$program.CBL" "$ZOWE_USERNAME.CBL($program)" --response-timeout 30
    echo "✓ Program uploaded"
  else
    echo "✗ Program not found for $program"
    return 1
  fi
  
  # Step 3: Run COBOL Check to generate test version
  echo "3. Running COBOL Check (generating test program)..."
  zowe ssh issue command "cd /z/$LOWERCASE_USERNAME/cobolcheck && ./cobolcheck -p $program" --host "$ZOWE_OPT_HOST" --user "$ZOWE_OPT_USER" --password "$ZOWE_OPT_PASSWORD" --response-timeout 120
  
  # Step 4: Use special JCL to copy and compile
  echo "4. Using TDD-specific JCL for $program..."
  if [ -f "$program.JCL" ]; then
    zowe zos-files upload file-to-data-set "$program.JCL" "$ZOWE_USERNAME.JCL($program)" --response-timeout 30
    
    JOB_ID=$(zowe jobs submit data-set "$ZOWE_USERNAME.JCL($program)" --rff jobid --rft string --response-timeout 60)
    
    if [ -n "$JOB_ID" ]; then
      echo "✓ TDD job submitted. Job ID: $JOB_ID"
      
      # Wait for job completion
      echo "Waiting for TDD test execution..."
      sleep 30
      
      # Check results
      JOB_RC=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff retcode --rft string --response-timeout 30)
      echo "Job return code: $JOB_RC"
      
      # Show test results
      echo "=== TDD TEST RESULTS ==="
      zowe jobs view spool-file-by-id "$JOB_ID" 2 --response-timeout 30
      
      echo "=== PROGRAM OUTPUT ==="
      zowe jobs view spool-file-by-id "$JOB_ID" 3 --response-timeout 30
      
      if [ "$JOB_RC" = "CC 0000" ]; then
        echo "🎉 TDD SUCCESS: All tests passed for $program!"
        return 0
      else
        echo "❌ TDD FAILURE: Tests failed for $program"
        echo "This is expected in TDD - now refine your code!"
        return 1
      fi
    fi
  else
    echo "✗ JCL not found for $program"
    return 1
  fi
}

# Function for regular unit testing (from previous lab)
run_cobol_check_unit_tests() {
  program=$1
  echo "=== UNIT TESTING: $program ==="
  # ... (keep the previous unit testing code for EMPPAY)
}

# Function for regular program execution
run_regular_program() {
  program=$1
  echo "=== REGULAR EXECUTION: $program ==="
  # ... (keep the previous regular execution code for NUMBERS)
}

# Main TDD Execution Flow
echo "🚀 COBOL TEST-DRIVEN DEVELOPMENT LAB"

echo "=========================================="
echo "1. TDD APPROACH - DEPTPAY"
echo "   - Tests written FIRST"
echo "   - Code written to pass tests"
echo "   - Automated validation"
echo "=========================================="
test_driven_development "DEPTPAY"

echo "=========================================="
echo "2. UNIT TESTING - EMPPAY (for comparison)"
echo "=========================================="
run_cobol_check_unit_tests "EMPPAY"

echo "=========================================="
echo "3. REGULAR EXECUTION - NUMBERS (control)"
echo "=========================================="
run_regular_program "NUMBERS"

echo "=========================================="
echo "🎓 TDD LAB COMPLETED"
echo "=========================================="
