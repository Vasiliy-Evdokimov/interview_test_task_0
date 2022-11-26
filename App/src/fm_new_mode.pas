unit fm_new_mode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  nauka_types, Vcl.ComCtrls, fm_main;

type
  TfmNewMode = class(TForm)
    lblName: TLabel;
    edName: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    gbProducts: TGroupBox;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDel: TButton;
    lvProducts: TListView;
    btnUp: TButton;
    btnDown: TButton;
    lvSummary: TListView;
    edLossesRatio: TEdit;
    lblLosses: TLabel;
    lblRatioSum_: TLabel;
    lblRatioSum: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure edLossesRatioChange(Sender: TObject);
  private
    RatioSum: integer;
    procedure Add(MP: TModeProduct);
    procedure Edit(MP: TModeProduct);
    procedure Delete(Index: integer);
    procedure OrderMove(Index, Step: integer);
    procedure RefreshProductsList;
    procedure RecountRatio;
    procedure FillGroupRatio(GroupID, Value: integer);
  public
    UM: TUnitMode;
  end;

  TProductGroupRatio = record
    ID: integer;
    Name: string;
    Ratio: integer;
  end;

var
  fmNewMode: TfmNewMode;
  LossRatio: integer;
  RatioSum: integer;
  PGR: array of TProductGroupRatio;

implementation

uses fm_new_mode_product;

{$R *.dfm}

procedure TfmNewMode.Add(MP: TModeProduct);
var i: integer;
begin
  SetLength(UM.Products, length(UM.Products) + 1);
  i := length(UM.Products) - 1;
  UM.Products[i] := MP;
  UM.Products[i].OrderID := i + 1;
end;

procedure TfmNewMode.Edit(MP: TModeProduct);
begin
  //
end;

procedure TfmNewMode.edLossesRatioChange(Sender: TObject);
begin
  RecountRatio();
end;

procedure TfmNewMode.Delete(Index: integer);
var MP: TModeProduct;
    i, Last: integer;
begin
  MP := UM.Products[Index];
  //
  Last := High(UM.Products);
  if Index < Last then
    Move(
      UM.Products[Index + 1],
      UM.Products[Index],
      (Last - Index) * SizeOf(UM.Products[Index])
    );
  SetLength(UM.Products, Last);
end;

procedure TfmNewMode.btnAddClick(Sender: TObject);
begin
  with fmNewModeProduct do
  begin
    MP.ID := 0;
    MP.UnitID := UM.UnitID;
    MP.ModeID := UM.ID;
    MP.ProductID := -1;
    MP.OrderID := 0;
    MP.Ratio := 0;
    if ShowModal = mrOk then
    begin
      Add(MP);
      RefreshProductsList();
    end;
  end;
end;

