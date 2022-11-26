unit fm_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, IniFiles, Vcl.ImgList, Vcl.Buttons, Vcl.Samples.Spin, Registry,
  nauka_types, sqlthrd;

type
  TfmMain = class(TForm)
    mmMain: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    pnProdDetails: TPanel;
    ilButtons: TImageList;
    pnProdUnits: TPanel;
    pnButtons: TPanel;
    lblProdUnitAdd: TLabel;
    btnProdUnitAdd: TButton;
    cbProdUnitAdd: TComboBox;
    sbProdUnits: TScrollBox;
    spProduction: TSplitter;
    pnProdUpper: TPanel;
    pnProdResults: TPanel;
    sbProdResults: TScrollBox;
    pbProdResults: TPaintBox;
    pnScroll: TPanel;
    btnUpdate: TButton;
    edTotalVolume: TEdit;
    lblTotalVolume: TLabel;
    btnReport: TButton;
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnProdUnitAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pbProdResultsPaint(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure edTotalVolumeChange(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
  private
    procedure LoadConfig;
    procedure SaveConfig;

    procedure GetLists;

    procedure CreateModeComponents(UnitIndex: integer);

    procedure InitIE;
 public
    procedure btnProdUnitDelete(Sender: TObject);
    procedure btnProdUnitSave(Sender: TObject);
    procedure cbProdUnitChange(Sender: TObject);

    procedure pbModePBPaint(Sender: TObject);
    procedure pbModePBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbModePBMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbModePBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pbModePBMouseLeave(Sender: TObject);

    procedure ProductSpinEditChange(Sender: TObject);

    procedure RefreshProdUnitAddList;
    procedure DrawScreenReport;

    procedure UnderConstruction;

    procedure SQL_AddProductToModeResult(Command: TSQLCommand; DS: TSQLDataSet);
  end;

  PDrawParams = ^TDrawParams;
  TDrawParams = record
    SplitterID: integer;
    X: integer;                        // start X
    Y: integer;                        // start Y
    MouseX: integer;                   // mouse X when clicked
    MouseY: integer;                   // mouse Y when clicked
    MouseDn: boolean;                  // mouse clicked flag
    Shift: TShiftState;                // shift pressed flag
  end;

var
  fmMain: TfmMain;
  DrawPrm: TDrawParams;
  bmp: TBitmap;
  PatternFileName,
  ReportFileName: string;
  report: TReport;

implementation

uses
  fm_units, fm_new_unit, fm_product_groups,
  fm_products, fm_new_mode, fm_text_input,
  fm_preview;

{$R *.dfm}

procedure TfmMain.InitIE();
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if ((IERegistryPath <> '') and (IEVersion <> 0)) then
    begin
      Reg.OpenKey(IERegistryPath, true);
      Reg.WriteInteger(ExtractFileName(Application.ExeName), IEVersion);
    end;
  finally
    Reg.Free;
  end;
end;

procedure TfmMain.ProductSpinEditChange(Sender: TObject);
var
  tag, uidx, pidx1, pidx2, midx: integer;
  prev_val, new_val, delta: integer;
begin
  tag := (Sender as TSpinEdit).Tag;
  uidx := tag div 1000000;
  pidx1 := (tag mod 1000000) div 1000;
  pidx2 := tag mod 1000;
  midx := CurProd.Units[uidx].Components.ProductSpins[pidx1].MIndex;
  //
  prev_val := CurProd.Units[uidx].Products[midx].Ratio;
  new_val := (Sender as TSpinEdit).Value;
  delta := prev_val - new_val;
  //
  if midx = pidx1 then
  begin
    CurProd.Units[uidx].Products[pidx1].Ratio := new_val;
    CurProd.Units[uidx].Products[pidx2].Ratio :=
      CurProd.Units[uidx].Products[pidx2].Ratio + delta;
  end else
  begin
    CurProd.Units[uidx].Products[pidx2].Ratio := new_val;
    CurProd.Units[uidx].Products[pidx1].Ratio :=
      CurProd.Units[uidx].Products[pidx1].Ratio + delta;
  end;
  //
  CurProd.Units[uidx].ActualizeSpinEdits();
  CurProd.Units[uidx].CreateModeComponents1();
  CurProd.Units[uidx].DrawModeProducts();
  CurProd.Calculate;
end;

procedure TfmMain.UnderConstruction;
begin
  Application.MessageBox(
    'Эта функция в разработке :)',
    PChar(Application.Title),
    MB_ICONINFORMATION + MB_OK);
end;

procedure TfmMain.GetLists;
begin
  fmProductGroups.SQL_RefreshProductGroupsList();
  fmProducts.SQL_RefreshProductsList();
  fmUnits.SQL_RefreshUnitsList();
end;

procedure TfmMain.btnProdUnitAddClick(Sender: TObject);
var i: integer;
begin
  if cbProdUnitAdd.ItemIndex < 0 then exit;
  //
  i := integer(cbProdUnitAdd.Items.Objects[cbProdUnitAdd.ItemIndex]);
  CurProd.AddProductionUnit(i);
  //
  RefreshProdUnitAddList();
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  SaveConfig;
  //
  sqlth.Terminate;
  while sqlth.Suspended do sqlth.Resume;
  sqlth.WaitFor;
  sqlth.Free;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Application.Title := '..:: НАУKА ТЕСТ ::..';
  //
  CurProd := TProduction.Create;
  bmp := TBitmap.Create;
  //
  PatternFileName := ExtractFileDir(Application.ExeName) + '\pattern.html';
  ReportFileName := ExtractFileDir(Application.ExeName) + '\report.html';
  InitIE();
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  bmp.Free;
  CurProd.Destroy;
end;

procedure TfmMain.FormPaint(Sender: TObject);
begin
  DrawScreenReport();
end;

procedure TfmMain.FormShow(Sender: TObject);
begin
  LoadConfig;
  //
  sqlth := TSQLThread.Create(true);
  sqlth.SetConnectionParams(@cnfg.Database);
  sqlth.Resume;
  //
  GetLists();
  //
  edTotalVolume.Text := inttostr(CurProd.TotalVolume);
end;

procedure TfmMain.LoadConfig;
var
  ini: TIniFile;
  scn: string;
  i, x: integer;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));

  scn := 'MainForm';
