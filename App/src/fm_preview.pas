unit fm_preview;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, fm_main, Vcl.OleCtrls, SHDocVw,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfmPreview = class(TForm)
    pnButtons: TPanel;
    btnPrint: TBitBtn;
    wbPreview: TWebBrowser;
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPreview: TfmPreview;

implementation

{$R *.dfm}

procedure TfmPreview.btnPrintClick(Sender: TObject);
begin
  wbPreview.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_PROMPTUSER);
end;

end.
