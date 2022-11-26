unit nauka_types;

interface

uses
  System.SysUtils, Vcl.StdCtrls, Vcl.ExtCtrls, System.Classes,
  Winapi.Windows, Vcl.Graphics, Vcl.Samples.Spin, Vcl.Controls,
  Generics.Collections, sqlthrd;

const
  UNIT_CMPNT_Y_START = 20;
  UNIT_CMPNT_Y_OFFSET = 80;
  UNIT_CMPNT_BTN_DEL_X = 10;
  UNIT_CMPNT_BTN_SAVE_X = 50;
  UNIT_CMPNT_LBL_X = 100;
  UNIT_CMPNT_CB_X = 190;
  UNIT_CMPNT_CB_WIDTH = 100;

  UNIT_CMPNT_PN_X = 300;
  UNIT_CMPNT_PN_HEIGHT = 40;
  UNIT_CMPNT_PN_SCALE = 4;
  UNIT_CMPNT_SP_WIDTH = 3;

  UNIT_CMPNT_SPIN_WIDTH = 40;
  UNIT_CMPNT_SPIN_OFFSET = 140;

  COLOR_ARRAY: array [0..9] of TColor =
    (clMaroon, clOlive, clGreen, clPurple, clTeal,
     clNavy, clAqua, clLime, clFuchsia, clBlue);

  IERegistryPath =
    '\Software\Microsoft\Internet Explorer\Main' +
    '\FeatureControl\FEATURE_BROWSER_EMULATION\';
  IEVersion = 11001;

type
  TConfig = record
    Database: TSQLConnectionParams;
  end;

  TProductGroup = record
    ID: integer;
    Code: integer;
    Name: string;
  end;
  TProductGroups = array of TProductGroup;

  TProduct = record
    ID: integer;
    Code: integer;
    Name: string;
    GroupID: integer;
  end;
  TProducts = array of TProduct;

  TModeProduct = record
    ID: integer;
    UnitID: integer;
    ModeID: integer;
    ProductID: integer;
    OrderID: byte;
    Ratio: integer;
    //
    procedure Assign(Source: TModeProduct);
  end;
  PModeProduct = ^TModeProduct;
  TModeProducts = array of TModeProduct;

  TUnitMode = record
    ID: integer;
    UnitID: integer;
    OrderID: integer;
    Name: string;
    LossesRatio: integer;
    Products: TModeProducts;
  end;
  PUnitMode = ^TUnitMode;
  TUnitModes = array of TUnitMode;

  TUnit = record
    ID: integer;
    Code: integer;
    Name: string;
    MaxVolume: integer;
    Modes: TUnitModes;
    Enabled: boolean;
  end;
  PUnit = ^TUnit;
  TUnits = array of TUnit;

  TProductCalc = record
    ProductID: integer;
    Volume: double;
  end;
  TProductCalcs = array of TProductCalc;

  TGroupCalc = record
    GroupID: integer;
    Volume: double;
    Percent: double;
  end;
  TGroupCalcs = array of TGroupCalc;

  TUnitCalc = record
    Volume: double;
    Percent: double;
    ProductCalcs: TProductCalcs;
    GroupCalcs: TGroupCalcs;
    //
    ProductsSumVol: double;
    ProductsSumPrc: double;
    GroupsSumVol: double;
    GroupsSumPrc: double;
    //
    LossesVol: double;
  end;

  TProductComponent = record
    ProductID: integer;
    Left, Width: integer;
  end;
  TProductComponents = array of TProductComponent;

  TProductSplitter = record
    ProductID1: integer;
    ProductID2: integer;
    Left, Width: integer;
  end;
  TProductSplitters = array of TProductSplitter;

  TProductSpin = record
    Index1: integer;
    ProductID1: integer;
    Index2: integer;
    ProductID2: integer;
    MIndex: integer;
    BorderUpper, BorderLower: integer;
    SE: TSpinEdit;
    LB1: TLabel;
    LB2: TLabel;
  end;
  TProductSpins = array of TProductSpin;

  TUnitComponent = record
    LBL: TLabel;
    CB: TComboBox;
    BTN_DEL: TButton;
    BTN_SAVE: TButton;
    bmp: TBitmap;
    ModePB: TPaintBox;
    ProductComps: TProductComponents;
    ProductSplits: TProductSplitters;
    ProductSpins: TProductSpins;
    LossSE: TSpinEdit;
    LossLB: TLabel;
  end;
  TUnitComponents = array of TUnitComponent;

  TProductionUnit = class(TObject)
    ID: integer;
    Index: integer;
    ProductionID: integer;
    UnitID: integer;
    UnitP: PUnit;
    ModeID: integer;
    ModeP: PUnitMode;
    //
    Products: TModeProducts;
    Calc: TUnitCalc;
    Components: TUnitComponent;
    //
    procedure SetProductionMode(pModeID: integer);
    procedure InitProductionModeCalc;
    procedure DrawModeProducts;
    //
    procedure CreateModeComponents1;
    procedure CreateModeComponents2;
    procedure DestroyModeComponents;
    procedure ActualizeSpinEdits;
    //
    procedure CreateComponents;
    procedure MoveComponents;
    procedure DestroyComponents;
    //
    procedure Calculate;
    procedure Update;
    //
    constructor Create(pProductionID, pUnitID, pIndex: integer);
    destructor Destroy;
  end;
  PProductionUnit = ^TProductionUnit;
  TProductionUnits = array of TProductionUnit;

  TProduction = class(TObject)
    ID: integer;
    Name: string;
    TotalVolume: integer;
    UnitMaxVolumesSum: integer;
    Units: TList<TProductionUnit>;
    //
    procedure AddProductionUnit(UnitID: integer);
    procedure DeleteProductionUnit(UnitIndex: integer);
    procedure Update;
    procedure Calculate;
    //
    constructor Create;
    destructor Destroy;
  end;
  PProduction = ^TProduction;
  TProductions = array of TProduction;

  TReportString = record
    StyleID: integer;
    Text: string;
  end;
  TReport = record
    Text: array of TReportString;
    procedure Add(pStyleID: integer; pText: string);
    procedure Clear;
  end;

  function GetProductGroupByID(ID: integer): TProductGroup;
  function GetProductByID(ID: integer): TProduct;
  function GetUnitByID(ID: integer): PUnit;
  function GetUnitModeByID(UnitID, ID: integer): PUnitMode;
  function GetModeProductByID(UnitID, ModeID, ID: integer): PModeProduct;

  function MakeUnitXML(UN: TUnit): string;
  function MakeModeProductXML(Mode: TUnitMode; Products: TModeProducts): string;

  function GetSplitterIndexByXY(UC: TUnitComponent; X, Y: integer): integer;
  function GetColorByIndex(Index: integer): TColor;

  procedure ModeProductsAssign(const SRC: TModeProducts; var DST: TModeProducts);

