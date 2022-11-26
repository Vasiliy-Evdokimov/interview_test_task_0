object fmNewProduct: TfmNewProduct
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmNewProduct'
  ClientHeight = 153
  ClientWidth = 236
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object lblCode: TLabel
    Left = 16
    Top = 19
    Width = 26
    Height = 16
    Caption = #1050#1086#1076':'
  end
  object lblName: TLabel
    Left = 16
    Top = 49
    Width = 61
    Height = 16
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
  end
  object lblGroup: TLabel
    Left = 16
    Top = 79
    Width = 46
    Height = 16
    Caption = #1043#1088#1091#1087#1087#1072':'
  end
  object edCode: TEdit
    Left = 96
    Top = 16
    Width = 121
    Height = 24
    NumbersOnly = True
    TabOrder = 0
  end
  object edName: TEdit
    Left = 96
    Top = 46
    Width = 121
    Height = 24
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 61
    Top = 115
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 142
    Top = 115
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object cbGroups: TComboBox
    Left = 96
    Top = 76
    Width = 121
    Height = 24
    Style = csDropDownList
    TabOrder = 2
  end
end
