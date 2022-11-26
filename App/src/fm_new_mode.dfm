object fmNewMode: TfmNewMode
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmNewMode'
  ClientHeight = 322
  ClientWidth = 356
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
    356
    322)
  PixelsPerInch = 96
  TextHeight = 16
  object lblName: TLabel
    Left = 16
    Top = 19
    Width = 61
    Height = 16
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
  end
  object edName: TEdit
    Left = 83
    Top = 16
    Width = 258
    Height = 24
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 180
    Top = 285
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 266
    Top = 285
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object gbProducts: TGroupBox
    Left = 16
    Top = 46
    Width = 325
    Height = 227
    Caption = ' '#1055#1088#1086#1076#1091#1082#1090#1099' '
    TabOrder = 1
    object lblLosses: TLabel
      Left = 198
      Top = 158
      Width = 47
      Height = 16
      Caption = #1055#1086#1090#1077#1088#1080':'
    end
    object lblRatioSum_: TLabel
      Left = 198
      Top = 188
      Width = 46
      Height = 16
      Caption = #1048#1058#1054#1043#1054':'
    end
    object lblRatioSum: TLabel
      Left = 301
      Top = 188
      Width = 8
      Height = 16
      Alignment = taRightJustify
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnAdd: TButton
      Left = 16
      Top = 29
      Width = 33
      Height = 25
      ImageAlignment = iaCenter
      ImageIndex = 0
      Images = fmMain.ilButtons
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnEdit: TButton
      Left = 51
      Top = 29
      Width = 33
      Height = 25
      ImageAlignment = iaCenter
      ImageIndex = 1
      Images = fmMain.ilButtons
      TabOrder = 1
      OnClick = btnEditClick
    end
    object btnDel: TButton
      Left = 87
      Top = 29
      Width = 33
      Height = 25
      ImageAlignment = iaCenter
      ImageIndex = 2
      Images = fmMain.ilButtons
      TabOrder = 2
      OnClick = btnDelClick
    end
    object lvProducts: TListView
      Left = 16
      Top = 60
      Width = 176
      Height = 150
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        end
        item
          Caption = '%'
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 3
      ViewStyle = vsReport
      OnDblClick = btnEditClick
    end
    object btnUp: TButton
      Left = 123
      Top = 29
      Width = 33
      Height = 25
      ImageAlignment = iaCenter
      ImageIndex = 3
      Images = fmMain.ilButtons
      TabOrder = 4
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 159
      Top = 29
      Width = 33
      Height = 25
      ImageAlignment = iaCenter
      ImageIndex = 4
      Images = fmMain.ilButtons
      TabOrder = 5
      OnClick = btnDownClick
    end
    object lvSummary: TListView
      Left = 198
      Top = 29
      Width = 111
      Height = 120
      Color = clInactiveBorder
      Columns = <
        item
          Caption = #1043#1088#1091#1087#1087#1072
        end
        item
          Caption = '%'
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 6
      ViewStyle = vsReport
    end
    object edLossesRatio: TEdit
      Left = 251
      Top = 155
      Width = 58
      Height = 24
      Alignment = taRightJustify
      NumbersOnly = True
      TabOrder = 7
      OnChange = edLossesRatioChange
    end
  end
end
