#!/bin/bash
# mainframe_operations.sh

echo "Starting mainframe operations..."

# Use the Zowe username from environment variable
ZOWE_USERNAME="$ZOWE_OPT_USER"
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

echo "Working with username: $ZOWE_USERNAME"

# Execute commands on the mainframe using Zowe CLI
echo "Changing to cobolcheck directory on mainframe..."
zowe zos-files list uss "/z/$LOWERCASE_USERNAME/cobolcheck" --response-timeout 30

echo "Listing files in cobolcheck directory:"
zowe zos-files list uss "/z/$LOWERCASE_USERNAME/cobolcheck" --response-timeout 30

# Function to run cobolcheck and copy files
run_cobolcheck() {
  program=$1
  echo "Running cobolcheck for $program"

  # Execute cobolcheck on the mainframe via SSH or shell command
  zowe ssh issue command "cd /z/$LOWERCASE_USERNAME/cobolcheck && ./cobolcheck -p $program" --host "$ZOWE_OPT_HOST" --user "$ZOWE_OPT_USER" --password "$ZOWE_OPT_PASSWORD" || echo "Cobolcheck execution completed for $program (exceptions may have occurred)"

  # Check if CC##99.CBL was created and copy it
  echo "Checking for CC##99.CBL and copying files for $program..."
  
  # Copy CC##99.CBL to MVS dataset if it exists
  zowe zos-files download uss-file "/z/$LOWERCASE_USERNAME/cobolcheck/CC##99.CBL" -f "./temp_cc99.cbl" --response-timeout 30 || echo "CC##99.CBL not found for $program"
  
  if [ -f "./temp_cc99.cbl" ]; then
    zowe zos-files upload file-to-data-set "./temp_cc99.cbl" "$ZOWE_USERNAME.CBL($program)" --response-timeout 30 && echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)" || echo "Failed to copy CC##99.CBL"
    rm -f "./temp_cc99.cbl"
  fi

  # Copy the JCL file if it exists in our repository
  if [ -f "$program.JCL" ]; then
    zowe zos-files upload file-to-data-set "$program.JCL" "$ZOWE_USERNAME.JCL($program)" --response-timeout 30 && echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)" || echo "Failed to copy ${program}.JCL"
  else
    echo "${program}.JCL not found in repository"
  fi
}

# Run for each program
for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck "$program"
done

echo "Mainframe operations completed"