var
  cnfg: TConfig;
  sqlth: TSQLThread;
  ProductsGroups: TProductGroups;
  Products: TProducts;
  Units: TUnits;
  CurProd: TProduction;
  UnitComps: TUnitComponents;

implementation

uses fm_main;

procedure ModeProductsAssign(const SRC: TModeProducts; var DST: TModeProducts);
var i: integer;
begin
  if length(DST) <> length(SRC) then SetLength(DST, length(SRC));
  for i := 0 to length(DST) - 1 do
    DST[i].Assign(SRC[i]);
end;

function GetColorByIndex(Index: integer): TColor;
var i: integer;
begin
  i := Index mod length(COLOR_ARRAY);
  Result := COLOR_ARRAY[i];
end;

function GetSplitterIndexByXY(UC: TUnitComponent; X, Y: integer): integer;
var
  i: integer;
  PS: TProductSplitter;
begin
  Result := -1;
  for i := 0 to length(UC.ProductSplits) - 1 do
  begin
    PS := UC.ProductSplits[i];
    if (X >= PS.Left) and
       (X <= PS.Left + PS.Width) and
       (Y >= 0) and
       (Y <= UC.ModePB.Height)
     then
     begin
       Result := i;
       break;
     end;
  end;
end;

function MakeUnitXML(UN: TUnit): string;
var
  i, j: integer;
  xmlModes, xmlProducts: string;
