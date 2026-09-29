#ifndef PackageDir
  #error PackageDir must point to the staged Windows package.
#endif
#ifndef AppVersion
  #error AppVersion must be provided by build-windows.ps1.
#endif
#ifndef OutputDir
  #error OutputDir must be provided by build-windows.ps1.
#endif

[Setup]
AppId={{71D2CF86-DB75-4C75-B80A-23C167723FE1}
AppName=Foxtopia
AppVersion={#AppVersion}
AppPublisher=KlausennGames
DefaultDirName={localappdata}\KlausennGames\common\Foxtopia
DefaultGroupName=KlausennGames\Foxtopia
DisableDirPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=Foxtopia-Setup-{#AppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\Foxtopia.ico
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"

[CustomMessages]
english.DesktopShortcut=Create a desktop shortcut
turkish.DesktopShortcut=Masaüstü kısayolu oluştur
english.ExtraOptions=Additional options:
turkish.ExtraOptions=Ek seçenekler:
english.LaunchGame=Launch Foxtopia
turkish.LaunchGame=Foxtopia'yı başlat

[Files]
Source: "{#PackageDir}\*"; DestDir: "{app}"; Excludes: "current.json"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#PackageDir}\current.json"; DestDir: "{app}"; Flags: ignoreversion

[INI]
Filename: "{app}\launcher-language.ini"; Section: "Locale"; Key: "Language"; String: "{language}"

[Icons]
Name: "{autoprograms}\Foxtopia"; Filename: "{app}\FoxtopiaLauncher.exe"; IconFilename: "{app}\Foxtopia.ico"; WorkingDir: "{app}"
Name: "{autodesktop}\Foxtopia"; Filename: "{app}\FoxtopiaLauncher.exe"; IconFilename: "{app}\Foxtopia.ico"; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:DesktopShortcut}"; GroupDescription: "{cm:ExtraOptions}"

[Run]
Filename: "{app}\FoxtopiaLauncher.exe"; Description: "{cm:LaunchGame}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\versions"
Type: filesandordirs; Name: "{app}\updates"
Type: filesandordirs; Name: "{app}\logs"
Type: files; Name: "{app}\current.json"

