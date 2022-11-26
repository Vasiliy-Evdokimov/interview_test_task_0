object fmNewModeProduct: TfmNewModeProduct
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmNewModeProduct'
  ClientHeight = 109
  ClientWidth = 243
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  DesignSize = (
    243
    109)
  PixelsPerInch = 96
  TextHeight = 16
  object lblRatio: TLabel
    Left = 16
    Top = 45
    Width = 116
    Height = 16
    Caption = #1050#1086#1101#1092#1092'. '#1074#1099#1088#1072#1073#1086#1090#1082#1080':'
  end
  object Label1: TLabel
    Left = 16
    Top = 11
    Width = 52
    Height = 16
    Caption = #1055#1088#1086#1076#1091#1082#1090':'
  end
  object edRatio: TEdit
    Left = 144
    Top = 42
    Width = 81
    Height = 24
    NumbersOnly = True
    TabOrder = 1
  end
  object cbProducts: TComboBox
    Left = 80
    Top = 8
    Width = 145
    Height = 24
    Style = csDropDownList
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 69
    Top = 76
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 150
    Top = 76
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = btnCancelClick
  end
end
