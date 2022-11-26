unit fm_new_unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  nauka_types, sqlthrd, fm_main;

type
  TfmNewUnit = class(TForm)
    edMaxVolume: TEdit;
    lblMaxVolume: TLabel;
    gbModes: TGroupBox;
    edCode: TEdit;
    lblCode: TLabel;
    edName: TEdit;
    lblName: TLabel;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDel: TButton;
    lvModes: TListView;
    btnOk: TButton;
    btnCancel: TButton;
    btnUp: TButton;
    btnDown: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
  private
    SelectedIndex: integer;
    procedure Add(UM: TUnitMode);
    procedure Edit(UM: TUnitMode);
    procedure Delete(Index: integer);
    procedure OrderMove(Index, Step: integer);
    procedure RefreshModesList;
  public
    UN: TUnit;
  end;

var
  fmNewUnit: TfmNewUnit;

implementation

uses fm_new_mode;

{$R *.dfm}

procedure TfmNewUnit.Add(UM: TUnitMode);
var i: integer;
begin
  SetLength(UN.Modes, length(UN.Modes) + 1);
  i := length(UN.Modes) - 1;
  UN.Modes[i] := UM;
end;

procedure TfmNewUnit.Delete(Index: integer);
var UM: TUnitMode;
    i, Last: integer;
begin
  UM := UN.Modes[Index];
  //
  Last := High(UN.Modes);
  if Index < Last then
    Move(
      UN.Modes[Index + 1],
      UN.Modes[Index],
      (Last - Index) * SizeOf(UN.Modes[Index])
    );
  SetLength(UN.Modes, Last);
end;

procedure TfmNewUnit.Edit(UM: TUnitMode);
begin
  //
end;

procedure TfmNewUnit.OrderMove(Index, Step: integer);
var UM: TUnitMode;
begin
  if ((Index + Step) < 0) or
     ((Index + Step) > length(UN.Modes) - 1) then exit;
  //
  UM := UN.Modes[Index + Step];
  UN.Modes[Index + Step] := UN.Modes[Index];
  UN.Modes[Index] := UM;
end;

procedure TfmNewUnit.btnAddClick(Sender: TObject);
begin
  with fmNewMode do
  begin
    UM.ID := 0;
    UM. UnitID := UN.ID;
    UM.OrderID := 0;
    UM.Name := '';
    UM.LossesRatio := 0;
    SetLength(UM.Products, 0);
    if ShowModal = mrOk then
    begin
      Add(UM);
      RefreshModesList();
    end;
  end;
end;

procedure TfmNewUnit.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfmNewUnit.btnDelClick(Sender: TObject);
var UM: TUnitMode;
begin
  if lvModes.Selected = nil then exit;
  //
  UM := UN.Modes[lvModes.Selected.Index];
  if Application.MessageBox(
      PChar('Вы уверены, что хотите удалить режим "' + UM.Name + '" ?'),
      PChar(Application.Title),
      MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;
  Delete(lvModes.Selected.Index);
  RefreshModesList();
end;

procedure TfmNewUnit.btnDownClick(Sender: TObject);
begin
  if lvModes.Selected = nil then exit;
  //
  OrderMove(lvModes.Selected.Index, 1);
  RefreshModesList();
end;

procedure TfmNewUnit.btnEditClick(Sender: TObject);
begin
  if lvModes.Selected = nil then exit;
  //
  with fmNewMode do
  begin
    UM := UN.Modes[lvModes.Selected.Index];
    if ShowModal = mrOk then
    begin
      UN.Modes[lvModes.Selected.Index] := UM;
      RefreshModesList();
    end;
  end;
end;

procedure TfmNewUnit.btnOkClick(Sender: TObject);
var err: string;
begin
  if trim(edCode.Text) = '' then edCode.Text := '0';
  if trim(edMaxVolume.Text) = '' then edMaxVolume.Text := '0';
  err := '';
  if trim(edName.Text) = '' then err := err + #10#13 + ' - название установки;';
  if length(UN.Modes) = 0 then err := err + #10#13 + ' - список режимов пуст;';
  if strtoint(edMaxVolume.Text) <= 0 then err := err + #10#13 + ' - не указан макс. объем;';
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
  UN.Name := edName.Text;
  UN.Code := strtoint(edCode.Text);
  UN.MaxVolume := strtoint(edMaxVolume.Text);
  //
  ModalResult := mrOK;
end;

procedure TfmNewUnit.btnUpClick(Sender: TObject);
begin
  if lvModes.Selected = nil then exit;
  //
  OrderMove(lvModes.Selected.Index, -1);
  RefreshModesList();
end;

procedure TfmNewUnit.FormShow(Sender: TObject);
var i: integer;
begin
  if UN.ID <= 0
    then Caption := 'Новая установка'
    else Caption := 'Редактирование установки';
  edCode.Text := inttostr(UN.Code);
  edName.Text := UN.Name;
  edMaxVolume.Text := inttostr(UN.MaxVolume);
  //
  RefreshModesList();
end;

procedure TfmNewUnit.RefreshModesList;
var
  i: integer;
  LI: TListItem;
begin
  lvModes.Clear;
  for i := Low(UN.Modes) to High(UN.Modes) do
  begin
    lvModes.AddItem(UN.Modes[i].Name, TObject(UN.Modes[i].ID));
    LI := lvModes.Items[lvModes.Items.Count - 1];
  end;
end;

end.
