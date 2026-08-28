; Inno Setup script for Kruftle.
; CI supplies both values:
;   iscc /DAppVersion=1.2.3 /DTargetArch=x64 kruftle.iss
; TargetArch is the Flutter target directory name — x64 or arm64 — and picks
; both the build output to package and what the installer says it supports.
;
; Unattended install and uninstall, which is what the Microsoft Store's EXE
; submission asks for:
;   Kruftle-1.2.3-windows-x64-setup.exe /VERYSILENT /NORESTART
;   unins000.exe /VERYSILENT /NORESTART
; Add /ALLUSERS for a machine-wide install (needs elevation); without it the
; install is per-user and needs none. Both return 0 on success and neither ever
; asks for a reboot — see RestartIfNeededByRun below.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#ifndef TargetArch
  #define TargetArch "x64"
#endif

#define AppName "Kruftle"
#define AppPublisher "Dizitart"
#define AppURL "https://github.com/dizitart/kruftle"
#define AppExeName "kruftle.exe"

[Setup]
AppId={{7C4F2E31-9A5B-4D8C-B1E6-3F0A2D7C8E45}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}/issues
AppUpdatesURL={#AppURL}/releases
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
LicenseFile=..\..\LICENSE
OutputBaseFilename=Kruftle-{#AppVersion}-windows-{#TargetArch}-setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; An arm64 installer refuses to run on x64; the x64 one is accepted on arm64
; too, because Windows emulates it — but the arm64 build is the one an arm64
; machine should be offered, and the updater picks by processor.
#if TargetArch == "arm64"
ArchitecturesAllowed=arm64
ArchitecturesInstallIn64BitMode=arm64
#else
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
#endif

; Per-user by default, into %LOCALAPPDATA%\Programs\Kruftle, which is where
; {autopf} resolves without elevation.
;
; This is not only about sparing the user a UAC prompt. Kruftle updates itself
; by unpacking the new build beside the installed one and renaming the two — no
; installer, the way VS Code does it — and that needs the install directory's
; parent to be writable by the person running Kruftle. Under C:\Program Files
; it is not, and the app falls back to downloading and running this installer
; instead. Per-user is what makes the quiet path the normal one.
;
; `commandline` and not `dialog`: an install mode page on every install is
; friction for the one case in a hundred that wants machine-wide, and
; /ALLUSERS covers that case exactly. UsePreviousPrivileges keeps an existing
; machine-wide install machine-wide when it is upgraded.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline
UsePreviousPrivileges=yes

; Nothing here is ever worth a reboot: Restart Manager closes a running Kruftle
; and starts it again, and no file this package installs is ever in use by
; anything else. /NORESTART is honoured regardless; these say the installer
; would not have asked in the first place.
RestartIfNeededByRun=no
CloseApplications=yes
RestartApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "..\..\build\windows\{#TargetArch}\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
; `skipifsilent`, so an unattended install starts nothing. A self-update that
; falls back to this installer passes /RESTARTAPPLICATIONS, and it is Restart
; Manager — not this line — that brings Kruftle back.
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent
