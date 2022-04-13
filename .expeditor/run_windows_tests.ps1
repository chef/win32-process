# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

# This will run ruby test on windows platform

Write-Output 'Downloading Ruby + DevKit'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile('https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.1-1/rubyinstaller-devkit-3.1.1-1-x64.exe', 'c:\\rubyinstaller-devkit-3.1.1-1-x64.exe')

Write-Output 'Installing Ruby + DevKit'
Start-Process c:\rubyinstaller-devkit-3.1.1-1-x64.exe -ArgumentList '/verysilent /dir=C:\\ruby31' -Wait 

Write-Output 'Cleaning up installation'
Remove-Item c:\rubyinstaller-devkit-3.1.1-1-x64.exe -Force

Write-Output "--- Bundle install"

bundle config --local path vendor/bundle
If ($lastexitcode -ne 0) { Exit $lastexitcode }

bundle install --jobs=7 --retry=3
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Bundle Execute"

bundle exec rake
If ($lastexitcode -ne 0) { Exit $lastexitcode }