begin
  xmlModes := '<Modes>';
  xmlProducts := '<Products>';
  for i := 0 to High(UN.Modes) do
  begin
    xmlModes := xmlModes +
      '<Item ' +
        'ID="' + IntToStr(UN.Modes[i].ID) + '" ' +
        'UnitID="' + IntToStr(UN.Modes[i].UnitID) + '" ' +
        'OrderID="' + IntToStr(i + 1) + '" ' +
        'Name="' + UN.Modes[i].Name + '" ' +
        'LossesRatio="' + IntToStr(UN.Modes[i].LossesRatio) + '" ' +
        '/>';
    for j := 0 to High(UN.Modes[i].Products) do
      xmlProducts := xmlProducts +
        '<Item ' +
          'ID="' + IntToStr(UN.Modes[i].Products[j].ID) + '" ' +
          'UnitID="' + IntToStr(UN.Modes[i].UnitID) + '" ' +
          'ModeID="' + IntToStr(i + 1) + '" ' +
          'OrderID="' + IntToStr(j + 1) + '" ' +
          'ProductID="' + IntToStr(UN.Modes[i].Products[j].ProductID) + '" ' +
          'Ratio="' + IntToStr(UN.Modes[i].Products[j].Ratio) + '" ' +
          '/>';
  end;
  xmlProducts := xmlProducts + '</Products>';
  xmlModes := xmlModes + '</Modes>';
  //
  Result := QuotedStr(xmlModes) + ', ' + QuotedStr(xmlProducts);
end;

function MakeModeProductXML(Mode: TUnitMode; Products: TModeProducts): string;
var
  i: integer;
  xmlProducts: string;
begin
  xmlProducts := '<Products>';
  for i := 0 to High(Products) do
    xmlProducts := xmlProducts +
      '<Item ' +
        'ID="' + IntToStr(Products[i].ID) + '" ' +
        'UnitID="' + IntToStr(Mode.UnitID) + '" ' +
        'ModeID="' + IntToStr(Mode.ID) + '" ' +
        'OrderID="' + IntToStr(i + 1) + '" ' +
        'ProductID="' + IntToStr(Products[i].ProductID) + '" ' +
        'Ratio="' + IntToStr(Products[i].Ratio) + '" ' +
        '/>';
  xmlProducts := xmlProducts + '</Products>';
  Result := xmlProducts;
end;

function GetUnitByID(ID: integer): PUnit;
var i: integer;
begin
  for i := Low(Units) to High(Units) do
    if Units[i].ID = ID then
    begin
      Result := @Units[i];
      break;
    end;
end;

function GetUnitModeByID(UnitID, ID: integer): PUnitMode;
var
  i: integer;
  UN: PUnit;
begin
  UN := GetUnitByID(UnitID);
  if UN.ID > 0 then
    for i := Low(UN.Modes) to High(UN.Modes) do
      if UN^.Modes[i].ID = ID then
      begin
        Result := @UN.Modes[i];
        break;
      end;
end;

function GetModeProductByID(UnitID, ModeID, ID: integer): PModeProduct;
var
  i: integer;
  UN: PUnit;
  UM: PUnitMode;
begin
  UM := GetUnitModeByID(UnitID, ModeID);
  if UM.ID > 0 then
    for i := Low(UM.Products) to High(UM.Products) do
      if UM.Products[i].ID = ID then
      begin
        Result := @UM.Products[i];
        break;
      end;
end;

function GetProductGroupByID(ID: integer): TProductGroup;
var i: integer;
begin
  Result.ID := 0;
  for i := Low(ProductsGroups) to High(ProductsGroups) do
    if ProductsGroups[i].ID = ID then
    begin
      Result := ProductsGroups[i];
      break;
    end;
end;

function GetProductByID(ID: integer): TProduct;
var i: integer;
begin
  Result.ID := 0;
  for i := Low(Products) to High(Products) do
    if Products[i].ID = ID then
    begin
      Result := Products[i];
      break;
    end;
end;

{ TProductionUnit }

procedure TProductionUnit.Calculate;
var i, j, id: integer;
begin
  for i := 0 to High(Calc.GroupCalcs) do
  begin
    Calc.GroupCalcs[i].Volume := 0;
    Calc.GroupCalcs[i].Percent := 0;
  end;
  Calc.ProductsSumVol := 0;
  Calc.ProductsSumPrc := 0;
  Calc.GroupsSumVol := 0;
  Calc.GroupsSumPrc := 0;
  //
  for i := 0 to High(Products) do
  begin
    Calc.ProductCalcs[i].Volume := Calc.Volume * Products[i].Ratio * 0.01;
    Calc.ProductsSumVol := Calc.ProductsSumVol + Calc.ProductCalcs[i].Volume;
    Calc.ProductsSumPrc := Calc.ProductsSumPrc + Products[i].Ratio;
    id := GetProductByID(Products[i].ProductID).GroupID;
    for j := 0 to High(Calc.GroupCalcs) do
      if Calc.GroupCalcs[j].GroupID = id then
      begin
        Calc.GroupCalcs[j].Volume := Calc.GroupCalcs[j].Volume + Calc.ProductCalcs[i].Volume;
        Calc.GroupCalcs[j].Percent := Calc.GroupCalcs[j].Percent + Products[i].Ratio;
        break;
      end;
  end;
  //
  for i := 0 to High(Calc.GroupCalcs) do
  begin
    Calc.GroupsSumVol := Calc.GroupsSumVol + Calc.GroupCalcs[i].Volume;
    Calc.GroupsSumPrc := Calc.GroupsSumPrc + Calc.GroupCalcs[i].Percent;
  end;
  //
  if ModeID > 0 then
    Calc.LossesVol := Calc.Volume * ModeP.LossesRatio * 0.01;
