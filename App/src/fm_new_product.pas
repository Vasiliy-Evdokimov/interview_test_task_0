unit fm_new_product;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, nauka_types;

type
  TfmNewProduct = class(TForm)
    lblCode: TLabel;
    edCode: TEdit;
    lblName: TLabel;
    edName: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    lblGroup: TLabel;
    cbGroups: TComboBox;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    PR: TProduct;
  end;

var
  fmNewProduct: TfmNewProduct;

implementation

{$R *.dfm}

procedure TfmNewProduct.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfmNewProduct.btnOkClick(Sender: TObject);
var err: string;
begin
  err := '';
  if trim(edCode.Text) = '' then edCode.Text := '0';
  if trim(edName.Text) = '' then err := err + #10#13 + ' - название продукта;';
  if cbGroups.ItemIndex < 0 then err := err + #10#13 + ' - группа продуктов;';
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
  PR.Code := strtoint(edCode.Text);
  PR.Name := edName.Text;
  PR.GroupID := integer(cbGroups.Items.Objects[cbGroups.ItemIndex]);
  //
  ModalResult := mrOk;
end;

procedure TfmNewProduct.FormShow(Sender: TObject);
var i: integer;
begin
  if PR.ID <= 0
    then Caption := 'Новый продукт'
    else Caption := 'Редактирование продукта';
  edCode.Text := inttostr(PR.Code);
  edName.Text := PR.Name;
  //
  cbGroups.Clear;
  for i := Low(ProductsGroups) to High(ProductsGroups) do
  begin
    cbGroups.AddItem(ProductsGroups[i].Name, TObject(ProductsGroups[i].ID));
    if ProductsGroups[i].ID = PR.GroupID
      then cbGroups.ItemIndex := i;
  end;
end;

end.
