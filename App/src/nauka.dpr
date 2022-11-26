program nauka;

uses
  Vcl.Forms,
  fm_main in 'fm_main.pas' {fmMain},
  fm_units in 'fm_units.pas' {fmUnits},
  fm_new_unit in 'fm_new_unit.pas' {fmNewUnit},
  fm_new_mode in 'fm_new_mode.pas' {fmNewMode},
  fm_product_groups in 'fm_product_groups.pas' {fmProductGroups},
  fm_new_product_group in 'fm_new_product_group.pas' {fmNewProductGroup},
  fm_products in 'fm_products.pas' {fmProducts},
  fm_new_product in 'fm_new_product.pas' {fmNewProduct},
  nauka_types in 'nauka_types.pas',
  sqlthrd in 'sqlthrd.pas',
  fm_new_mode_product in 'fm_new_mode_product.pas' {fmNewModeProduct},
  fm_text_input in 'fm_text_input.pas' {fmTextInput},
  fm_preview in 'fm_preview.pas' {fmPreview};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmUnits, fmUnits);
  Application.CreateForm(TfmNewUnit, fmNewUnit);
  Application.CreateForm(TfmNewMode, fmNewMode);
  Application.CreateForm(TfmProductGroups, fmProductGroups);
  Application.CreateForm(TfmNewProductGroup, fmNewProductGroup);
  Application.CreateForm(TfmProducts, fmProducts);
  Application.CreateForm(TfmNewProduct, fmNewProduct);
  Application.CreateForm(TfmNewModeProduct, fmNewModeProduct);
  Application.CreateForm(TfmTextInput, fmTextInput);
  Application.CreateForm(TfmPreview, fmPreview);
  Application.Run;
end.