end;

constructor TProductionUnit.Create(pProductionID, pUnitID, pIndex: integer);
begin
  ID := 0;
  Index := pIndex;
  ProductionID := pProductionID;
  UnitID := pUnitID;
  UnitP := GetUnitByID(pUnitID);
  ModeID := 0;
  ModeP := nil;
  SetLength(Products, 0);
  //
  CreateComponents();
end;

procedure TProductionUnit.CreateComponents;
var i: integer;
begin
  with Components do
  begin
    bmp := TBitmap.Create;
    //
    LBL := TLabel.Create(fmMain);
    LBL.Parent := fmMain.sbProdUnits;
    LBL.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index + 3;
    LBL.Left := UNIT_CMPNT_LBL_X;
    LBL.Tag := Index;
    LBL.Caption := UnitP.Name;
    //
    CB := TComboBox.Create(fmMain);
    CB.Parent := fmMain.sbProdUnits;
    CB.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index;
    CB.Left := UNIT_CMPNT_CB_X;
    CB.Width := UNIT_CMPNT_CB_WIDTH;
    CB.Style := csDropDownList;
    CB.Tag := Index;
    CB.OnChange := fmMain.cbProdUnitChange;
    //
    CB.Clear;
    for i := 0 to length(UnitP.Modes) - 1 do
    begin
     CB.AddItem(UnitP.Modes[i].Name, TObject(UnitP.Modes[i].ID));
      if UnitP.Modes[i].ID = ModeID
        then CB.ItemIndex := CB.Items.Count - 1;
    end;
    //
    BTN_DEL := TButton.Create(fmMain);
    BTN_DEL.Parent := fmMain.sbProdUnits;
    BTN_DEL.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index - 1;
    BTN_DEL.Left := UNIT_CMPNT_BTN_DEL_X;
    BTN_DEL.Tag := Index;
    BTN_DEL.Caption := '';
    BTN_DEL.Images := fmMain.ilButtons;
    BTN_DEL.ImageAlignment := iaCenter;
    BTN_DEL.ImageIndex := 2;
    BTN_DEL.Width := 35;
    BTN_DEL.Height := CB.Height + 2;
    BTN_DEL.OnClick := fmMain.btnProdUnitDelete;
    //
    BTN_SAVE := TButton.Create(fmMain);
    BTN_SAVE.Parent := fmMain.sbProdUnits;
    BTN_SAVE.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index - 1;
    BTN_SAVE.Left := UNIT_CMPNT_BTN_SAVE_X;
    BTN_SAVE.Tag := Index;
    BTN_SAVE.Caption := '';
    BTN_SAVE.Images := fmMain.ilButtons;
    BTN_SAVE.ImageAlignment := iaCenter;
    BTN_SAVE.ImageIndex := 5;
    BTN_SAVE.Width := 35;
    BTN_SAVE.Height := CB.Height + 2;
    BTN_SAVE.OnClick := fmMain.btnProdUnitSave;
    //
    ModePB := TPaintBox.Create(fmMain);
    ModePB.Parent := fmMain.sbProdUnits;
    ModePB.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index - 8;
    ModePB.Left := UNIT_CMPNT_PN_X;
    ModePB.Width := round(UnitP.MaxVolume * UNIT_CMPNT_PN_SCALE);
    ModePB.Height := UNIT_CMPNT_PN_HEIGHT;
    ModePB.Tag := Index;
    ModePB.OnPaint := fmMain.pbModePBPaint;
    ModePB.OnMouseDown := fmMain.pbModePBMouseDown;
    ModePB.OnMouseMove := fmMain.pbModePBMouseMove;
    ModePB.OnMouseUp := fmMain.pbModePBMouseUp;
    ModePB.OnMouseLeave := fmMain.pbModePBMouseLeave;
  end;
end;

