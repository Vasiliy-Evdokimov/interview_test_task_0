object fmNewUnit: TfmNewUnit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmNewUnit'
  ClientHeight = 313
  ClientWidth = 284
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
  object lblMaxVolume: TLabel
    Left = 16
    Top = 53
    Width = 147
    Height = 16
    Caption = #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1099#1081' '#1086#1073#1098#1077#1084', '#1090':'
  end
  object lblCode: TLabel
    Left = 16
    Top = 20
    Width = 26
    Height = 16
    Caption = #1050#1086#1076':'
  end
  object lblName: TLabel
    Left = 102
    Top = 19
    Width = 61
    Height = 16
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
  end
  object edMaxVolume: TEdit
    Left = 176
    Top = 50
    Width = 89
    Height = 24
    NumbersOnly = True
    TabOrder = 2
  end
  object gbModes: TGroupBox
    Left = 16
    Top = 80
    Width = 249
    Height = 189
    Caption = ' '#1056#1077#1078#1080#1084#1099' '
    TabOrder = 3
    DesignSize = (
      249
      189)
    object btnAdd: TButton
      Left = 207
      Top = 24
      Width = 33
      Height = 25
      Anchors = [akTop, akRight]
      ImageAlignment = iaCenter
      ImageIndex = 0
      Images = fmMain.ilButtons
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnEdit: TButton
      Left = 207
      Top = 55
      Width = 33
      Height = 25
      Anchors = [akTop, akRight]
      ImageAlignment = iaCenter
      ImageIndex = 1
      Images = fmMain.ilButtons
      TabOrder = 1
      OnClick = btnEditClick
    end
    object btnDel: TButton
      Left = 207
      Top = 86
      Width = 33
      Height = 25
      Anchors = [akTop, akRight]
      ImageAlignment = iaCenter
      ImageIndex = 2
      Images = fmMain.ilButtons
      TabOrder = 2
      OnClick = btnDelClick
    end
    object lvModes: TListView
      Left = 16
      Top = 24
      Width = 185
      Height = 150
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 3
      ViewStyle = vsReport
      OnDblClick = btnEditClick
    end
    object btnUp: TButton
      Left = 207
      Top = 117
      Width = 33
      Height = 25
      Anchors = [akTop, akRight]
      ImageAlignment = iaCenter
      ImageIndex = 3
      Images = fmMain.ilButtons
      TabOrder = 4
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 207
      Top = 148
      Width = 33
      Height = 25
      Anchors = [akTop, akRight]
      ImageAlignment = iaCenter
      ImageIndex = 4
      Images = fmMain.ilButtons
      TabOrder = 5
      OnClick = btnDownClick
    end
  end
  object edCode: TEdit
    Left = 52
    Top = 16
    Width = 37
    Height = 24
    NumbersOnly = True
    TabOrder = 0
  end
  object edName: TEdit
    Left = 176
    Top = 16
    Width = 89
    Height = 24
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 109
    Top = 280
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 190
    Top = 280
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 5
    OnClick = btnCancelClick
  end
end
