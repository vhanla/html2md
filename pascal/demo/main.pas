unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HTMLToMarkDown, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Clipbrd;

type
  TMemo = class(Vcl.StdCtrls.TMemo)
  private
    function GetClipboardHTMLContent: string;
  protected
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
  end;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    btnConvert: TButton;
    Memo2: TMemo;
    Splitter1: TSplitter;
    procedure btnConvertClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  CF_HTML: WORD;

implementation

{$R *.dfm}

procedure TForm1.btnConvertClick(Sender: TObject);
var
  errorMsg: string;
  mdResult: string;
begin
  try
    mdResult := ConvertHTMLToMarkdown(Memo1.Text, errorMsg);
    if not mdResult.IsEmpty then
      Memo2.Text := mdResult
    else
      Memo2.Text := errorMsg;
  except
  end;
end;


{ TMemo }

function TMemo.GetClipboardHTMLContent: string;
var
  CF_HTML, CF_TEXT_HTML: Word;
  Data: THandle;
  Ptr: Pointer;
  Size: NativeUInt;
  HtmlData: string;
  Utf8: UTF8String;
  StartFragment, EndFragment: Integer;
  StartFragmentTag, EndFragmentTag: string;
begin
  Result := '';

  // Register Clipboard Formats
  CF_HTML := RegisterClipboardFormat('HTML Format');
  CF_TEXT_HTML := RegisterClipboardFormat('text/html');

  Clipboard.Open;
  try
    // Check for 'text/html' first (preferred, e.g., from Firefox)
    Data := Clipboard.GetAsHandle(CF_TEXT_HTML);
    if Data = 0 then
    begin
      // Fallback to 'HTML Format' (for Chromium browsers)
      Data := Clipboard.GetAsHandle(CF_HTML);
      if Data = 0 then
        Exit; // Neither format is available
    end;

    // Lock and extract data
    Ptr := GlobalLock(Data);
    try
      if Assigned(Ptr) then
      begin
        Size := GlobalSize(Data);
        if Size > 0 then
        begin
          // If we are using 'HTML Format' (Chromium-like), extract UTF-8 content
          if Data = Clipboard.GetAsHandle(CF_HTML) then
          begin
            SetString(Utf8, PAnsiChar(Ptr), Size - 1); // Extract UTF-8 content
            HtmlData := String(Utf8); // Convert to Delphi string
            StartFragmentTag := 'StartFragment:';
            EndFragmentTag := 'EndFragment:';

            // Look for StartFragment and EndFragment in the HTML data
            StartFragment := StrToIntDef(Copy(HtmlData, Pos(StartFragmentTag, HtmlData) + Length(StartFragmentTag), 10), -1);
            EndFragment := StrToIntDef(Copy(HtmlData, Pos(EndFragmentTag, HtmlData) + Length(EndFragmentTag), 10), -1);

            // Ensure valid fragment range and extract it
            if (StartFragment >= 0) and (EndFragment > StartFragment) then
              Result := Copy(HtmlData, StartFragment + 1, EndFragment - StartFragment)
            else
              Result := ''; // Return empty string if invalid markers
          end
          else
          begin
            // For 'text/html' format (e.g., Firefox), use it directly
            HtmlData := PChar(Ptr); // Directly assign for Firefox data (which is already a valid Delphi string)
            Result := HtmlData; // No need for extra processing
          end;
        end;
      end;
    finally
      GlobalUnlock(Data);
    end;
  finally
    Clipboard.Close;
  end;
end;


procedure TMemo.WMPaste(var Message: TWMPaste);
var
  HtmlContent: string;
begin
  HtmlContent := GetClipboardHTMLContent;

  if HtmlContent <> '' then
  begin
    Self.Text := HtmlContent;
  end
  else
    inherited;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//  CF_HTML := RegisterClipboardFormat('HTML Format');
end;

end.