procedure TProductionUnit.MoveComponents;
var j: integer;
begin
  with Components do
  begin
    LBL.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index + 3;
    LBL.Tag := Index;
    //
    CB.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index;
    CB.Tag := Index;
    //
    BTN_DEL.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index - 1;
    BTN_DEL.Tag := Index;
    //
    BTN_SAVE.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index - 1;
    BTN_SAVE.Tag := Index;
    //
    ModePB.Top := UNIT_CMPNT_Y_START + UNIT_CMPNT_Y_OFFSET * Index - 8;
    ModePB.Tag := Index;
    //
    for j := 0 to High(Components.ProductSpins) do
    begin
      if (length(Products) > 1) and (j < length(Products) - 1) then
        with Components.ProductSpins[j] do
        begin
          SE.Top := Components.ModePB.Top + Components.ModePB.Height + 5;
          SE.Tag := Self.Index * 1000000 + Index1 * 1000 + Index2;
          LB1.Top := SE.Top - 2;
          LB1.Tag := SE.Tag;
          LB2.Top := SE.Top + 12;
          LB2.Tag := SE.Tag;
        end;
      if (length(Products) > 1) and (j = length(Products) - 1) then
        with Components.ProductSpins[j] do
        begin
          SE.Top := Components.ModePB.Top + Components.ModePB.Height + 5;
          LB1.Top := SE.Top - 2;
          Components.LossSE.Top := Components.ModePB.Top + Components.ModePB.Height + 5;
          Components.LossLB.Top := Components.LossSE.Top - 2;
        end;
    end;
  end;
end;

procedure TProductionUnit.CreateModeComponents1;
var
  i, j, k, pw, px: integer;
begin
  if (length(Products) <= 0) then exit;
  //
  SetLength(Components.ProductComps, 0);
  SetLength(Components.ProductSplits, 0);
  px := 0;
  k := 0;
  for j := 0 to length(Products) - 1 do
  begin
    SetLength(Components.ProductComps, j + 1);
    with Components.ProductComps[j] do
    begin
      ProductID := Products[j].ProductID;
      //
      Left := px;
      pw := round((UnitP.MaxVolume * UNIT_CMPNT_PN_SCALE / 100) * Products[j].Ratio);
      Width := pw;
      px := px + pw;
      //
      if j < length(Products) - 1 then
      begin
        SetLength(Components.ProductSplits, k + 1);
        Components.ProductSplits[k].ProductID1 := Products[j].ProductID;
        Components.ProductSplits[k].ProductID2 := Products[j + 1].ProductID;
        Components.ProductSplits[k].Left := px;
        pw := UNIT_CMPNT_SP_WIDTH;
        Components.ProductSplits[k].Width := pw;
        px := px + pw;
        inc(k);
      end;
    end;
  end;
end;

procedure TProductionUnit.CreateModeComponents2;
var
  i, j, k: integer;
  PR1, PR2: TProduct;
