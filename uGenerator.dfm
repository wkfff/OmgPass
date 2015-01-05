object frmGenerator: TfrmGenerator
  Left = 427
  Top = 266
  BorderStyle = bsDialog
  Caption = 'Passwords generator'
  ClientHeight = 272
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 190
    Height = 146
    Caption = 'Symbols'
    TabOrder = 0
    object chkCap: TCheckBox
      Left = 16
      Top = 20
      Width = 161
      Height = 17
      Caption = 'Upper case (A ... Z)'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = CheckMe
    end
    object chkLett: TCheckBox
      Left = 16
      Top = 43
      Width = 161
      Height = 17
      Caption = 'Lower case (a ... z)'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = CheckMe
    end
    object chkNum: TCheckBox
      Left = 16
      Top = 66
      Width = 161
      Height = 17
      Caption = 'Digits (0 ... 9)'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = CheckMe
    end
    object chkSpec: TCheckBox
      Left = 16
      Top = 89
      Width = 167
      Height = 17
      Caption = 'Special (!,'#8470',$,%, ...)'
      TabOrder = 3
      OnClick = CheckMe
    end
    object chkOwn: TCheckBox
      Left = 16
      Top = 111
      Width = 58
      Height = 19
      Caption = 'Custom:'
      TabOrder = 4
      WordWrap = True
      OnClick = CheckMe
    end
    object txtOwn: TEdit
      Left = 82
      Top = 112
      Width = 97
      Height = 21
      Enabled = False
      TabOrder = 5
      Text = 'Omg!PassIsTheBestProgram4KeepYourPasswordsEver'
      OnChange = CheckMe
    end
  end
  object GroupBox2: TGroupBox
    Left = 208
    Top = 8
    Width = 190
    Height = 146
    Caption = 'Options'
    TabOrder = 1
    object lblLength: TLabel
      Left = 16
      Top = 17
      Width = 83
      Height = 13
      Caption = 'Password lenght:'
    end
    object UpDown: TUpDown
      Left = 129
      Top = 34
      Width = 24
      Height = 21
      Associate = txtPassLenght
      Min = 4
      Max = 32
      Position = 8
      TabOrder = 0
      OnClick = UpDownClick
    end
    object txtPassLenght: TEdit
      Left = 16
      Top = 34
      Width = 113
      Height = 21
      AutoSize = False
      NumbersOnly = True
      TabOrder = 1
      Text = '8'
    end
    object chkDntRe: TCheckBox
      Left = 16
      Top = 66
      Width = 152
      Height = 17
      Hint = #1057#1080#1084#1074#1086#1083#1099' '#1074' '#1087#1072#1088#1086#1083#1077' '#1085#1077' '#1087#1086#1074#1090#1086#1088#1103#1102#1090#1089#1103
      Caption = 'Use symbols once'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      WordWrap = True
      OnClick = chkDntReClick
    end
    object chkDntDouble: TCheckBox
      Left = 16
      Top = 89
      Width = 152
      Height = 17
      Hint = #1053#1077' '#1089#1090#1072#1074#1080#1090#1100' '#1088#1103#1076#1086#1084' '#1086#1076#1080#1085#1072#1082#1086#1074#1099#1077' '#1089#1080#1084#1074#1086#1083#1099
      Caption = 'Do not duplicate symbols'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 3
      WordWrap = True
    end
    object chkBadSymbols: TCheckBox
      Left = 16
      Top = 111
      Width = 152
      Height = 19
      Hint = #1048#1089#1082#1083#1102#1095#1072#1077#1090' '#1087#1086#1093#1086#1078#1080#1077' '#1089#1080#1084#1074#1086#1083#1099' (1, l, i, ...)'
      Caption = 'Exclude illegible symbols'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 4
      WordWrap = True
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 160
    Width = 390
    Height = 57
    Caption = 'Password'
    TabOrder = 2
    object lblResult: TLabel
      Left = 16
      Top = 21
      Width = 352
      Height = 22
      AutoSize = False
      Caption = 'Omg!Pass'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      ShowAccelChar = False
    end
  end
  object btnModal: TButton
    Left = 318
    Top = 228
    Width = 80
    Height = 33
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnModalClick
  end
  object btnClose: TButton
    Left = 144
    Top = 228
    Width = 81
    Height = 33
    Caption = 'Close'
    TabOrder = 4
    OnClick = btnCloseClick
  end
  object btnGenerate: TButton
    Left = 231
    Top = 228
    Width = 81
    Height = 33
    Caption = 'Create'
    TabOrder = 5
    OnClick = btnGenerateClick
  end
end
