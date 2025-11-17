COBOL Check Automation
A powerful and automated testing framework designed to bring modern unit testing practices to COBOL development. This project leverages the excellent Cobol-Check framework and wraps it in an automated pipeline to test COBOL programs seamlessly.

https://img.shields.io/badge/License-MIT-yellow.svg
https://img.shields.io/badge/PRs-welcome-brightgreen.svg

🚀 Overview
Testing COBOL applications can be a complex and manual process. This project aims to change that by providing a complete, self-contained environment to compile, run, and validate COBOL unit tests automatically.

By integrating Cobol-Check with a streamlined automation script, this solution allows developers to:

Write unit tests for COBOL programs in a simple, behavior-driven style.

Execute their entire test suite with a single command.

Integrate testing into CI/CD pipelines for mainframe or GnuCOBOL applications.

Accelerate development and improve code quality for critical business systems.

✨ Features
Full Automation: A single script handles the entire lifecycle: compilation, test execution, and cleanup.

GnuCOBOL Ready: Pre-configured for use with the open-source GnuCOBOL compiler.

Cobol-Check Integration: Utilizes the robust Cobol-Check testing framework under the hood.

Simple Test Writing: Write clear, concise unit tests using the Cobol-Check syntax.

Sample Included: Comes with a working example (CALC.cbl and its test CALC_TEST.cbl) to get you started immediately.

Flexible & Configurable: Easy to adapt for your specific project structure and dependencies.

📁 Project Structure
bash
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
🛠️ Prerequisites
Before you begin, ensure you have the following installed on your system:

GnuCOBOL: The open-source COBOL compiler.

On Ubuntu/Debian: sudo apt-get install open-cobol or gnucobol

On macOS (using Homebrew): brew install gnu-cobol

On Windows: Download from SourceForge.

Bash Shell: The scripts are written for a Unix-like environment (Linux, macOS, WSL on Windows).

Git: To clone the repository and its submodules.

🚦 Getting Started
1. Clone the Repository
bash
git clone https://github.com/Xframex/cobol-check-automation.git
cd cobol-check-automation
2. Initialize the Cobol-Check Submodule
This project uses Cobol-Check as a Git submodule. You need to initialize and update it.

bash
git submodule init
git submodule update
3. Make the Script Executable
bash
chmod +x scripts/run_tests.sh
4. Run the Example Test!
The project comes with a ready-to-run example. Execute the automation script from the project's root directory.

bash
./scripts/run_tests.sh
You should see output similar to the following, indicating that the tests were discovered, compiled, run, and passed:

text
========================================
Setting up environment...
========================================
Environment setup complete.

========================================
Running COBOL Check for test: CALC_TEST.cbl
========================================
...
Cobol-check version 0.1.0
Feature: CALC-TEST
  Test cases for the CALC program

  Scenario: Test addition of two positive numbers
    When ADDITION with A = 5, B = 3
    Then EXPECT RESULT = 8

  Scenario: Test subtraction where result is positive
    When SUBTRACT with A = 10, B = 4
    Then EXPECT RESULT = 6

  Scenario: Test subtraction where result is negative
    When SUBTRACT with A = 4, B = 10
    Then EXPECT RESULT = -6

4 scenarios tested, 0 failed.
========================================
Test run finished.
========================================
📝 How to Write Your Own Tests
Place your COBOL Program: Put the COBOL program you want to test (e.g., MYPROG.cbl) in the src/ directory.

Create a Test Suite: Create a new test file in the test/ directory. The name should be descriptive, e.g., MYPROG_TEST.cbl.

Follow the Cobol-Check Syntax: Use the UT prefixes and the Gherkin-style keywords (TESTSUITE, BEFORE-EACH, TESTCASE, etc.) as shown in the CALC_TEST.cbl example.

A basic test case looks like this:

cobol
       TESTCASE "Verify successful transaction"
       MOVE 100 TO WS-INPUT-AMOUNT
       MOVE "DEPOSIT" TO WS-TRANSACTION-TYPE
       UT-MOCK
       MOVE "SUCCESS" UT-RESULT
       UT-PROCESS-MOCK
       CALL "MYPROG" USING WS-INPUT-AMOUNT
                           WS-TRANSACTION-TYPE
                           WS-OUTPUT-STATUS
       EXPECT WS-OUTPUT-STATUS TO BE "SUCCESS"
For a complete guide on the Cobol-Check syntax, please refer to the official Cobol-Check Documentation.

🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request

Please see CONTRIBUTING.md for more details.

📜 License
Distributed under the MIT License. See LICENSE file for more information.

🙏 Acknowledgments
A huge thank you to the team at Neopragma for creating and maintaining the fantastic Cobol-Check framework.

The GnuCOBOL team for providing a robust, open-source COBOL compiler.

