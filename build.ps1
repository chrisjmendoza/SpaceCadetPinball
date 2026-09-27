# One-command Windows build. Works from a normal PowerShell prompt:
# finds CMake (on PATH or bundled with Visual Studio), downloads SDL if needed, builds.
#   .\build.ps1                 Release x64 build into bin\Release
#   .\build.ps1 -Run            ...and start the game
#   .\build.ps1 -Config Debug   Debug build into bin\Debug
#   .\build.ps1 -Clean          Reconfigure from scratch
param(
	[ValidateSet('Release', 'Debug')][string]$Config = 'Release',
	[ValidateSet('x64', 'Win32')][string]$Arch = 'x64',
	[switch]$Run,
	[switch]$Clean
)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$cmake = (Get-Command cmake -ErrorAction SilentlyContinue).Source
if (-not $cmake)
{
	$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
	if (Test-Path $vswhere)
	{
		$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
		if ($vsPath)
		{
			$candidate = Join-Path $vsPath 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
			if (Test-Path $candidate) { $cmake = $candidate }
		}
	}
}
if (-not $cmake)
{
	throw "CMake not found. Install Visual Studio 2019 or newer with the 'Desktop development with C++' workload."
}

$buildDir = "build\$Arch"
if ($Clean -and (Test-Path $buildDir)) { Remove-Item -Recurse -Force $buildDir }

& $cmake -S . -B $buildDir -A $Arch -DCMAKE_WIN32_EXECUTABLE:BOOL=1
if ($LASTEXITCODE -ne 0) { throw "CMake configure failed" }
& $cmake --build $buildDir --config $Config --parallel
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

$exe = Join-Path $PSScriptRoot "bin\$Config\SpaceCadetPinball.exe"
Write-Host "`nBuilt $exe"
Write-Host "Game data (PINBALL.DAT or CADET.DAT and sounds) goes next to the .exe."
if ($Run) { Start-Process $exe -WorkingDirectory (Split-Path $exe) }
