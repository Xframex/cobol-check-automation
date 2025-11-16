#!/bin/bash
# zowe_operations.sh

# Use the environment variables that Zowe CLI recognizes
echo "Starting Zowe operations for user: $ZOWE_OPT_USER"

# Convert username to lowercase for directory path
LOWERCASE_USERNAME=$(echo "$ZOWE_OPT_USER" | tr '[:upper:]' '[:lower:]')

echo "Checking directory /z/$LOWERCASE_USERNAME/cobolcheck"

# Check if directory exists, create if it doesn't
if ! zowe zos-files list uss "/z/$LOWERCASE_USERNAME/cobolcheck" --response-timeout 30 &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck"
else
    echo "Directory already exists."
fi

# Upload files
echo "Uploading COBOL Check files..."
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "cobol-check-0.2.19.jar"

# Verify upload
echo "Verifying upload:"
zowe zos-files list uss "/z/$LOWERCASE_USERNAME/cobolcheck" --response-timeout 30

echo "Zowe operations completed successfully"