//	if ini.ReadBool(scn, 'Maximized', false) then
//	begin
//		fmMain.WindowState := wsMaximized;
//	end else
//	begin
		fmMain.Width := ini.ReadInteger(scn, 'Width', 640);
		fmMain.Height := ini.ReadInteger(scn, 'Height', 480);
//	end;
  pnProdUnits.Height := ini.ReadInteger(scn, 'pnProdUnits.Height', 200);

	scn := 'Database';
	cnfg.Database.Server := ini.ReadString(scn, 'Server', '(local)');
	cnfg.Database.DatabaseName := ini.ReadString(scn, 'DatabaseName', 'nauka');
	cnfg.Database.User := ini.ReadString(scn, 'User', 'sa');
	cnfg.Database.Password := ini.ReadString(scn, 'Password', 'sa');
	cnfg.Database.ConnectionTimeout := ini.ReadInteger(scn, 'ConnectionTimeout', 15);
	cnfg.Database.CommandTimeout := ini.ReadInteger(scn, 'CommandTimeout', 30);

  scn := 'ProductGroups';
  for i := 0 to fmProductGroups.lvGroups.Columns.Count - 1 do
	begin
		x := ini.ReadInteger(scn, 'fmProductGroups.lvGroups.Columns[' + IntToStr(i) + '].Width', 50);
		if x < 5 then x := 50;
		fmProductGroups.lvGroups.Columns[i].Width := x;
	end;

  scn := 'Products';
  for i := 0 to fmProducts.lvProducts.Columns.Count - 1 do
	begin
		x := ini.ReadInteger(scn, 'fmProducts.lvProducts.Columns[' + IntToStr(i) + '].Width', 50);
		if x < 5 then x := 50;
		fmProducts.lvProducts.Columns[i].Width := x;
	end;

  scn := 'Units';
  for i := 0 to fmUnits.lvUnits.Columns.Count - 1 do
	begin
		x := ini.ReadInteger(scn, 'fmUnits.lvUnits.Columns[' + IntToStr(i) + '].Width', 50);
		if x < 5 then x := 50;
		fmUnits.lvUnits.Columns[i].Width := x;
	end;

  scn := 'UnitModes';
  for i := 0 to fmNewUnit.lvModes.Columns.Count - 1 do
	begin
		x := ini.ReadInteger(scn, 'fmNewUnit.lvModes.Columns[' + IntToStr(i) + '].Width', 50);
		if x < 5 then x := 50;
		fmNewUnit.lvModes.Columns[i].Width := x;
	end;

  scn := 'ModeProducts';
  for i := 0 to fmNewMode.lvProducts.Columns.Count - 1 do
	begin
		x := ini.ReadInteger(scn, 'fmNewMode.lvProducts.Columns[' + IntToStr(i) + '].Width', 50);
		if x < 5 then x := 50;
		fmNewMode.lvProducts.Columns[i].Width := x;
	end;

  scn := 'ModeSummary';
  for i := 0 to fmNewMode.lvSummary.Columns.Count - 1 do
	begin
		x := ini.ReadInteger(scn, 'fmNewMode.lvSummary.Columns[' + IntToStr(i) + '].Width', 50);
		if x < 5 then x := 50;
		fmNewMode.lvSummary.Columns[i].Width := x;
	end;

  ini.Free;
