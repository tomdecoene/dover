; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=AddOne
AppVerName=AddOne - BRANCH - TAG
AppVersion=TAG
AppPublisher=GWEAdded
AppPublisherURL=http://www.gweadded.com.br
AppSupportURL=http://www.gweadded.com.br
AppUpdatesURL=http://www.gweadded.com.br
DefaultDirName={code:GetDefaultAddOnDir}
DisableDirPage=yes
Compression=lzma
SolidCompression=yes
UsePreviousAppDir=no
AppendDefaultDirName=yes
Uninstallable=yes

[Files]
Source: "AddOnInstallAPI.exe"; DestDir: {app}; Flags: ignoreversion
Source: "Dover.exe"; DestDir: {app}; Flags: ignoreversion
Source: "Framework.dll"; DestDir: {app}; Flags: ignoreversion
[Registry]
Root: HKLM; Subkey: "Software\Dover"
Root: HKLM; Subkey: "Software\Dover\Frameworkx64"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\Dover\Frameworkx64"; ValueType: string; ValueName: "InstallPathx64"; ValueData: "{app}"

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"

[Messages]
en.BeveledLabel=English

[CustomMessages]
en.MyDescription=My description
en.MyAppName=My Program
en.MyAppVerName=My Program %1


[Code]
//-Public Vars
var
  CurrentLocation : string;
  AddOnDir : string;
  FinishedInstall : Boolean;
  Uninstalling : Boolean;

//-Check if the application is installed;
//- if yes --> suggest to Remove
//- if no --> Install
function CheckInstalled(): boolean;
  var
    ResultCode: Integer;
  begin
    result := False;
    //-if find...
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'Software\Dover\Frameworkx64','InstallPathx64', CurrentLocation) then
      begin
        //-...Execute the uninstall to remove
        Exec(CurrentLocation + '\unins000.exe', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
        result := True;
      end;
  end;

//-When Setup starts, get the parameters of B1
function PreparePaths() : Boolean;
  var
    position : integer;
    aux : string;
    ResultCode : Integer;
  begin
    //-First Check if the application is installed
    if CheckInstalled then
      begin
        Result := False;
      end
    else
      //-If not yet installed, the 6th parameter has to be character "|" to be a valid call from B1
      if pos('|', paramstr(2)) <> 0 then
        begin
          aux := paramstr(2);
          position := Pos('|', aux)
          AddOnDir := Copy(aux,0, position - 1)
          Result := True;

        end
      else
        begin
          //-The Setup just Runs if Called from B1
          MsgBox('The Setup just can be run from Business One.', mbInformation, MB_OK)

          Result := False;
        end;
  end;

function GetDefaultAddOnDir(Param : string): string;
  begin
    //-Default Directory to Install the Add-On
       result := AddOnDir;
  end;

function InitializeSetup(): Boolean;
  begin
    result := PreparePaths;
  end;

function NextButtonClick(CurPageID: Integer): Boolean;
  var
    ResultCode: Integer;
  begin
    Result := True;
    case CurPageID of
      wpSelectDir :
        begin
          AddOnDir := ExpandConstant('{app}');
          end;
      wpFinished :
        begin
          //-If All OK then
          if FinishedInstall then
            begin
              //-Send to B1 the Installation Folder and ...
              Exec(ExpandConstant('{app}\AddOnInstallAPI.exe'), '-s "' + ExpandConstant('{app}') + '"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
              //-...indicates finish installing
              Exec(ExpandConstant('{app}\AddOnInstallAPI.exe'), '-i', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
            end;
        end;
    end;
  end;

procedure CurStepChanged(CurStep: TSetupStep);
  begin
    if CurStep = ssPostInstall then
      FinishedInstall := True;
    end;

