<#
.SYNOPSIS
    Configures a newly provisioned Windows 10 or 11 virtual machine with development tools.
.DESCRIPTION
    This script installs necessary software and configures settings for a development workstation.
.NOTES
    Author: Arthur Musaelian
    Requires: PowerShell 5.0 or higher
    Run as Administrator
#>

# Exit script if not running as Administrator
#Requires -RunAsAdministrator

# Check for Winget and configure it on Windows 11
function Reset-Winget {
  [CmdletBinding()]
  param ()

  try {
      Write-Host "Checking the operating system version..."

      # Get the operating system version
      $operatingSystemVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption

      if ($operatingSystemVersion -like "*Windows 11*") {
          Write-Host "Configuring Winget for Windows 11..."

          # Install NuGet package provider
          Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop

          # Set the PowerShell gallery repository as trusted
          Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction Stop

          # Install the Winget installation script
          Install-Script -Name winget-install -Force -ErrorAction Stop

          # Run the Winget installation script
          & winget-install.ps1 -Force -ErrorAction Stop

          # Reset the Winget source and upgrade AppInstaller
          winget source reset --force
          winget upgrade Microsoft.AppInstaller -ErrorAction Stop

          Write-Host "Winget configuration completed."
      }
      else {
          Write-Host "Winget configuration not required for this OS."
      }
  }
  catch {
      Write-Error "An error occurred during the Winget configuration process: $_"
  }
}

function Install-PowerShell7 {
  [CmdletBinding()]
  param ()

  try {
      # Check if PowerShell 7 is installed
      $ps7Installed = Test-Path -Path "$env:ProgramFiles\PowerShell\7\pwsh.exe"

      if ($ps7Installed) {
          Write-Host "PowerShell 7 is already installed."
      }
      else {
          Write-Host "PowerShell 7 is not installed. Installing..."
          winget install --id Microsoft.Powershell --source winget
      }
  }
  catch {
      Write-Error "Failed to install PowerShell 7: $_"
  }
}

function Enable-VmFeatures {
  [CmdletBinding()]
  param ()

  try {
      # Check and enable necessary Windows features for Virtualization and Containerization
      Write-Host "Checking and enabling necessary Windows features for virtualization..."
      $features = @("VirtualMachinePlatform", "Microsoft-Hyper-V", "Containers")
      foreach ($feature in $features) {
          if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).State -ne 'Enabled') {
              Write-Host "Enabling $feature feature..."
              Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -All
          }
          else {
              Write-Host "$feature feature is already enabled."
          }
      }
  }
  catch {
      Write-Error "An error occurred while enabling necessary Windows features for virtualization: $_"
  }
}

# Function to install Chocolatey if not already installed
function Install-Chocolatey {
  [CmdletBinding()]
  param ()

  if (-not (Test-Path -Path "$env:ProgramData\Chocolatey")) {
      Write-Host "Installing Chocolatey..."
      Set-ExecutionPolicy Bypass -Scope Process -Force
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  } else {
      Write-Host "Chocolatey is already installed."
  }
}

# Function to install a package using Chocolatey
function Install-Package {
  [CmdletBinding()]
  param (
      [string]$PackageName
  )
  Write-Host "Installing $PackageName..."
  choco install $PackageName -Confirm:$false
}

function Install-AWSModules {
  [CmdletBinding()]
  param ()

  try {
      # Check if the AWS.Tools.Installer module is already installed
      if (-not (Get-Module -ListAvailable -Name AWS.Tools.Installer -ErrorAction SilentlyContinue)) {
          # Update NuGet Package Provider
          Try {
              Write-Host "Updating NuGet Package Provider..."
              Install-PackageProvider -Name NuGet -Force
              Write-Host "NuGet Package Provider updated successfully."
          }
          Catch {
              Write-Error "Failed to update NuGet Package Provider. Error: $_"
          }
          Write-Host "Installing AWS.Tools.Installer module..."
          Install-Module -Name AWS.Tools.Installer -Force
      } else {
          Write-Host "AWS.Tools.Installer module is already installed."
      }

      # Import the AWS.Tools.Installer module
      Import-Module AWS.Tools.Installer

      # Install the AWS.Tools.EC2 and AWS.Tools.S3 modules
      Write-Host "Installing AWS.Tools.EC2 and AWS.Tools.S3 modules..."
      Install-AWSToolsModule -Name AWS.Tools.EC2, AWS.Tools.S3 -CleanUp -Force

      Write-Host "AWS.Tools.EC2 and AWS.Tools.S3 modules installed successfully."
  }
  catch {
      Write-Error "An error occurred: $_"
  }
  finally {
      Write-Host "Installation process completed."
  }
}

# Define the list of packages to install
$Packages = @(
  'awscli',
  'googlechrome',
  'git',
  'microsoft-windows-terminal',
  'postman',
  'vlc',
  'vscode',
  'notepadplusplus',
  'firefox',
  'python3',
  'nodejs',
  '7zip',
  'terraform',
  'dropbox',
  'kubernetes-cli',
  'docker-desktop',
  'javaruntime',
  'azure-cli',
  'figma',
  'putty',
  'mobaxterm',
  'yarn',
  'mysql.workbench'
)

# Main script
try {
  Reset-Winget
  Install-PowerShell7
  Install-AWSModules
  Install-Chocolatey
  foreach ($PackageName in $Packages) {
      Install-Package -PackageName $PackageName
  }

  # Update the PATH environment variable
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

  wsl --install
  Enable-VmFeatures
  npm install -g @aws-amplify/cli

  Write-Host "The environment is almost set up. Do you want to reboot now? (y/n)"
  $response = Read-Host
  if ($response -match 'y|Y') {
      Write-Host "Rebooting computer..."
      Restart-Computer
  } else {
      Write-Host "Reboot cancelled."
  }
}
catch {
  Write-Host "An error occurred: $_" -ForegroundColor Red
}
