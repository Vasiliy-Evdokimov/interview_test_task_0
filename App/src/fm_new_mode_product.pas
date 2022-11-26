unit fm_new_mode_product;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, nauka_types;

type
  TfmNewModeProduct = class(TForm)
    lblRatio: TLabel;
    edRatio: TEdit;
    Label1: TLabel;
    cbProducts: TComboBox;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    MP: TModeProduct;
  end;

var
  fmNewModeProduct: TfmNewModeProduct;

implementation

{$R *.dfm}

procedure TfmNewModeProduct.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfmNewModeProduct.btnOkClick(Sender: TObject);
var err: string;
begin
  err := '';
  if trim(edRatio.Text) = '' then edRatio.Text := '0';
  if cbProducts.ItemIndex < 0 then err := err + #10#13 + ' - продукт;';
  if strtoint(edRatio.Text) <= 0 then err := err + #10#13 + ' - коэфф. выработки;';
  if err <> '' then
  begin
    err := 'Обнаружены следующие ошибки:' + copy(err, 1, length(err) - 1) + '.';
    Application.MessageBox(
      PChar(err),
      PChar(Application.Title),
      MB_OK + MB_ICONINFORMATION);
    exit;
  end;
  //
  MP.ProductID:= integer(cbProducts.Items.Objects[cbProducts.ItemIndex]);
  MP.Ratio := strtoint(edRatio.Text);
  //
  ModalResult := mrOk;
end;

procedure TfmNewModeProduct.FormShow(Sender: TObject);
var
  i: integer;
  s: string;
begin
  if MP.ProductID <= 0
    then Caption := 'Новый продукт'
    else Caption := 'Редактирование продукта';
  edRatio.Text := inttostr(MP.Ratio);
  //
  cbProducts.Clear;
  for i := Low(Products) to High(Products) do
  begin
    s := Products[i].Name + ' (' + GetProductGroupByID(Products[i].GroupID).Name + ')';
    cbProducts.AddItem(s, TObject(Products[i].ID));
    if Products[i].ID = MP.ProductID
      then cbProducts.ItemIndex := i;
  end;
end;

end.
