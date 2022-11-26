unit fm_new_product_group;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, nauka_types;

type
  TfmNewProductGroup = class(TForm)
    lblCode: TLabel;
    edCode: TEdit;
    lblName: TLabel;
    edName: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    PG: TProductGroup;
  end;

var
  fmNewProductGroup: TfmNewProductGroup;

implementation

{$R *.dfm}

procedure TfmNewProductGroup.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfmNewProductGroup.btnOkClick(Sender: TObject);
begin
  if trim(edCode.Text) = '' then edCode.Text := '0';
  if trim(edName.Text) = '' then
  begin
    Application.MessageBox(
      PChar('Не указано название группы!'),
      PChar(Application.Title),
      MB_OK + MB_ICONINFORMATION);
    exit;
  end;
  //
  PG.Code := strtoint(edCode.Text);
  PG.Name := edName.Text;
  //
  ModalResult := mrOk;
end;

procedure TfmNewProductGroup.FormShow(Sender: TObject);
begin
  if PG.ID <= 0
    then Caption := 'Новая группа'
    else Caption := 'Редактирование группы';
  edCode.Text := inttostr(PG.Code);
  edName.Text := PG.Name;
end;

end.