end;

procedure TfmMain.N2Click(Sender: TObject);
begin
  fmUnits.ShowModal;
end;

procedure TfmMain.N3Click(Sender: TObject);
begin
  fmProductGroups.ShowModal;
end;

procedure TfmMain.N4Click(Sender: TObject);
begin
  fmProducts.ShowModal;
end;

procedure TfmMain.pbModePBPaint(Sender: TObject);
var i, j: integer;
begin
  i := (Sender as TPaintBox).Tag;
  //
  CurProd.Units[i].DrawModeProducts();
end;

procedure TfmMain.pbProdResultsPaint(Sender: TObject);
begin
  DrawScreenReport();
end;

procedure TfmMain.pbModePBMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i, sid: integer;
begin
  i := (Sender as TPaintBox).Tag;
  sid := GetSplitterIndexByXY(CurProd.Units[i].Components, X, Y);
  if sid >= 0 then
  begin
    UnderConstruction(); exit;
    //
    DrawPrm.MouseDn := true;
    DrawPrm.MouseX := X;
    DrawPrm.MouseY := Y;
    DrawPrm.Shift := Shift;
    DrawPrm.SplitterID := sid;
  end;
end;

procedure TfmMain.pbModePBMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DrawPrm.MouseDn := false;
end;

procedure TfmMain.pbModePBMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i, j, sid: integer;
begin
  i := (Sender as TPaintBox).Tag;
  sid := GetSplitterIndexByXY(CurProd.Units[i].Components, X, Y);
  if sid >= 0
    then Screen.Cursor := crHSplit
    else Screen.Cursor := crDefault;
  //
  if DrawPrm.MouseDn then
  begin
    //SP.X := SP.X + X - DrawPrm.MouseX;
    //SP.Y := SP.Y + Y - DrawPrm.MouseY;
  end;
end;

procedure TfmMain.pbModePBMouseLeave(Sender: TObject);
begin
  Screen.Cursor := crDefault;
end;

