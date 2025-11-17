cat > README.md << 'EOF'
# COBOL Check Automation

A powerful and automated testing framework designed to bring modern unit testing practices to COBOL development. This project leverages the excellent [Cobol-Check](https://github.com/neopragma/cobol-check) framework and wraps it in an automated pipeline to test COBOL programs seamlessly.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## 🚀 Overview

Testing COBOL applications can be a complex and manual process. This project aims to change that by providing a complete, self-contained environment to **compile, run, and validate** COBOL unit tests automatically.

By integrating `Cobol-Check` with a streamlined automation script, this solution allows developers to:
*   Write unit tests for COBOL programs in a simple, behavior-driven style.
*   Execute their entire test suite with a single command.
*   Integrate testing into CI/CD pipelines for mainframe or GnuCOBOL applications.
*   Accelerate development and improve code quality for critical business systems.

## ✨ Features

*   **Full Automation:** A single script handles the entire lifecycle: compilation, test execution, and cleanup.
*   **GnuCOBOL Ready:** Pre-configured for use with the open-source GnuCOBOL compiler.
*   **Cobol-Check Integration:** Utilizes the robust Cobol-Check testing framework under the hood.
*   **Simple Test Writing:** Write clear, concise unit tests using the Cobol-Check syntax.
*   **Sample Included:** Comes with a working example (`CALC.cbl` and its test `CALC_TEST.cbl`) to get you started immediately.
*   **Flexible & Configurable:** Easy to adapt for your specific project structure and dependencies.

## 📁 Project Structure

```bash
cobol-check-automation/
├── src/                    # Directory for your main COBOL source programs
│   └── CALC.cbl           # Example program under test
├── test/                  # Directory for your Cobol-Check test suites
│   └── CALC_TEST.cbl      # Example test suite for CALC.cbl
├── cobol-check/           # Cobol-Check framework (included as submodule)
├── scripts/
│   └── run_tests.sh       # Main automation script
├── lib/                   # Directory for copybooks (optional)
├── work/                  # Auto-generated working directory for compiled modules
└── temp/                  # Auto-generated directory for temporary files
