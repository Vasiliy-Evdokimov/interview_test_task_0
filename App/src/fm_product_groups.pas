unit fm_product_groups;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  sqlthrd, nauka_types, fm_main;

type
  TfmProductGroups = class(TForm)
    lvGroups: TListView;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
  private
    SelectedID: integer;
    procedure SQL_Add(PG: TProductGroup);
    procedure SQL_Edit(PG: TProductGroup);
    procedure SQL_Delete(ID: integer);
	  procedure SQL_AddResult(Command: TSQLCommand; DS: TSQLDataSet);
    procedure SQL_RefreshProductGroupsListResult(Command: TSQLCommand; DS: TSQLDataSet);
    procedure RefreshListView;
  public
    procedure SQL_RefreshProductGroupsList;
  end;

var
  fmProductGroups: TfmProductGroups;

implementation

uses fm_new_product_group;

{$R *.dfm}

procedure TfmProductGroups.btnAddClick(Sender: TObject);
begin
  with fmNewProductGroup do
  begin
    PG.ID := 0;
    PG.Code := 0;
    PG.Name := '';
    if ShowModal = mrOk then SQL_Add(PG);
  end;
end;

procedure TfmProductGroups.SQL_RefreshProductGroupsList;
var q: string;
begin
  q := 'select * from ProductsGroups';
  sqlth.Add(q, '', ctDataSet, SQL_RefreshProductGroupsListResult);
end;

procedure TfmProductGroups.SQL_RefreshProductGroupsListResult(Command: TSQLCommand; DS: TSQLDataSet);
var i: integer;
begin
  if Command.Successful then
  begin
    SetLength(ProductsGroups, 0);
    while not DS.Eof do
		begin
      SetLength(ProductsGroups, length(ProductsGroups) + 1);
      i := length(ProductsGroups) - 1;
      ProductsGroups[i].ID := DS.FieldByName('ID').AsInteger;
      ProductsGroups[i].Code := DS.FieldByName('Code').AsInteger;
      ProductsGroups[i].Name := trim(DS.FieldByName('Name').AsString);
      //
			DS.Next;
		end;
  end;
  //
  if Visible then RefreshListView();  
end;

procedure TfmProductGroups.RefreshListView;
var
  i: integer;
  LI: TListItem;
begin
  lvGroups.Clear;
  for i := 0 to High(ProductsGroups) do
  begin
    lvGroups.AddItem(inttostr(ProductsGroups[i].ID), TObject(ProductsGroups[i].ID));
    LI := lvGroups.Items[lvGroups.Items.Count - 1];
    LI.SubItems.Add(inttostr(ProductsGroups[i].Code));
    LI.SubItems.Add(ProductsGroups[i].Name);
    if ProductsGroups[i].ID = SelectedID
      then lvGroups.ItemIndex := i;
  end;
end;

procedure TfmProductGroups.btnDelClick(Sender: TObject);
var PG: TProductGroup;
begin
  if lvGroups.Selected = nil then exit;
  //
  PG := GetProductGroupByID(integer(lvGroups.Selected.Data));
  if Application.MessageBox(
      PChar('Вы уверены, что хотите удалить группу "' + PG.Name + '" ?'),
      PChar(Application.Title),
      MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;
  SQL_Delete(PG.ID);
end;

procedure TfmProductGroups.btnEditClick(Sender: TObject);
begin
  if lvGroups.Selected = nil then exit;
  //
  with fmNewProductGroup do
  begin
    PG := GetProductGroupByID(integer(lvGroups.Selected.Data));
    if ShowModal = mrOk then SQL_Edit(PG);
  end;
end;

procedure TfmProductGroups.FormShow(Sender: TObject);
begin
  //SQL_RefreshProductGroupsList();
  RefreshListView();
end;

procedure TfmProductGroups.SQL_Add(PG: TProductGroup);
var q: string;
begin
  q := 'exec ProductGroupAdd ' +
          inttostr(PG.Code) + ', ' +
          QuotedStr(PG.Name);
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmProductGroups.SQL_Edit(PG: TProductGroup);
var q: string;
begin
  q := 'exec ProductGroupEdit ' +
          inttostr(PG.ID) + ', ' +
          inttostr(PG.Code) + ', ' +
          QuotedStr(PG.Name);
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmProductGroups.SQL_Delete(ID: integer);
var q: string;
begin
  q :=
    'delete from ProductsGroups where ID = ' + inttostr(ID) + '; ' +
    'select 0 as ID;';
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmProductGroups.SQL_AddResult(Command: TSQLCommand; DS: TSQLDataSet);
begin
  if Command.Successful then
  begin
    if not DS.Eof then
      SelectedID := DS.FieldByName('ID').AsInteger;
    SQL_RefreshProductGroupsList();
  end;
end;

end.