procedure TfmMain.btnProdUnitDelete(Sender: TObject);
var i: integer;
begin
  i := (Sender as TButton).Tag;
  if Application.MessageBox(
    PChar('Вы уверены, что хотите удалить из производства' + #10#13 +
          'установку "' + CurProd.Units[i].UnitP.Name + '" ?'),
    PChar(Application.Title),
    MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;
  //
  CurProd.DeleteProductionUnit(i);
  RefreshProdUnitAddList();
end;

procedure TfmMain.btnProdUnitSave(Sender: TObject);
var
  i: integer;
  q, name: string;
begin
  i := (Sender as TButton).Tag;
  if CurProd.Units[i].ModeID <= 0 then exit;
  //
  if Application.MessageBox(
    PChar('Сохранить этот режим как новый для ' + #10#13 +
          'установки "' + CurProd.Units[i].UnitP.Name + '" ?'),
    PChar(Application.Title),
    MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;
  //
  fmTextInput.Caption := '';
  fmTextInput.lblCaption.Caption := 'Название режима:';
  fmTextInput.edText.Text := '';
  if fmTextInput.ShowModal = mrOk then
  begin
    name := trim(fmTextInput.edText.Text);
    q :=
      'exec AddProductToMode ' +
      inttostr(CurProd.Units[i].UnitP.ID) + ', ' +
      QuotedStr(name) + ', ' +
      inttostr(CurProd.Units[i].ModeP.LossesRatio) + ', ' +
      QuotedStr(MakeModeProductXML(CurProd.Units[i].ModeP^, CurProd.Units[i].Products));
    sqlth.Add(q, '', ctCommand, SQL_AddProductToModeResult);
  end;
end;

procedure TfmMain.btnReportClick(Sender: TObject);
var
  PF: TextFile;
  RepOut: TStringList;
  s: string;
  i: integer;
begin
  RepOut := TStringList.Create;
  RepOut.Clear;
  if FileExists(PatternFileName) then
  begin
    try
      AssignFile(PF, PatternFileName);
      Reset(PF);
      while not EOF(PF) do
      begin
        readln(PF, s);
        if trim(s) <> '*INSERT YOUR CONTENT HERE*'
          then RepOut.Add(s)
          else
            for i := 0 to length(report.Text) - 1 do
              RepOut.Add(
                '<span class=s' + inttostr(report.Text[i].StyleID) + '>' +
                report.Text[i].Text + '</span>');
      end;
    finally
      CloseFile(PF);
    end;
  end else
    for i := 0 to length(report.Text) - 1 do
      RepOut.Add(
        '<span class=s' + inttostr(report.Text[i].StyleID) + '>' +
        report.Text[i].Text + '</span>');
  RepOut.SaveToFile(ReportFileName);
  RepOut.Free;
  //
  fmPreview.wbPreview.Navigate(ReportFileName + '?randomize=' + inttostr(random(1000)));
  fmPreview.ShowModal;
end;

procedure TfmMain.SQL_AddProductToModeResult(Command: TSQLCommand; DS: TSQLDataSet);
begin
  if Command.Successful then
  begin
    Application.MessageBox(
    PChar('Режим успешно сохранен!'),
    PChar(Application.Title),
    MB_OK + MB_ICONINFORMATION);
    //
    GetLists();
  end;
end;

procedure TfmMain.btnUpdateClick(Sender: TObject);
begin
  CurProd.Update();
end;

procedure TfmMain.cbProdUnitChange(Sender: TObject);
var
  i, j: integer;
  cb: TComboBox;
begin
  i := (Sender as TComboBox).Tag;
  j := (Sender as TComboBox).ItemIndex;
  if j < 0 then exit;
  //
  cb := CurProd.Units[i].Components.CB;
  j := integer(cb.Items.Objects[cb.ItemIndex]);
  CurProd.Units[i].SetProductionMode(j);
  CurProd.Calculate();
end;

procedure TfmMain.CreateModeComponents(UnitIndex: integer);
var
  i, j, k, pw, px: integer;
  UMPR: TModeProducts;
begin
  i := UnitIndex;
  //
  UMPR := CurProd.Units[i].Products;
  SetLength(UnitComps[i].ProductComps, length(UMPR));
  SetLength(UnitComps[i].ProductSplits, 0);
  px := 0;
  for j := 0 to High(UMPR) do
  begin
    with UnitComps[i].ProductComps[j] do
    begin
      ProductID := UMPR[j].ProductID;
      //
      Left := px;
      pw := round((CurProd.Units[i].UnitP.MaxVolume * UNIT_CMPNT_PN_SCALE / 100) * UMPR[j].Ratio);
      Width := pw;
      px := px + pw;
      //
      if j < length(UMPR) - 1 then
      begin
        k := length(UnitComps[i].ProductSplits) + 1;
        SetLength(UnitComps[i].ProductSplits, k);
        k := k - 1;
        UnitComps[i].ProductSplits[k].ProductID1 := UMPR[j].ProductID;
        UnitComps[i].ProductSplits[k].ProductID2 := UMPR[j + 1].ProductID;
        UnitComps[i].ProductSplits[k].Left := px;
        pw := UNIT_CMPNT_SP_WIDTH;
        UnitComps[i].ProductSplits[k].Width := pw;
        px := px + pw;
      end;
    end;
  end;
end;

procedure TfmMain.DrawScreenReport;
const
  frmt_head = '%20s%12.12s%5s%15.15s';
  frmt_unit = '%-20s%12.1f%5s%15.3f';
  frmt_group = '%2s%-18s%12.1f%5s%15.3f';
  frmt_prod = '%4s%-16s%12.1f%5s%15.3f';
var
  i, j, k,
  xx, yy,
  y_offset, x_offset: integer;
  s: string;
  PR: TProduct;
  GR: TProductGroup;
begin
  if bmp.Width < pbProdResults.Width then bmp.Width := pbProdResults.Width;
  if bmp.Height < pbProdResults.Height then bmp.Height := pbProdResults.Height;

  bmp.Canvas.Brush.Style := bsSolid;
  bmp.Canvas.Brush.Color := clInactiveCaption;
  bmp.Canvas.Pen.Color := clWhite;
  bmp.Canvas.Rectangle(Rect(0, 0, bmp.Width, bmp.Height));

  report.Clear;

  s := 'ОТЧЕТ О МОДЕЛИРОВАНИИ ПРОИЗВОДСТВА';
  report.Add(0, s);
  report.Add(2, '');

  s := 'Заданное количество сырья, т: ' + inttostr(CurProd.TotalVolume);
  report.Add(5, s);
  report.Add(0, '');

  x_offset := 20;
  y_offset := 25;
  //
  bmp.Canvas.Font.Name := 'Courier New';
  bmp.Canvas.Font.Size := 12;
  //
  bmp.Canvas.Font.Style := bmp.Canvas.Font.Style + [fsBold, fsUnderline] - [fsItalic];
  bmp.Canvas.Font.Color := clBlack;
  //
  s :=
    Format(frmt_head, [' ', 'Нагрузка, %', ' ', 'Кол-во сырья, т']);
   //
  yy := y_offset;
  if CurProd.Units.Count > 0 then
  begin
    bmp.Canvas.TextOut(x_offset, yy, s);
    report.Add(1, s);
  end;
  //
  for i := 0 to CurProd.Units.Count - 1 do
  begin
    inc(yy, y_offset);
    bmp.Canvas.Font.Style := bmp.Canvas.Font.Style + [fsBold, fsUnderline] - [fsItalic];
    bmp.Canvas.Font.Color := clBlack;
    s :=
      Format(frmt_unit,
        [CurProd.Units[i].UnitP.Name,
        CurProd.Units[i].Calc.Percent * 100,
        ' ',
        CurProd.Units[i].Calc.Volume]);
    bmp.Canvas.TextOut(x_offset, yy, s);
    report.Add(1, s);

    for j := 0 to High(CurProd.Units[i].Calc.GroupCalcs) do
    begin
      bmp.Canvas.Font.Color := clBlack;
      inc(yy, y_offset);
      bmp.Canvas.Font.Style := bmp.Canvas.Font.Style - [fsBold, fsUnderline, fsItalic];
      GR := GetProductGroupByID(CurProd.Units[i].Calc.GroupCalcs[j].GroupID);
      s:=
        Format(frmt_group,
          [' ', GR.Name,
          CurProd.Units[i].Calc.GroupCalcs[j].Percent / 1,
          ' ',
          CurProd.Units[i].Calc.GroupCalcs[j].Volume]);
      bmp.Canvas.TextOut(x_offset, yy, s);
      report.Add(2, s);
      //
      for k := 0 to High(CurProd.Units[i].Products) do
      begin
        PR := GetProductByID(CurProd.Units[i].Products[k].ProductID);
        if CurProd.Units[i].Calc.GroupCalcs[j].GroupID <> PR.GroupID
          then continue;
        //
        bmp.Canvas.Font.Color := GetColorByIndex(k);
        inc(yy, y_offset);
        bmp.Canvas.Font.Style := bmp.Canvas.Font.Style - [fsBold, fsUnderline] + [fsItalic];
        s:=
          Format(frmt_prod,
            [' ', PR.Name,
            CurProd.Units[i].Products[k].Ratio / 1,
            ' ',
            CurProd.Units[i].Calc.ProductCalcs[k].Volume]);
        bmp.Canvas.TextOut(x_offset, yy, s);
        report.Add(3, s);
      end;
    end;
    //
    bmp.Canvas.Font.Color := clRed;
    bmp.Canvas.Font.Style := bmp.Canvas.Font.Style - [fsUnderline, fsItalic, fsBold];
    if CurProd.Units[i].ModeID > 0 then
    begin
      inc(yy, y_offset);
      s :=
        Format(frmt_group,
          [' ', 'Потери',
          CurProd.Units[i].ModeP.LossesRatio / 1,
          ' ',
          CurProd.Units[i].Calc.LossesVol]);
      bmp.Canvas.TextOut(x_offset, yy, s);
      report.Add(4, s);
    end;
    //
    bmp.Canvas.Font.Color := clBlack;
    bmp.Canvas.Font.Style := bmp.Canvas.Font.Style - [fsUnderline, fsItalic] + [fsBold];
    inc(yy, y_offset);
    s :=
      Format(frmt_unit,
      ['Итого по группам:',
      CurProd.Units[i].Calc.GroupsSumPrc,
      ' ',
      CurProd.Units[i].Calc.GroupsSumVol]);
    bmp.Canvas.TextOut(x_offset, yy, s);
    report.Add(5, s);
    //
    bmp.Canvas.Font.Style := bmp.Canvas.Font.Style - [fsItalic] + [fsItalic, fsUnderline];
    inc(yy, y_offset);
    s :=
      Format(frmt_unit,
      ['Итого по продуктам:',
      CurProd.Units[i].Calc.ProductsSumPrc,
      ' ',
      CurProd.Units[i].Calc.ProductsSumVol]);
    bmp.Canvas.TextOut(x_offset, yy, s);
    report.Add(6, s);
  end;
  //
  report.Add(2, '');
  report.Add(5, FormatDateTime('dd.mm.yyyy hh:nn:ss', Now()));
  //
  pnScroll.Top := yy;
  //
  BitBlt(pbProdResults.Canvas.Handle, 0, 0, pbProdResults.Width, pbProdResults.Height,
  	     bmp.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TfmMain.edTotalVolumeChange(Sender: TObject);
begin
  if trim(edTotalVolume.Text) = ''
    then CurProd.TotalVolume := 0
    else CurProd.TotalVolume := strtoint(trim(edTotalVolume.Text));
  CurProd.Calculate();
end;

procedure TfmMain.RefreshProdUnitAddList;
  var
  i, j: integer;
  flExist: boolean;
begin
  cbProdUnitAdd.Clear;
  for i := Low(Units) to High(Units) do
  begin
    flExist := false;
    for j := 0 to CurProd.Units.Count - 1 do
      if Units[i].ID = CurProd.Units[j].UnitID then
      begin
        flExist := true;
        break;
      end;
    if flExist then continue;
    //
    cbProdUnitAdd.AddItem(Units[i].Name, TObject(Units[i].ID));
  end;
  cbProdUnitAdd.Enabled := (cbProdUnitAdd.Items.Count > 0);
end;

procedure TfmMain.SaveConfig;
var
	ini: TIniFile;
  scn: string;
  i: integer;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));

  scn := 'MainForm';
	ini.WriteBool(scn, 'Maximized', fmMain.WindowState = wsMaximized);
	ini.WriteInteger(scn, 'Width', fmMain.Width);
	ini.WriteInteger(scn, 'Height', fmMain.Height);
  ini.WriteInteger(scn, 'pnProdUnits.Height', pnProdUnits.Height);

  scn := 'ProductGroups';
  for i := 0 to fmProductGroups.lvGroups.Columns.Count - 1 do
    ini.WriteInteger(
      scn,
      'fmProductGroups.lvGroups.Columns[' + IntToStr(i) + '].Width',
      fmProductGroups.lvGroups.Columns[i].Width);

  scn := 'Products';
  for i := 0 to fmProducts.lvProducts.Columns.Count - 1 do
    ini.WriteInteger(
      scn,
      'fmProducts.lvProducts.Columns[' + IntToStr(i) + '].Width',
      fmProducts.lvProducts.Columns[i].Width);

  scn := 'Units';
  for i := 0 to fmUnits.lvUnits.Columns.Count - 1 do
    ini.WriteInteger(
      scn,
      'fmUnits.lvUnits.Columns[' + IntToStr(i) + '].Width',
      fmUnits.lvUnits.Columns[i].Width);

  scn := 'UnitModes';
  for i := 0 to fmNewUnit.lvModes.Columns.Count - 1 do
    ini.WriteInteger(
      scn,
      'fmNewUnit.lvModes.Columns[' + IntToStr(i) + '].Width',
      fmNewUnit.lvModes.Columns[i].Width);

  scn := 'ModeProducts';
  for i := 0 to fmNewMode.lvProducts.Columns.Count - 1 do
    ini.WriteInteger(
      scn,
      'fmNewMode.lvProducts.Columns[' + IntToStr(i) + '].Width',
      fmNewMode.lvProducts.Columns[i].Width);

 scn := 'ModeSummary';
  for i := 0 to fmNewMode.lvSummary.Columns.Count - 1 do
    ini.WriteInteger(
      scn,
      'fmNewMode.lvSummary.Columns[' + IntToStr(i) + '].Width',
      fmNewMode.lvSummary.Columns[i].Width);

  ini.Free;
end;

end.
