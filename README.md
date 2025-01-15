# html2md

This project provides a DLL for converting HTML to Markdown, along with a Pascal wrapper and demo application.

## Features

- Converts HTML to Markdown
- Supports Pascal integration via DLL
- Includes a demo application showcasing usage

## Third-Party Libraries

- **[github.com/JohannesKaufmann/html-to-markdown](https://www.google.com/url?sa=E&source=gmail&q=https://github.com/JohannesKaufmann/html-to-markdown)** \- Core Markdown conversion library.

## Usage

### Pascal

1. Include the `HTMLToMarkDown` unit in your Pascal project.
2. Call the `ConvertHTMLToMarkdown` function to convert HTML to Markdown.
3. Make sure to include the `html2md.dll` next to your executable or in a visible global PATH.


Delphi

```pascal
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

```

### Demo Application (html2mdapp)

The included demo application ( `html2mdapp`) is a simple Pascal program that demonstrates how to use the DLL to convert HTML from the clipboard to Markdown.

To use the demo application:

1. Copy HTML content to the clipboard.
2. Paste the HTML content into the left-hand memo box of the application.
3. Click the "Convert" button.
4. The Markdown version of the HTML will appear in the right-hand memo box.

## Building

### Building the DLL in Windows

1. Ensure Go is installed. Download it from the official Go website if necessary.
2. Open a command prompt and navigate to the directory containing the `html2md.dll` files.
3. Run `build.cmd` to create the DLL file.
4. For a smaller DLL file, run `build-stripped.cmd` to create a stripped version.

### Building the Pascal Demo App

1. Ensure a Pascal compiler like Delphi or Lazarus is installed.
2. Open the `main.pas` file in the Pascal IDE.
3. Compile and run the project to open the demo application.

## Additional Notes

- The DLL uses a cache to store conversion results. The default timeout for cached results is 30 seconds, this is for failed conversion as the GO garbage collector releases the buffer.
- The cache size can be adjusted.
- The demo application demonstrates how to paste HTML from the clipboard and convert it to Markdown.

## Contributing

Contributions are welcome! Please submit pull requests or issues for any bugs or feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