procedure TfmNewMode.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfmNewMode.btnDelClick(Sender: TObject);
var MP: TModeProduct;
begin
  if lvProducts.Selected = nil then exit;
  //
  MP := UM.Products[lvProducts.Selected.Index];
  if Application.MessageBox(
      PChar('Вы уверены, что хотите удалить продукт "' +
            GetProductGroupByID(MP.ProductID).Name + '" ?'),
      PChar(Application.Title),
      MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;
  Delete(lvProducts.Selected.Index);
  RefreshProductsList();
end;

procedure TfmNewMode.btnDownClick(Sender: TObject);
begin
  if lvProducts.Selected = nil then exit;
  //
  OrderMove(lvProducts.Selected.Index, 1);
  RefreshProductsList();
end;

procedure TfmNewMode.btnEditClick(Sender: TObject);
begin
  if lvProducts.Selected = nil then exit;
  //
  with fmNewModeProduct do
  begin
    MP := UM.Products[lvProducts.Selected.Index];
    if ShowModal = mrOk then
    begin
      UM.Products[lvProducts.Selected.Index] := MP;
      RefreshProductsList();
    end;
  end;
end;

procedure TfmNewMode.btnOkClick(Sender: TObject);
var err: string;
begin
  RecountRatio();
  err := '';
  if trim(edName.Text) = '' then err := err + #10#13 + ' - название режима;';
  if length(UM.Products) = 0 then err := err + #10#13 + ' - список продуктов пуст;';
  if RatioSum <> 100 then err := err + #10#13 + ' - суммарный коэффициент не равен 100%;';
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
  UM.Name := edName.Text;
  UM.LossesRatio := strtoint(edLossesRatio.Text);
  //
  ModalResult := mrOk;
end;

procedure TfmNewMode.btnUpClick(Sender: TObject);
begin
  if lvProducts.Selected = nil then exit;
  //
  OrderMove(lvProducts.Selected.Index, -1);
  RefreshProductsList();
end;

procedure TfmNewMode.FillGroupRatio(GroupID, Value: integer);
var i: integer;
    fl: boolean;
begin
  fl := false;
  for i := 0 to High(PGR) do
    if PGR[i].ID = GroupID then
    begin
      PGR[i].Ratio := PGR[i].Ratio + Value;
      fl := true;
    end;
  if not fl then
  begin
    SetLength(PGR, length(PGR) + 1);
    i := length(PGR) - 1;
    PGR[i].ID := GroupID;
    PGR[i].Name := GetProductGroupByID(GroupID).Name;
    PGR[i].Ratio := Value;
  end;
end;

procedure TfmNewMode.FormShow(Sender: TObject);
begin
  if UM.ID <= 0
    then Caption := 'Новый режим'
    else Caption := 'Редактирование режима';
  edName.Text := UM.Name;
  edLossesRatio.Text := inttostr(UM.LossesRatio);
  RefreshProductsList();
end;

procedure TfmNewMode.OrderMove(Index, Step: integer);
var MP: TModeProduct;
begin
  if ((Index + Step) < 0) or
     ((Index + Step) > length(UM.Products) - 1) then exit;
  //
  MP := UM.Products[Index + Step];
  UM.Products[Index + Step] := UM.Products[Index];
  UM.Products[Index] := MP;
end;

procedure TfmNewMode.RecountRatio;
var i: integer;
begin
  RatioSum := 0;
  SetLength(PGR, 0);
  for i := 0 to High(UM.Products) do
  begin
    RatioSum := RatioSum + UM.Products[i].Ratio;
    FillGroupRatio(
      GetProductByID(UM.Products[i].ProductID).GroupID,
      UM.Products[i].Ratio);
  end;
  if trim(edLossesRatio.Text) = ''
    then LossRatio := 0
    else LossRatio := strtoint(edLossesRatio.Text);
  RatioSum := RatioSum + LossRatio;
  //
  lvSummary.Clear;
  for i := Low(PGR) to High(PGR) do
  begin
    lvSummary.AddItem(PGR[i].Name, nil);
    lvSummary.Items[lvSummary.Items.Count - 1].SubItems.Add(
      inttostr(PGR[i].Ratio));
  end;
  lblRatioSum.Caption := inttostr(RatioSum);
  if RatioSum <> 100
    then lblRatioSum.Font.Color := clRed
    else lblRatioSum.Font.Color := clGreen;
end;

procedure TfmNewMode.RefreshProductsList;
var
  i: integer;
  LI: TListItem;
  s: string;
begin
  lvProducts.Clear;
  for i := Low(UM.Products) to High(UM.Products) do
  begin
    lvProducts.AddItem(inttostr(i + 1), TObject(i));
    LI := lvProducts.Items[lvProducts.Items.Count - 1];
    LI.SubItems.Add(GetProductByID(UM.Products[i].ProductID).Name);
    //s := GetProductGroupByID(GetProductByID(UM.Products[i].ProductID).GroupID).Name;
    //LI.SubItems.Add(s);
    LI.SubItems.Add(inttostr(UM.Products[i].Ratio));
  end;
  RecountRatio();
end;

end.