begin
  i := Index;
  //
  DestroyModeComponents();
  //
  SetLength(Components.ProductSpins, length(Products));
  for j := 0 to High(Products) do
  begin
    if (length(Products) > 1) and (j < length(Products) - 1) then
      with Components.ProductSpins[j] do
      begin
        Index1 := j;
        Index2 := j + 1;
        //
        ProductID1 := Products[Index1].ProductID;
        ProductID2 := Products[Index2].ProductID;
        //
        if Products[Index1].Ratio <= Products[Index2].Ratio
          then MIndex := Index1
          else MIndex := Index2;
        k := round(Products[MIndex].Ratio * 0.1);
        BorderLower := Products[MIndex].Ratio - k;
        BorderUpper := Products[MIndex].Ratio + k;
        //
        SE := TSpinEdit.Create(fmMain);
        SE.Visible := false;
        SE.Parent := fmMain.sbProdUnits;
        SE.Width := UNIT_CMPNT_SPIN_WIDTH;
        SE.Left := Components.ModePB.Left + UNIT_CMPNT_SPIN_OFFSET * Index1;
        SE.Top := Components.ModePB.Top + Components.ModePB.Height + 5;
        SE.Tag := Self.Index * 1000000 + Index1 * 1000 + Index2;
        SE.Value := Products[MIndex].Ratio;
        SE.MinValue := BorderLower;
        SE.MaxValue := BorderUpper;
        SE.OnChange := fmMain.ProductSpinEditChange;
        SE.Font.Color := GetColorByIndex(MIndex);
        SE.Font.Style := SE.Font.Style + [fsBold];
        if (BorderLower = BorderUpper)
          then SE.ReadOnly := true;
        //
        PR1 := GetProductByID(ProductID1);
        LB1 := TLabel.Create(fmMain);
        LB1.Visible := false;
        LB1.Parent := fmMain.sbProdUnits;
        LB1.Left := SE.Left + SE.Width + 5;
        LB1.Top := SE.Top - 2;
        LB1.Caption := PR1.Name;
        LB1.Font.Color := GetColorByIndex(Index1);
        LB1.Tag := SE.Tag;
        //
        PR2 := GetProductByID(ProductID2);
        LB2 := TLabel.Create(fmMain);
        LB2.Visible := false;
        LB2.Parent := fmMain.sbProdUnits;
        LB2.Left := SE.Left + SE.Width + 5;
        LB2.Top := SE.Top + 12;
        LB2.Caption := PR2.Name;
        LB2.Font.Color := GetColorByIndex(Index2);
        LB2.Tag := SE.Tag;
      end;

    if (length(Products) > 1) and (j = length(Products) - 1) then
      with Components.ProductSpins[j] do
      begin
        Index1 := j;
        ProductID1 := Products[Index1].ProductID;
        MIndex := Index1;
        //
        SE := TSpinEdit.Create(fmMain);
        SE.Parent := fmMain.sbProdUnits;
        SE.Visible := false;
        SE.Width := UNIT_CMPNT_SPIN_WIDTH;
        SE.Left := Components.ModePB.Left + UNIT_CMPNT_SPIN_OFFSET * Index1;
        SE.Top := Components.ModePB.Top + Components.ModePB.Height + 5;
        SE.Value := Products[Index1].Ratio;
        SE.MinValue := 0;
        SE.MaxValue := 100;
        SE.Font.Color := GetColorByIndex(Index1);
        SE.Font.Style := SE.Font.Style + [fsBold];
        SE.ReadOnly := true;
        SE.Cursor := crNo;
        //
        PR1 := GetProductByID(ProductID1);
        LB1 := TLabel.Create(fmMain);
        LB1.Visible := false;
        LB1.Parent := fmMain.sbProdUnits;
        LB1.Left := SE.Left + SE.Width + 5;
        LB1.Top := SE.Top - 2;
        LB1.Caption := PR1.Name;
        LB1.Font.Color := GetColorByIndex(Index1);
        LB1.Tag := SE.Tag;
        //
        Components.LossSE := TSpinEdit.Create(fmMain);
        Components.LossSE.Visible := false;
        Components.LossSE.Parent := fmMain.sbProdUnits;
        Components.LossSE.Width := UNIT_CMPNT_SPIN_WIDTH;
        Components.LossSE.Left := Components.ModePB.Left + UNIT_CMPNT_SPIN_OFFSET * (Index1 + 1);
        Components.LossSE.Top := Components.ModePB.Top + Components.ModePB.Height + 5;
        Components.LossSE.Value := Self.ModeP.LossesRatio;
        Components.LossSE.MinValue := 0;
        Components.LossSE.MaxValue := 100;
        Components.LossSE.Font.Color := clRed;
        Components.LossSE.Font.Style := SE.Font.Style + [fsBold];
        Components.LossSE.ReadOnly := true;
        Components.LossSE.Cursor := crNo;
        //
        Components.LossLB := TLabel.Create(fmMain);
        Components.LossLB.Visible := false;
        Components.LossLB.Parent := fmMain.sbProdUnits;
        Components.LossLB.Left := Components.LossSE.Left + SE.Width + 5;
        Components.LossLB.Top := Components.LossSE.Top - 2;
        Components.LossLB.Caption := 'Потери';
        Components.LossLB.Font.Color := clRed;
      end;
  end;
  //
  for j := 0 to High(Components.ProductSpins) do
  begin
    if Components.ProductSpins[j].SE <> nil
      then Components.ProductSpins[j].SE.Visible := true;
    if Components.ProductSpins[j].LB1 <> nil
      then Components.ProductSpins[j].LB1.Visible := true;
    if Components.ProductSpins[j].LB2 <> nil
      then Components.ProductSpins[j].LB2.Visible := true;
  end;
  Components.LossSE.Visible := true;
  Components.LossLB.Visible := true;
end;

procedure TProductionUnit.ActualizeSpinEdits;
var i: integer;
begin
  for i := 0 to High(Components.ProductSpins) do
   Components.ProductSpins[i].SE.Value :=
    Products[Components.ProductSpins[i].MIndex].Ratio;
end;

