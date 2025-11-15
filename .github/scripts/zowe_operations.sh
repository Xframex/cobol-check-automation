#!/bin/bash
set -e  # Exit on any error

# Your specific username
USERNAME="z63170"
COBOLCHECK_DIR="/z/$USERNAME/cobolcheck"

echo "Working with username: $USERNAME"
echo "Target directory: $COBOLCHECK_DIR"

# Check if Zowe CLI is available
if ! command -v zowe &> /dev/null; then
    echo "Error: Zowe CLI is not installed or not in PATH"
    exit 1
fi

# Verify Zowe connection
echo "Testing Zowe connection to /z/$USERNAME..."
if ! zowe zos-files list uss "/z/$USERNAME" &>/dev/null; then
    echo "Error: Cannot access /z/$USERNAME. Check credentials and permissions."
    exit 1
fi

# Check if cobolcheck directory exists, create if it doesn't
echo "Checking if directory $COBOLCHECK_DIR exists..."
if ! zowe zos-files list uss-files "$COBOLCHECK_DIR" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$COBOLCHECK_DIR"
    echo "Directory created successfully."
else
    echo "Directory already exists."
fi

# Upload files
echo "Uploading cobol-check files..."
zowe zos-files upload dir-to-uss "./cobol-check" "$COBOLCHECK_DIR" --recursive --binary-files "cobol-check-0.2.9.jar"

# Verify upload
echo "Verifying upload contents:"
zowe zos-files list uss-files "$COBOLCHECK_DIR" --recursive

echo "Zowe operations completed successfully for user $USERNAME!"
