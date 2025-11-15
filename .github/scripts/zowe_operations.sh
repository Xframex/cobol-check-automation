#!/bin/bash
# zowe_operations.sh

# ----------------------------
# 1️⃣ Ensure Node.js and Zowe CLI are available
# ----------------------------
if ! command -v zowe &> /dev/null
then
    echo "Zowe CLI not found. Installing..."
    # Install Node.js if not present (minimal check)
    if ! command -v node &> /dev/null
    then
        echo "Node.js not found. Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi
    # Install Zowe CLI
    npm install -g @zowe/cli
fi

# Make sure npm global binaries are in PATH
export PATH=$PATH:$(npm bin -g)

# ----------------------------
# 2️⃣ Convert username to lowercase
# ----------------------------
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# ----------------------------
# 3️⃣ Check if directory exists, create if it doesn't
# ----------------------------
TARGET_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"
if ! zowe zos-files list uss-files "$TARGET_DIR" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$TARGET_DIR"
else
    echo "Directory already exists."
fi

# ----------------------------
# 4️⃣ Upload files
# ----------------------------
zowe zos-files upload dir-to-uss "./cobol-check" "$TARGET_DIR" --recursive --binary-files "cobol-check-0.2.9.jar"

# ----------------------------
# 5️⃣ Verify upload
# ----------------------------
echo "Verifying upload:"
zowe zos-files list uss-files "$TARGET_DIR"
