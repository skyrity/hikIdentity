object frmMain: TfrmMain
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  Caption = 'frmMain'
  ClientHeight = 448
  ClientWidth = 918
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Padding.Left = 4
  Padding.Top = 4
  Padding.Right = 4
  Padding.Bottom = 4
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 4
    Top = 4
    Width = 501
    Height = 440
    Align = alLeft
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 499
      Height = 72
      Align = alTop
      TabOrder = 0
      object btn_Start: TButton
        Left = 24
        Top = 24
        Width = 75
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #21551'    '#21160
        TabOrder = 0
        OnClick = btn_StartClick
      end
      object btn_CatchImg: TButton
        Left = 128
        Top = 24
        Width = 75
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #25235'    '#22270
        TabOrder = 1
      end
    end
    object pal_CameraArea: TPanel
      Left = 1
      Top = 73
      Width = 499
      Height = 366
      Align = alClient
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    Left = 505
    Top = 4
    Width = 409
    Height = 440
    Align = alClient
    TabOrder = 1
    object REditDebug: TRichEdit
      Left = 1
      Top = 177
      Width = 407
      Height = 262
      Align = alClient
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 407
      Height = 176
      Align = alTop
      TabOrder = 1
      object btn_IdReader: TButton
        Left = 16
        Top = 13
        Width = 75
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #36523#20221#35777#35835#21462
        TabOrder = 0
        OnClick = btn_IdReaderClick
      end
      object Panel5: TPanel
        Left = 160
        Top = 1
        Width = 246
        Height = 174
        Align = alRight
        TabOrder = 1
        object imgPhoto: TImage
          Left = 1
          Top = 1
          Width = 244
          Height = 172
          Align = alClient
          Stretch = True
          ExplicitLeft = 4
          ExplicitTop = 284
          ExplicitWidth = 361
          ExplicitHeight = 322
        end
      end
      object btn_BmpRead: TButton
        Left = 16
        Top = 61
        Width = 75
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #28608#27963#21345
        TabOrder = 2
        OnClick = btn_BmpReadClick
      end
    end
    object btn_Check: TButton
      Left = 16
      Top = 112
      Width = 75
      Height = 25
      Caption = #26816#27979#21345
      TabOrder = 2
      OnClick = btn_CheckClick
    end
  end
end