procedure TProductionUnit.DestroyModeComponents;
var i: integer;
begin
  for i := 0 to High(Components.ProductSpins) do
  begin
    if Components.ProductSpins[i].SE <> nil
      then Components.ProductSpins[i].SE.Free;
    if Components.ProductSpins[i].LB1 <> nil
      then Components.ProductSpins[i].LB1.Free;
    if Components.ProductSpins[i].LB2 <> nil
      then Components.ProductSpins[i].LB2.Free;
  end;
  if Components.LossSE <> nil
      then Components.LossSE.Free;
  if Components.LossLB <> nil
      then Components.LossLB.Free;
end;

procedure TProductionUnit.DestroyComponents;
var i: integer;
begin
  if Components.LBL <> nil then Components.LBL.Free;
  if Components.CB <> nil then Components.CB.Free;
  if Components.BTN_DEL <> nil then Components.BTN_DEL.Free;
  if Components.BTN_SAVE <> nil then Components.BTN_SAVE.Free;
  //
  if Components.ModePB <> nil then Components.ModePB.Free;
  if Components.bmp <> nil then Components.bmp.Free;
end;

destructor TProductionUnit.Destroy;
begin
  DestroyComponents();
  DestroyModeComponents();
  //
  inherited;
end;

procedure TProductionUnit.DrawModeProducts;
var
  i, j, k, tx, ty, px, pw: integer;
begin
  with Components do
  begin
    bmp.SetSize(ModePB.Width, ModePB.Height);

    bmp.Canvas.Brush.Style := bsSolid;
    bmp.Canvas.Brush.Color := clWhite;
    bmp.Canvas.Pen.Color := clWhite;
    bmp.Canvas.Rectangle(Rect(0, 0, bmp.Width, bmp.Height));

    bmp.Canvas.Brush.Style := bsClear;
    bmp.Canvas.Pen.Color := clBlack;
    bmp.Canvas.Pen.Width := 1;
    bmp.Canvas.Pen.Style := psSolid;
    bmp.Canvas.Rectangle(Rect(0, 0, bmp.Width, bmp.Height));

    bmp.Canvas.Brush.Style := bsSolid;
    bmp.Canvas.Pen.Color := clBlack;
    bmp.Canvas.Pen.Width := 1;
    bmp.Canvas.Pen.Style := psSolid;

    bmp.Canvas.Font.Name := 'Tahoma';
    bmp.Canvas.Font.Color := clBlack;
    bmp.Canvas.Font.Size := 10;

    ty := (bmp.Height div 2) - 8;

    if (ModeID > 0) then
    begin
      for j := 0 to High(ProductComps) do
      begin
        bmp.Canvas.Brush.Color := GetColorByIndex(j);
        bmp.Canvas.Rectangle(
          Rect(
            ProductComps[j].Left,
            0,
            ProductComps[j].Left + ProductComps[j].Width,
            bmp.Height));
        //
        tx := ProductComps[j].Left + (ProductComps[j].Width div 2) - 8;

        bmp.Canvas.Brush.Style := bsClear;
        bmp.Canvas.TextOut(tx, ty, inttostr(Products[j].Ratio));
        bmp.Canvas.Brush.Style := bsSolid;
      end;
      //
      bmp.Canvas.Brush.Color := clMenuHighlight;
      for j := 0 to High(ProductSplits) do
        bmp.Canvas.Rectangle(
          Rect(
            ProductSplits[j].Left,
            0,
            ProductSplits[j].Left + ProductSplits[j].Width,
            bmp.Height));
      //
      j := length(ProductComps) - 1;
      k := ProductComps[j].Left + ProductComps[j].Width;
      bmp.Canvas.Brush.Color := clRed;
      bmp.Canvas.Rectangle(
        Rect(
          k,
          0,
          bmp.Width,
          bmp.Height));
      tx := k + ((bmp.Width - k) div 2) - 8;
      bmp.Canvas.Brush.Style := bsClear;
      bmp.Canvas.TextOut(tx, ty, inttostr(Self.ModeP.LossesRatio));
      bmp.Canvas.Brush.Style := bsSolid;
    end;

    BitBlt(ModePB.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, bmp.Canvas.Handle, 0, 0, SRCCOPY);
  end;
end;

procedure TProductionUnit.InitProductionModeCalc;
var
  i, j: integer;
  PR: TProduct;

  function IsGroupExists(GroupID: integer): boolean;
  var k: integer;
  begin
    Result := false;
    for k := 0 to High(Calc.GroupCalcs) do
      if Calc.GroupCalcs[k].GroupID = GroupID then
      begin
        Result := true;
        break;
      end;
  end;

