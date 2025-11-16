#!/bin/bash
# mainframe_operations.sh

echo "Starting automated job submission..."

ZOWE_USERNAME="$ZOWE_OPT_USER"
echo "Working with username: $ZOWE_USERNAME"

# Function to submit job and get detailed output
process_program() {
  program=$1
  echo "=== Processing $program ==="
  
  # Upload COBOL source code
  if [ -f "src/main/cobol/$program.CBL" ]; then
    echo "Uploading $program.CBL to mainframe..."
    zowe zos-files upload file-to-data-set "src/main/cobol/$program.CBL" "$ZOWE_USERNAME.CBL($program)" --response-timeout 30
  else
    echo "Error: $program.CBL not found in repository"
    return 1
  fi
  
  # Upload JCL file
  if [ -f "$program.JCL" ]; then
    echo "Uploading $program.JCL to mainframe..."
    zowe zos-files upload file-to-data-set "$program.JCL" "$ZOWE_USERNAME.JCL($program)" --response-timeout 30
  else
    echo "Error: $program.JCL not found in repository"
    return 1
  fi
  
  # Submit the job
  echo "Submitting job for $program..."
  JOB_ID=$(zowe jobs submit data-set "$ZOWE_USERNAME.JCL($program)" --rff jobid --rft string --response-timeout 60)
  
  if [ -n "$JOB_ID" ]; then
    echo "✓ Job submitted successfully. Job ID: $JOB_ID"
    
    # Wait for job to complete
    echo "Waiting for job to complete..."
    sleep 20
    
    # Check job status
    JOB_STATUS=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff status --rft string --response-timeout 30)
    echo "Job status: $JOB_STATUS"
    
    # Get job return code
    JOB_RC=$(zowe jobs view job-status-by-jobid "$JOB_ID" --rff retcode --rft string --response-timeout 30)
    echo "Job return code: $JOB_RC"
    
    # Get detailed compilation output
    echo "=== COMPILATION OUTPUT ==="
    zowe jobs view spool-file-by-id "$JOB_ID" 2 --response-timeout 30
    
    # Check if compilation was successful
    if [ "$JOB_RC" = "CC 0000" ] || [ "$JOB_RC" = "null" ]; then
      echo "✓ Job completed successfully"
      return 0
    else
      echo "✗ Job completed with issues. Return code: $JOB_RC"
      echo "Check the compilation output above for COBOL syntax errors."
      return 1
    fi
    
  else
    echo "✗ Failed to submit job for $program"
    return 1
  fi
}

# Process just NUMBERS for now
for program in NUMBERS; do
  if process_program "$program"; then
    echo "✓ Successfully processed $program"
  else
    echo "✗ Failed to process $program"
  fi
  echo "----------------------------------------"
done

echo "Automated job submission completed"
