unit fm_products;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  nauka_types, sqlthrd, fm_main;

type
  TfmProducts = class(TForm)
    lvProducts: TListView;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
  private
    SelectedID: integer;
    procedure SQL_Add(PR: TProduct);
    procedure SQL_Edit(PR: TProduct);
    procedure SQL_Delete(ID: integer);
	  procedure SQL_AddResult(Command: TSQLCommand; DS: TSQLDataSet);
    procedure SQL_RefreshProductsListResult(Command: TSQLCommand; DS: TSQLDataSet);
    procedure RefreshListView;
  public
    procedure SQL_RefreshProductsList;
  end;

var
  fmProducts: TfmProducts;

implementation

uses fm_new_product;

{$R *.dfm}

procedure TfmProducts.btnAddClick(Sender: TObject);
begin
  with fmNewProduct do
  begin
    PR.ID := 0;
    PR.Code := 0;
    PR.Name := '';
    PR.GroupID := -1;
    if ShowModal = mrOk then SQL_Add(PR);
  end;
end;

procedure TfmProducts.SQL_RefreshProductsList;
var q: string;
begin
  q := 'select * from Products';
  sqlth.Add(q, '', ctDataSet, SQL_RefreshProductsListResult);
end;

procedure TfmProducts.SQL_RefreshProductsListResult(Command: TSQLCommand; DS: TSQLDataSet);
var i: integer;
begin
  if Command.Successful then
  begin
    SetLength(Products, 0);
    while not DS.Eof do
		begin
      SetLength(Products, length(Products) + 1);
      i := length(Products) - 1;
      Products[i].ID := DS.FieldByName('ID').AsInteger;
      Products[i].Code := DS.FieldByName('Code').AsInteger;
      Products[i].Name := trim(DS.FieldByName('Name').AsString);
      Products[i].GroupID := DS.FieldByName('GroupID').AsInteger;
      //
			DS.Next;
		end;
  end;
  //
  if Visible then RefreshListView();  
end;

procedure TfmProducts.RefreshListView;
var
  i: integer;
  LI: TListItem;
  PG: TProductGroup;
  s: string;
begin
  lvProducts.Clear;
  for i := 0 to High(Products) do
  begin  
    lvProducts.AddItem(inttostr(Products[i].ID), TObject(Products[i].ID));
    LI := lvProducts.Items[lvProducts.Items.Count - 1];
    LI.SubItems.Add(inttostr(Products[i].Code));
    LI.SubItems.Add(Products[i].Name);
    PG := GetProductGroupByID(Products[i].GroupID);
    if PG.ID = 0
      then s := '???'
      else s := PG.Name;
    LI.SubItems.Add(s);
    if Products[i].ID = SelectedID
      then lvProducts.ItemIndex := i;
  end;
end;


procedure TfmProducts.btnDelClick(Sender: TObject);
var PR: TProduct;
begin
  if lvProducts.Selected = nil then exit;
  //
  PR := GetProductByID(integer(lvProducts.Selected.Data));
  if Application.MessageBox(
      PChar('¬ы уверены, что хотите удалить продукт "' + PR.Name + '" ?'),
      PChar(Application.Title),
      MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;
  SQL_Delete(PR.ID);
end;

procedure TfmProducts.btnEditClick(Sender: TObject);
begin
  if lvProducts.Selected = nil then exit;
  //
  with fmNewProduct do
  begin
    PR := GetProductByID(integer(lvProducts.Selected.Data));
    if ShowModal = mrOk then SQL_Edit(PR);
  end;
end;

procedure TfmProducts.FormShow(Sender: TObject);
begin
  //SQL_RefreshProductsList();
  RefreshListView();
end;

procedure TfmProducts.SQL_Add(PR: TProduct);
var q: string;
begin
  q := 'exec ProductAdd ' +
          inttostr(PR.Code) + ', ' +
          QuotedStr(PR.Name) + ', ' +
          inttostr(PR.GroupID);
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmProducts.SQL_Edit(PR: TProduct);
var q: string;
begin
  q := 'exec ProductEdit ' +
          inttostr(PR.ID) + ', ' +
          inttostr(PR.Code) + ', ' +
          QuotedStr(PR.Name) + ', ' +
          inttostr(PR.GroupID);
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmProducts.SQL_Delete(ID: integer);
var q: string;
begin
  q :=
    'delete from Products where ID = ' + inttostr(ID) + '; ' +
    'select 0 as ID;';
  sqlth.Add(q, '', ctDataSet, SQL_AddResult);
end;

procedure TfmProducts.SQL_AddResult(Command: TSQLCommand; DS: TSQLDataSet);
begin
  if Command.Successful then
  begin
    if not DS.Eof then
      SelectedID := DS.FieldByName('ID').AsInteger;
    SQL_RefreshProductsList();
  end;
end;

end.
