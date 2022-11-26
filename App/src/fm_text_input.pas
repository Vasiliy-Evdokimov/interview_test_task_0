unit fm_text_input;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfmTextInput = class(TForm)
    lblCaption: TLabel;
    edText: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmTextInput: TfmTextInput;

implementation

{$R *.dfm}

procedure TfmTextInput.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfmTextInput.btnOkClick(Sender: TObject);
begin
  if trim(edText.Text) = '' then exit;
  //
  ModalResult := mrOk;
end;

end.
