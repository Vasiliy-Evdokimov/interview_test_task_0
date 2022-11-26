object fmTextInput: TfmTextInput
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmTextInput'
  ClientHeight = 113
  ClientWidth = 186
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 16
  object lblCaption: TLabel
    Left = 16
    Top = 16
    Width = 56
    Height = 16
    Caption = 'lblCaption'
  end
  object edText: TEdit
    Left = 16
    Top = 38
    Width = 153
    Height = 24
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 16
    Top = 76
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 94
    Top = 76
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