begin
  SetLength(Calc.ProductCalcs, length(Products));
  for i := 0 to length(Products) - 1 do
  begin
    Calc.ProductCalcs[i].ProductID := Products[i].ProductID;
    Calc.ProductCalcs[i].Volume := 0;
    PR := GetProductByID(Products[i].ProductID);
    //
    if not IsGroupExists(PR.GroupID) then
    begin
      SetLength(Calc.GroupCalcs, length(Calc.GroupCalcs) + 1);
      j := length(Calc.GroupCalcs) - 1;
      Calc.GroupCalcs[j].GroupID := PR.GroupID;
      Calc.GroupCalcs[j].Volume := 0;
      Calc.GroupCalcs[j].Percent := 0;
    end;
  end;
end;

procedure TProductionUnit.SetProductionMode(pModeID: integer);
var i: integer;
begin
  ModeID := pModeID;
  ModeP := GetUnitModeByID(UnitP.ID, pModeID);
  //
  ModeProductsAssign(ModeP.Products, Products);
  //
  InitProductionModeCalc();
  CreateModeComponents1();
  DrawModeProducts();
  //
  CreateModeComponents2();
end;

procedure TProductionUnit.Update;
var
  i: integer;
  MPS: TModeProducts;
begin
  UnitP := GetUnitByID(UnitID);
  DestroyComponents();
  CreateComponents();
  if ModeID > 0 then
  begin
    //ModeProductsAssign(Products, MPS);
    ModeP := GetUnitModeByID(UnitP.ID, ModeID);
    ModeProductsAssign(ModeP.Products, Products);
    //ModeProductsAssign(MPS, Products);
    //
    InitProductionModeCalc();
    CreateModeComponents1();
    DrawModeProducts();
    //
    CreateModeComponents2();
  end;
end;

{ TProduction }

constructor TProduction.Create;
begin
  ID := 0;
  Name := '';
  TotalVolume := 0;
  UnitMaxVolumesSum := 0;
  Units := TList<TProductionUnit>.Create();
end;

procedure TProduction.AddProductionUnit(UnitID: integer);
var UN: TProductionUnit;
begin
  UN := TProductionUnit.Create(ID, UnitID, Units.Count);
  Units.Add(UN);
  //
  Calculate();
end;

procedure TProduction.DeleteProductionUnit(UnitIndex: integer);
var
  i, Last: integer;
  PRS: TModeProducts;
begin
  CurProd.Units[UnitIndex].Destroy;
  CurProd.Units.Delete(UnitIndex);
  //
  for i := 0 to Units.Count - 1 do
  begin
    Units[i].Index := i;
    Units[i].MoveComponents();
    if Units[i].ModeID > 0
      then Units[i].SetProductionMode(Units[i].ModeID);
  end;
  //
  Calculate();
end;

destructor TProduction.Destroy;
begin
  while Units.Count > 0 do
  begin
    Units[0].Destroy;
    Units.Delete(0);
  end;
  //
  inherited;
end;

procedure TProduction.Update;
var i: integer;
begin
  for i := 0 to Units.Count - 1 do
    Units[i].Update();
end;

procedure TProduction.Calculate;
var i: integer;
begin
  UnitMaxVolumesSum := 0;
  for i := 0 to Units.Count - 1 do
    UnitMaxVolumesSum := UnitMaxVolumesSum + Units[i].UnitP.MaxVolume;
  //
  for i := 0 to Units.Count - 1 do
  begin
    Units[i].Calc.Percent := Units[i].UnitP.MaxVolume / UnitMaxVolumesSum;
    Units[i].Calc.Volume := TotalVolume * Units[i].Calc.Percent;
    Units[i].Calculate();
  end;
  //
  fmMain.DrawScreenReport();
end;

{ TModeProduct }

procedure TModeProduct.Assign(Source: TModeProduct);
begin
  Self.ID := Source.ID;
  Self.UnitID := Source.UnitID;
  Self.ModeID := Source.ModeID;
  Self.ProductID := Source.ProductID;
  Self.OrderID := Source.OrderID;
  Self.Ratio := Source.Ratio;
end;

{ TReport }

procedure TReport.Add(pStyleID: integer; pText: string);
var i, j, k: integer;
begin
  j := 0;
  if (pText = '') and (pStyleID > 0) then j := pStyleID - 1;
  for k := 0 to j do
  begin
    SetLength(Text, length(Text) + 1);
    i := length(Text) - 1;
    Text[i].StyleID := pStyleID;
    Text[i].Text := pText;
  end;
end;

procedure TReport.Clear;
begin
  SetLength(Text, 0);
end;

end.
