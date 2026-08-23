; Inno Setup script for Kruftle.
; Version is supplied by CI: iscc /DAppVersion=1.2.3 kruftle.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
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
OutputBaseFilename=Kruftle-{#AppVersion}-windows-setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Per-user install needs no elevation; the app writes nothing outside its own
; data directory.
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
; /SILENT during a self-update relaunches the app when the installer finishes.
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent
