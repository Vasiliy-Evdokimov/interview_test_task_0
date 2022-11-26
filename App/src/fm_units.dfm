object fmUnits: TfmUnits
  Left = 0
  Top = 0
  Align = alCustom
  BorderStyle = bsDialog
  Caption = #1058#1045#1061'. '#1059#1057#1058#1040#1053#1054#1042#1050#1048
  ClientHeight = 277
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  ExplicitWidth = 320
  ExplicitHeight = 240
  DesignSize = (
    400
    277)
  PixelsPerInch = 96
  TextHeight = 16
  object lvUnits: TListView
    Left = 8
    Top = 8
    Width = 343
    Height = 261
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'ID'
      end
      item
        Caption = #1050#1086#1076
      end
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077
      end
      item
        Caption = #1052#1072#1082#1089'. '#1086#1073#1098#1077#1084', '#1090
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = btnEditClick
  end
  object btnAdd: TButton
    Left = 357
    Top = 8
    Width = 35
    Height = 25
    Anchors = [akTop, akRight]
    ImageAlignment = iaCenter
    ImageIndex = 0
    Images = fmMain.ilButtons
    TabOrder = 1
    OnClick = btnAddClick
  end
  object btnEdit: TButton
    Left = 357
    Top = 39
    Width = 34
    Height = 25
    Anchors = [akTop, akRight]
    ImageAlignment = iaCenter
    ImageIndex = 1
    Images = fmMain.ilButtons
    TabOrder = 2
    OnClick = btnEditClick
  end
  object btnDel: TButton
    Left = 357
    Top = 70
    Width = 34
    Height = 25
    Anchors = [akTop, akRight]
    ImageAlignment = iaCenter
    ImageIndex = 2
    Images = fmMain.ilButtons
    TabOrder = 3
    OnClick = btnDelClick
  end
end
