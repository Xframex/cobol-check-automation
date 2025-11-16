#!/bin/bash
# mainframe_operations.sh

echo "Starting COBOL Unit Testing with COBOL Check..."

ZOWE_USERNAME="$ZOWE_OPT_USER"
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
echo "Working with username: $ZOWE_USERNAME"

# Function to run COBOL Check tests
run_cobol_check_tests() {
  program=$1
  echo "=== Running COBOL Check Unit Tests for $program ==="
  
  # Upload COBOL source code
  if [ -f "src/main/cobol/$program.CBL" ]; then
    echo "Uploading $program.CBL to mainframe..."
    zowe zos-files upload file-to-data-set "src/main/cobol/$program.CBL" "$ZOWE_USERNAME.CBL($program)" --response-timeout 30
  else
    echo "Error: $program.CBL not found"
    return 1
  fi
  
  # Upload test files if they exist
  if [ -f "src/test/cobol/$program/$program.cut" ]; then
    echo "Uploading $program test suite to mainframe..."
    zowe zos-files upload file-to-data-set "src/test/cobol/$program/$program.cut" "$ZOWE_USERNAME.CBL($program""T)" --response-timeout 30
  fi
  
  # Upload JCL
  if [ -f "$program.JCL" ]; then
    echo "Uploading $program.JCL to mainframe..."
    zowe zos-files upload file-to-data-set "$program.JCL" "$ZOWE_USERNAME.JCL($program)" --response-timeout 30
  else
    echo "Error: $program.JCL not found"
    return 1
  fi
  
  # Run COBOL Check on the mainframe
  echo "Running COBOL Check for $program..."
  zowe ssh issue command "cd /z/$LOWERCASE_USERNAME/cobolcheck && ./cobolcheck -p $program" --host "$ZOWE_OPT_HOST" --user "$ZOWE_OPT_USER" --password "$ZOWE_OPT_PASSWORD" --response-timeout 120
  
  # Check if COBOL Check generated the test program
  echo "Checking for generated test program..."
  zowe zos-files list uss "/z/$LOWERCASE_USERNAME/cobolcheck" --response-timeout 30 | grep "CCH#99.CBL" && echo "✓ COBOL Check generated test program" || echo "✗ COBOL Check failed to generate test program"
  
  # Submit the compilation and test job
  echo "Submitting test job for $program..."
  JOB_ID=$(zowe jobs submit data-set "$ZOWE_USERNAME.JCL($program)" --rff jobid --rft string --response-timeout 60)
  
  if [ -n "$JOB_ID" ]; then
    echo "✓ Test job submitted successfully. Job ID: $JOB_ID"
    
    # Wait for job to complete
    echo "Waiting for test execution to complete..."
    sleep 30
    
    # Check job status
    JOB_STATUS=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff status --rft string --response-timeout 30)
    echo "Job status: $JOB_STATUS"
    
    # Get job return code
    JOB_RC=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff retcode --rft string --response-timeout 30)
    echo "Job return code: $JOB_RC"
    
    # Get test output
    echo "=== UNIT TEST RESULTS for $program ==="
    zowe jobs view spool-file-by-id "$JOB_ID" 2 --response-timeout 30
    
    echo "=== PROGRAM OUTPUT ==="
    zowe jobs view spool-file-by-id "$JOB_ID" 3 --response-timeout 30
    
    if [ "$JOB_RC" = "CC 0000" ]; then
      echo "✓ $program unit tests executed successfully!"
      return 0
    else
      echo "✗ $program unit tests failed with return code: $JOB_RC"
      return 1
    fi
    
  else
    echo "✗ Failed to submit test job for $program"
    return 1
  fi
}

# Function for regular program execution (without COBOL Check)
run_regular_program() {
  program=$1
  echo "=== Running $program normally ==="
  
  # Upload and submit as before
  # ... (keep our previous working code for NUMBERS)
}

# Run tests for EMPPAY with COBOL Check
echo "🔬 STARTING UNIT TESTING LAB"
run_cobol_check_tests "EMPPAY"

# Run NUMBERS normally (as our control)
echo "🔧 RUNNING CONTROL TEST"
run_regular_program "NUMBERS"

echo "Unit testing lab completed"
