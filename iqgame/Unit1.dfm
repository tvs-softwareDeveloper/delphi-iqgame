object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 651
  ClientWidth = 895
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object LabelTitle: TLabel
    Left = 328
    Top = 38
    Width = 236
    Height = 37
    Caption = 'Reactie en denk test'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object LabelInstruction: TLabel
    Left = 376
    Top = 232
    Width = 112
    Height = 15
    Caption = 'Druk op start broedar'
  end
  object LabelResult: TLabel
    Left = 418
    Top = 325
    Width = 3
    Height = 15
  end
  object Score: TLabel
    Left = 400
    Top = 160
    Width = 3
    Height = 15
  end
  object EditAnswer: TEdit
    Left = 376
    Top = 296
    Width = 121
    Height = 23
    TabOrder = 0
    Text = 'EditAnswer'
  end
  object ButtonSubmit: TButton
    Left = 512
    Top = 294
    Width = 75
    Height = 25
    Caption = 'Submit'
    TabOrder = 1
    OnClick = ButtonSubmitClick
  end
  object ButtonEven: TButton
    Left = 328
    Top = 400
    Width = 89
    Height = 33
    Caption = 'Even'
    TabOrder = 2
    OnClick = ButtonEvenClick
  end
  object ButtonOdd: TButton
    Left = 464
    Top = 400
    Width = 89
    Height = 33
    Caption = 'Odd'
    TabOrder = 3
    OnClick = ButtonOddClick
  end
  object ButtonStart: TButton
    Left = 400
    Top = 265
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 4
    OnClick = ButtonStartClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 376
    Top = 328
  end
end
