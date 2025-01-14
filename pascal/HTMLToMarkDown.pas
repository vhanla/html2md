unit HTMLToMarkDown;

interface

uses
  System.SysUtils, Winapi.Windows;

const
  DEFAULT_TIMEOUT_SECONDS = 30;
  DEFAULT_CACHE_SIZE_MD   = 100;

type
  TGetConversionSize = function(html: PWideChar): Cardinal; stdcall;
  TGetConversionResult = function(id: Cardinal; buffer: PWideChar; bufferSize: Integer): Integer; stdcall;
  TSetTimeout = procedure(seconds: Cardinal); stdcall;
  TSetMaxCacheSize = procedure(megabytes: Cardinal); stdcall;

// Set the timeout for conversion results (in seconds)
procedure SetConversionTimeout(seconds: Cardinal = DEFAULT_TIMEOUT_SECONDS);
// Set maximum cache size in megabytes
procedure SetMaxCacheSize(megabytes: Cardinal = DEFAULT_CACHE_SIZE_MD);

function GetConversionSize(html: PWideChar): Cardinal; stdcall;
  external 'html2md.dll' name 'GetConversionSize';
function GetConversionResult(id: Cardinal; buffer: PWideChar; bufferSize: Integer): Integer; stdcall;
  external 'html2md.dll' name 'GetConversionResult';
// Convert HTML to Markdown with error handling
function ConvertHTMLToMarkdown(const HTML: string; out ErrorMsg: string): string;

implementation

procedure SetConversionTimeout(seconds: Cardinal = DEFAULT_TIMEOUT_SECONDS);
var
  DLLHandle: THandle;
  SetTimeoutFunc: TSetTimeout;
begin
  DLLHandle := LoadLibrary('html2md.dll');
  if DLLHandle <> 0 then
  try
    @SetTimeoutFunc := GetProcAddress(DLLHandle, 'SetTimeout');
    if Assigned(SetTimeoutFunc) then
      SetTimeoutFunc(seconds)
    else
      raise Exception.Create('Failed to get SetTimeout function');
  finally
    FreeLibrary(DLLHandle);
  end
  else
    raise Exception.Create('Failed to load html2md.DLL');
end;

procedure SetMaxCacheSize(megabytes: Cardinal = DEFAULT_CACHE_SIZE_MD);
var
  DLLHandle: THandle;
  SetMaxCacheSizeFunc: TSetMaxCacheSize;
begin
  DLLHandle := LoadLibrary('html2md.dll');
  if DLLHandle <> 0 then
  try
    @SetMaxCacheSizeFunc := GetProcAddress(DLLHandle, 'SetMaxCacheSize');
    if Assigned(SetMaxCacheSizeFunc) then
      SetMaxCacheSizeFunc(megabytes)
    else
      raise Exception.Create('Failed to get SetMaxCacheSize function');
  finally
    FreeLibrary(DLLHandle);
  end
  else
    raise Exception.Create('Failed to load html2md.DLL');
end;

function ConvertHTMLToMarkdown(const HTML: string; out ErrorMsg: string): string;
var
//  DLLHandle: THandle;
//  GetSize: TGetConversionSize;
//  GetResult: TGetConversionResult;
  SizeInfo: Cardinal;
  BufferSize: Integer;
  ConversionID: Cardinal;
  Buffer: PWideChar;
  ResultLen: Integer;
begin
  Result := '';
  ErrorMsg := '';
//  DLLHandle := LoadLibrary('html2md.dll');
//  if DLLHandle = 0 then
//  begin
//    ErrorMsg := 'Failed to load html2md.DLL';
//    Exit;
//  end;

  try
//    @GetSize := GetProcAddress(DLLHandle, 'GetConversionSize');
//    if not Assigned(GetSize) then
//    begin
//      ErrorMsg := 'Failed to get GetConversionSize function';
//      Exit;
//    end;

//    @GetResult := GetProcAddress(DLLHandle, 'GetConversionResult');
//    if not Assigned(GetResult) then
//    begin
//      ErrorMsg := 'Faile to get GetConversionResult function';
//      Exit;
//    end;

    SizeInfo := GetConversionSize(PChar(HTML));
    if SizeInfo = 0 then
    begin
      ErrorMsg := 'Conversion failed or cache full';
      Exit;
    end;

    BufferSize := SizeInfo and $FFFF;
    ConversionID := SizeInfo and $FFFF0000;

    //Buffer := AllocMem((BufferSize +1) * SizeOf(WideChar));
    GetMem(Buffer, (BufferSize +1) * SizeOf(WideChar));
    try
      ResultLen := GetConversionResult(ConversionID, Buffer, BufferSize + 1);
      case ResultLen of
        -1: ErrorMsg := 'Conversion result expired or invalid';
        -2: ErrorMsg := 'Buffer too small';
        else
        begin
          SetString(Result, Buffer, ResultLen);
          Result := StringReplace(Result, #10, #13#10, [rfReplaceAll]);
        end;
      end;
    finally
      FreeMem(Buffer);
    end;
  finally
//    FreeLibrary(DLLHandle);
  end;

end;

//initialization
//  SetConversionTimeOut(2000); // 2 seconds
//  SetMaxCacheSize(100); // default 100 MB

end.
