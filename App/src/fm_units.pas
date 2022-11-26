unit fm_units;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  nauka_types, sqlthrd, fm_main;

type
  TfmUnits = class(TForm)
    lvUnits: TListView;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDel: TButton;
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
  private
    SelectedID: integer;
    procedure SQL_Add(UN: TUnit);
    procedure SQL_Edit(UN: TUnit);
    procedure SQL_Delete(ID: integer);
	  procedure SQL_AddResult(Command: TSQLCommand; DS: TSQLDataSet);
    procedure SQL_RefreshUnitsListResult(Command: TSQLCommand; DS: TSQLDataSet);
    procedure RefreshListView;
  public
    procedure SQL_RefreshUnitsList;
  end;

var
  fmUnits: TfmUnits;

implementation

uses fm_new_unit;

{$R *.dfm}

procedure TfmUnits.btnAddClick(Sender: TObject);
begin
  with fmNewUnit do
  begin
    UN.ID := 0;
    UN.Code := 0;
    UN.Name := '';
    UN.MaxVolume := 0;
    SetLength(UN.Modes, 0);
    if ShowModal = mrOk
      then SQL_Add(UN);
  end;
end;

procedure TfmUnits.btnDelClick(Sender: TObject);
var UN: PUnit;
begin
  if lvUnits.Selected = nil then exit;
  //
  UN := GetUnitByID(integer(lvUnits.Selected.Data));
  if Application.MessageBox(
      PChar('¬ы уверены, что хотите удалить установку "' + UN.Name + '" ?'),
      PChar(Application.Title),
      MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;
  SQL_Delete(UN.ID);
end;

procedure TfmUnits.btnEditClick(Sender: TObject);
begin
  if lvUnits.Selected = nil then exit;
  //
  with fmNewUnit do
  begin
    UN := Units[lvUnits.Selected.Index];
    if ShowModal = mrOk then
    begin
      Units[lvUnits.Selected.Index] := UN;
      SQL_Edit(UN);
    end;
  end;
end;

procedure TfmUnits.FormShow(Sender: TObject);
begin
  //SQL_RefreshUnitsList();
  RefreshListView();
end;

procedure TfmUnits.SQL_Add(UN: TUnit);
var q: string;
begin
  q := 'exec UnitAdd ' +
          inttostr(UN.Code) + ', ' +
          QuotedStr(UN.Name) + ', ' +
          inttostr(UN.MaxVolume) + ', ' +
          MakeUnitXML(UN) + ';';
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmUnits.SQL_AddResult(Command: TSQLCommand; DS: TSQLDataSet);
begin
  if Command.Successful then
  begin
    if not DS.Eof then
      SelectedID := DS.FieldByName('ID').AsInteger;
    SQL_RefreshUnitsList();
  end;
end;

procedure TfmUnits.SQL_Delete(ID: integer);
var q: string;
begin
  q := 'exec UnitDelete ' + inttostr(ID) + ';';
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmUnits.SQL_Edit(UN: TUnit);
var q: string;
begin
  q := 'exec UnitEdit ' +
          inttostr(UN.ID) + ', ' +
          inttostr(UN.Code) + ', ' +
          QuotedStr(UN.Name) + ', ' +
          inttostr(UN.MaxVolume) + ', ' +
          MakeUnitXML(UN) + ';';
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmUnits.SQL_RefreshUnitsList;
var q: string;
begin
  q :=
    'select * from Units; ' +
	  'select * from UnitModes order by UnitID, OrderID; ' +
	  'select * from ModeProducts order by ModeID, OrderID;';
  sqlth.Add(q, '', ctDataSet, SQL_RefreshUnitsListResult);
end;

procedure TfmUnits.SQL_RefreshUnitsListResult(Command: TSQLCommand; DS: TSQLDataSet);
var
  i, uid, mid, am: integer;
  UN: PUnit;
  UM: PUnitMode;
begin
  if Command.Successful then
  begin
    SetLength(Units, 0);
    while not DS.Eof do
		begin
      SetLength(Units, length(Units) + 1);
      i := length(Units) - 1;
      Units[i].ID := DS.FieldByName('ID').AsInteger;
      Units[i].Code := DS.FieldByName('Code').AsInteger;
      Units[i].Name := trim(DS.FieldByName('Name').AsString);
      Units[i].MaxVolume := DS.FieldByName('MaxVolume').AsInteger;
      SetLength(Units[i].Modes, 0);
      //
			DS.Next;
		end;
    //
    DS.Recordset := DS.NextRecordset(am);
		while not DS.Eof do
		begin
      uid := DS.FieldByName('UnitID').AsInteger;
      //
      UN := GetUnitByID(uid);
      SetLength(UN.Modes, length(UN.Modes) + 1);
      i := length(UN.Modes) - 1;
      UN.Modes[i].ID := DS.FieldByName('ID').AsInteger;
      UN.Modes[i].UnitID := uid;
      UN.Modes[i].OrderID := DS.FieldByName('OrderID').AsInteger;
      UN.Modes[i].Name := DS.FieldByName('Name').AsString;
      UN.Modes[i].LossesRatio := DS.FieldByName('LossesRatio').AsInteger;
      SetLength(UN.Modes[i].Products, 0);
      //
      DS.Next;
    end;
    //
    DS.Recordset := DS.NextRecordset(am);
		while not DS.Eof do
		begin
      uid := DS.FieldByName('UnitID').AsInteger;
      mid := DS.FieldByName('ModeID').AsInteger;
      //
      UM := GetUnitModeByID(uid, mid);
      SetLength(UM.Products, length(UM.Products) + 1);
      i := length(UM.Products) - 1;
      UM.Products[i].ID := DS.FieldByName('ID').AsInteger;
      UM.Products[i].UnitID := uid;
      UM.Products[i].ModeID := mid;
      UM.Products[i].ProductID := DS.FieldByName('ProductID').AsInteger;
      UM.Products[i].OrderID := DS.FieldByName('OrderID').AsInteger;
      UM.Products[i].Ratio :=  DS.FieldByName('Ratio').AsInteger;
      //
      DS.Next;
    end;
  end;
  //
  if Visible then RefreshListView();
  //
  fmMain.RefreshProdUnitAddList();
  //
  CurProd.Update();
end;

procedure TfmUnits.RefreshListView;
var
  i: integer;
  LI: TListItem;
begin
  lvUnits.Clear;
  for i := 0 to High(Units) do
  begin
    lvUnits.AddItem(inttostr(Units[i].ID), TObject(Units[i].ID));
    LI := lvUnits.Items[lvUnits.Items.Count - 1];
    LI.SubItems.Add(inttostr(Units[i].Code));
    LI.SubItems.Add(Units[i].Name);
    LI.SubItems.Add(inttostr(Units[i].MaxVolume));
    if Units[i].ID = SelectedID
      then lvUnits.ItemIndex := i;
  end;
end;


end.
