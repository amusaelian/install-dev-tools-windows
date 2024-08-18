# Install Development Tools on Windows with PowerShell

This PowerShell script provisions a newly deployed Windows 10 or 11 virtual machine with development tools. 

## Features

- Fixes Winget on Windows 11.
- Installs PowerShell 7 and Windows Subsystem for Linux
- Enables necessary Windows features for virtualization and containerization.
- Installs Chocolatey and a list of essential development tools.
- Installs AWS PowerShell modules and Amplify CLI.

The script installs the following packages via the Chocolatey package manager:

- 7-Zip
- AWS CLI
- Azure CLI
- Docker Desktop
- Dropbox
- Figma
- Firefox
- Git
- Google Chrome
- Java Runtime
- Kubernetes CLI
- MobaXterm
- MySQL Workbench
- Node.js
- Notepad++
- Postman
- PuTTY
- Python 3
- Terraform
- Visual Studio Code
- VLC Media Player
- Windows Terminal
- Yarn

## Requirements

- PowerShell 5.0 or higher.
- Administrator privileges.

## Installation and Usage

1. Download the script or clone the repository::

    ```powershell
    git clone https://github.com/amusaelian/your-repo.git
    ```
2. Open PowerShell as an Administrator.

3. Navigate to the repository directory:

    ```powershell
    cd your-repo
    ```

4. Run the script:

    ```powershell
    .\Setup-DevWorkstation.ps1
    ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](https://opensource.org/license/MIT) file for details.

