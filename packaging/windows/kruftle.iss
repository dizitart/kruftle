; Inno Setup script for Kruftle.
; CI supplies both values:
;   iscc /DAppVersion=1.2.3 /DTargetArch=x64 kruftle.iss
; TargetArch is the Flutter target directory name — x64 or arm64 — and picks
; both the build output to package and what the installer says it supports.

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
; Per-user install needs no elevation; the app writes nothing outside its own
; data directory.
PrivilegesRequiredOverridesAllowed=dialog

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
; /SILENT during a self-update relaunches the app when the installer finishes.
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent
