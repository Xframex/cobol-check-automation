#!/bin/bash
# mainframe_operations.sh

echo "Starting COBOL Check Unit Testing..."

ZOWE_USERNAME="$ZOWE_OPT_USER"
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
echo "Working with username: $ZOWE_USERNAME"

# Function to run COBOL Check unit tests
run_cobol_check_unit_tests() {
  program=$1
  echo "=== RUNNING COBOL CHECK FOR $program ==="
  
  # 1. Upload EMPPAY.CBL to the mainframe
  echo "1. Uploading $program.CBL to mainframe..."
  if [ -f "src/main/cobol/$program.CBL" ]; then
    zowe zos-files upload file-to-data-set "src/main/cobol/$program.CBL" "$ZOWE_USERNAME.CBL($program)" --response-timeout 30
    echo "✓ Uploaded $program.CBL"
  else
    echo "✗ Error: src/main/cobol/$program.CBL not found"
    return 1
  fi
  
  # 2. Upload test suite if it exists
  if [ -f "src/test/cobol/$program/$program.cut" ]; then
    echo "Uploading test suite $program.cut..."
    zowe zos-files upload file-to-data-set "src/test/cobol/$program/$program.cut" "$ZOWE_USERNAME.CUT($program)" --response-timeout 30
  fi
  
  # 3. Run COBOL Check on EMPPAY
  echo "2. Running COBOL Check on $program..."
  echo "Changing to cobolcheck directory and executing..."
  
  # Execute COBOL Check on the mainframe
  zowe ssh issue command "cd /z/$LOWERCASE_USERNAME/cobolcheck && ./cobolcheck -p $program" --host "$ZOWE_OPT_HOST" --user "$ZOWE_OPT_USER" --password "$ZOWE_OPT_PASSWORD" --response-timeout 120
  
  # 4. Check if COBOL Check generated the CC##99.CBL file
  echo "3. Checking for generated test program..."
  zowe zos-files list uss "/z/$LOWERCASE_USERNAME/cobolcheck" --response-timeout 30 | grep "CC##99.CBL" && echo "✓ CC##99.CBL generated" || echo "✗ CC##99.CBL not found"
  
  # 5. Copy CC##99.CBL to the MVS dataset
  echo "4. Copying CC##99.CBL to MVS dataset..."
  zowe ssh issue command "cd /z/$LOWERCASE_USERNAME/cobolcheck && cp CC##99.CBL '//''$ZOWE_USERNAME.CBL($program)''" --host "$ZOWE_OPT_HOST" --user "$ZOWE_OPT_USER" --password "$ZOWE_OPT_PASSWORD" --response-timeout 60
  
  # Verify the copy worked
  zowe zos-files list ams-files "$ZOWE_USERNAME.CBL" --response-timeout 30 | grep "$program" && echo "✓ Successfully copied to $ZOWE_USERNAME.CBL($program)" || echo "✗ Copy failed"
  
  # 6. Upload and submit the EMPPAY.JCL job
  echo "5. Submitting $program.JCL job..."
  if [ -f "$program.JCL" ]; then
    zowe zos-files upload file-to-data-set "$program.JCL" "$ZOWE_USERNAME.JCL($program)" --response-timeout 30
    
    JOB_ID=$(zowe jobs submit data-set "$ZOWE_USERNAME.JCL($program)" --rff jobid --rft string --response-timeout 60)
    
    if [ -n "$JOB_ID" ]; then
      echo "✓ Job submitted successfully. Job ID: $JOB_ID"
      
      # Wait for job to complete
      echo "Waiting for job completion..."
      sleep 30
      
      # Check job status
      JOB_STATUS=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff status --rft string --response-timeout 30)
      JOB_RC=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff retcode --rft string --response-timeout 30)
      
      echo "Job status: $JOB_STATUS"
      echo "Job return code: $JOB_RC"
      
      # Show job output
      echo "=== JOB OUTPUT ==="
      zowe jobs view spool-file-by-id "$JOB_ID" 2 --response-timeout 30
      zowe jobs view spool-file-by-id "$JOB_ID" 3 --response-timeout 30
      
      if [ "$JOB_RC" = "CC 0000" ]; then
        echo "🎉 $program unit tests completed successfully!"
        return 0
      else
        echo "❌ $program unit tests failed"
        return 1
      fi
    else
      echo "✗ Failed to submit job"
      return 1
    fi
  else
    echo "✗ $program.JCL not found"
    return 1
  fi
}

# Function for regular program execution (without COBOL Check)
run_regular_program() {
  program=$1
  echo "=== Running $program (Regular Execution) ==="
  
  if [ -f "src/main/cobol/$program.CBL" ]; then
    zowe zos-files upload file-to-data-set "src/main/cobol/$program.CBL" "$ZOWE_USERNAME.CBL($program)" --response-timeout 30
  fi
  
  if [ -f "$program.JCL" ]; then
    zowe zos-files upload file-to-data-set "$program.JCL" "$ZOWE_USERNAME.JCL($program)" --response-timeout 30
    
    JOB_ID=$(zowe jobs submit data-set "$ZOWE_USERNAME.JCL($program)" --rff jobid --rft string --response-timeout 60)
    
    if [ -n "$JOB_ID" ]; then
      echo "✓ Job submitted. Job ID: $JOB_ID"
      sleep 20
      
      JOB_RC=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff retcode --rft string --response-timeout 30)
      echo "Return code: $JOB_RC"
      
      echo "=== OUTPUT ==="
      zowe jobs view spool-file-by-id "$JOB_ID" 2 --response-timeout 30
      zowe jobs view spool-file-by-id "$JOB_ID" 3 --response-timeout 30
    fi
  fi
}

# Main execution
echo "🔬 COBOL CHECK UNIT TESTING LAB"

# Test EMPPAY with COBOL Check unit tests
echo "=========================================="
run_cobol_check_unit_tests "EMPPAY"

# Also test NUMBERS regularly to compare
echo "=========================================="
echo "CONTROL TEST: NUMBERS (without COBOL Check)"
run_regular_program "NUMBERS"

echo "=========================================="
echo "UNIT TESTING LAB COMPLETED"
