object fmProductGroups: TfmProductGroups
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1043#1056#1059#1055#1055#1067' '#1055#1056#1054#1044#1059#1050#1058#1054#1042
  ClientHeight = 250
  ClientWidth = 336
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
  object lvGroups: TListView
    Left = 8
    Top = 8
    Width = 281
    Height = 233
    Align = alCustom
    Columns = <
      item
        Caption = 'ID'
      end
      item
        Caption = #1050#1086#1076
      end
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = btnEditClick
  end
  object btnAdd: TButton
    Left = 295
    Top = 8
    Width = 34
    Height = 25
    ImageAlignment = iaCenter
    ImageIndex = 0
    Images = fmMain.ilButtons
    TabOrder = 1
    OnClick = btnAddClick
  end
  object btnEdit: TButton
    Left = 295
    Top = 39
    Width = 34
    Height = 25
    ImageAlignment = iaCenter
    ImageIndex = 1
    Images = fmMain.ilButtons
    TabOrder = 2
    OnClick = btnEditClick
  end
  object btnDel: TButton
    Left = 295
    Top = 70
    Width = 34
    Height = 25
    ImageAlignment = iaCenter
    ImageIndex = 2
    Images = fmMain.ilButtons
    TabOrder = 3
    OnClick = btnDelClick
  end
end
