unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

const
  WM_NEXT_ROUND = WM_USER + 1;

type
  TTaskType = (ttReaction, ttMultiply, ttEvenOdd);
  TGameState = (gsIdle, gsWaitingGreen, gsReactionReady, gsGreenShowing, gsQuestionActive, gsResult);

  TForm1 = class(TForm)
    LabelTitle: TLabel;
    LabelInstruction: TLabel;
    LabelResult: TLabel;
    EditAnswer: TEdit;
    ButtonStart: TButton;
    ButtonSubmit: TButton;
    ButtonEven: TButton;
    ButtonOdd: TButton;
    Timer1: TTimer;
    Score: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ButtonSubmitClick(Sender: TObject);
    procedure ButtonEvenClick(Sender: TObject);
    procedure ButtonOddClick(Sender: TObject);
  private
    StartTime: TDateTime;
    State: TGameState;
    Task: TTaskType;
    Num1, Num2, CorrectAnswer: Integer;
    TotalScore: Integer;
    MaxPointsPerQuestion: Integer;
    procedure WMNextRound(var Msg: TMessage); message WM_NEXT_ROUND;

    procedure StyleForm;
    procedure HideAnswerControls;
    procedure StartRound;
    procedure EndRound(const IsCorrect: Boolean; const TimeTakenSec: Double; const ExtraMsg: string = '');
    function SecondsSince(const T0: TDateTime): Double;
    function PointsForTime(const TimeTakenSec: Double): Integer;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.StyleForm;
const
  ACCENT  : TColor = $00E8A020;
  FG      : TColor = clWhite;
  RESULT_GREEN : TColor = $0040D040;
begin
  Color  := $002B2B2B;
  Width  := 520;
  Height := 420;
  Caption := 'IQ Game';
  Position := poScreenCenter;

  LabelTitle.ParentColor    := False;
  LabelTitle.Transparent    := True;
  LabelTitle.Font.Name      := 'Segoe UI';
  LabelTitle.Font.Size      := 22;
  LabelTitle.Font.Style     := [fsBold];
  LabelTitle.Font.Color     := ACCENT;
  LabelTitle.Caption        := 'IQ Game';
  LabelTitle.AutoSize       := True;
  LabelTitle.Left           := 20;
  LabelTitle.Top            := 16;

  Score.ParentColor         := False;
  Score.Transparent         := True;
  Score.Font.Name           := 'Segoe UI';
  Score.Font.Size           := 13;
  Score.Font.Style          := [fsBold];
  Score.Font.Color          := ACCENT;
  Score.Caption             := 'Score: 0';
  Score.AutoSize            := True;
  Score.Left                := 360;
  Score.Top                 := 22;

  LabelInstruction.ParentColor := False;
  LabelInstruction.Transparent := True;
  LabelInstruction.Font.Name   := 'Segoe UI';
  LabelInstruction.Font.Size   := 16;
  LabelInstruction.Font.Color  := FG;
  LabelInstruction.AutoSize    := True;
  LabelInstruction.Left        := 20;
  LabelInstruction.Top         := 100;
  LabelInstruction.Caption     := 'Druk op Start om te beginnen.';

  LabelResult.ParentColor   := False;
  LabelResult.Transparent   := True;
  LabelResult.Font.Name     := 'Segoe UI';
  LabelResult.Font.Size     := 12;
  LabelResult.Font.Color    := RESULT_GREEN;
  LabelResult.AutoSize      := True;
  LabelResult.Left          := 20;
  LabelResult.Top           := 150;
  LabelResult.Caption       := '';

  EditAnswer.Font.Name := 'Segoe UI';
  EditAnswer.Font.Size := 14;
  EditAnswer.Width     := 120;
  EditAnswer.Height    := 36;
  EditAnswer.Left      := 20;
  EditAnswer.Top       := 200;

  ButtonStart.Font.Name  := 'Segoe UI';
  ButtonStart.Font.Size  := 12;
  ButtonStart.Font.Style := [fsBold];
  ButtonStart.Width      := 160;
  ButtonStart.Height     := 44;
  ButtonStart.Left       := 20;
  ButtonStart.Top        := 300;
  ButtonStart.Caption    := 'Start';

  ButtonSubmit.Font.Name := 'Segoe UI';
  ButtonSubmit.Font.Size := 12;
  ButtonSubmit.Width     := 120;
  ButtonSubmit.Height    := 36;
  ButtonSubmit.Left      := 160;
  ButtonSubmit.Top       := 200;
  ButtonSubmit.Caption   := 'Bevestig';

  ButtonEven.Font.Name  := 'Segoe UI';
  ButtonEven.Font.Size  := 12;
  ButtonEven.Width      := 120;
  ButtonEven.Height     := 44;
  ButtonEven.Left       := 20;
  ButtonEven.Top        := 200;
  ButtonEven.Caption    := 'Even';

  ButtonOdd.Font.Name  := 'Segoe UI';
  ButtonOdd.Font.Size  := 12;
  ButtonOdd.Width      := 120;
  ButtonOdd.Height     := 44;
  ButtonOdd.Left       := 160;
  ButtonOdd.Top        := 200;
  ButtonOdd.Caption    := 'Oneven';
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  Self.OnMouseDown := FormMouseDown;

  Timer1.Enabled := False;


  TotalScore := 0;
  MaxPointsPerQuestion := 10;
  State := gsIdle;

  StyleForm;
  HideAnswerControls;

  ButtonStart.Visible := True;
  ButtonStart.Caption := 'Start';
end;


procedure TForm1.HideAnswerControls;
begin
  EditAnswer.Visible  := False;
  ButtonSubmit.Visible := False;
  ButtonEven.Visible  := False;
  ButtonOdd.Visible   := False;
  EditAnswer.Text     := '';
end;

function TForm1.SecondsSince(const T0: TDateTime): Double;
begin
  Result := (Now - T0) * 86400;
end;

function TForm1.PointsForTime(const TimeTakenSec: Double): Integer;
begin
  Result := MaxPointsPerQuestion - Trunc(TimeTakenSec);
  if Result < 0 then Result := 0;
end;

// gamefloeq

procedure TForm1.StartRound;
var
  Mode: Integer;
begin
  LabelResult.Caption := '';
  HideAnswerControls;
  ButtonStart.Visible := False;
  Color := $002B2B2B;

  Mode := Random(3);
  case Mode of
    0: Task := ttReaction;
    1: Task := ttMultiply;
  else
    Task := ttEvenOdd;
  end;

  case Task of
    ttReaction:
      begin
        State := gsWaitingGreen;
        Color := $000000CC;
        LabelInstruction.Caption := 'Reaction test — wacht op GROEN, dan klikken!';
        LabelResult.Caption := '';
        Timer1.Interval := Random(1200) + 500;
        Timer1.Enabled  := True;
      end;

    ttMultiply:
      begin
        State := gsQuestionActive;
        Num1 := Random(10);
        Num2 := Random(10);
        CorrectAnswer := Num1 * Num2;
        LabelInstruction.Caption := Format('🔢%d  ×  %d  = ?', [Num1, Num2]);
        EditAnswer.Visible  := True;
        ButtonSubmit.Visible := True;
        EditAnswer.SetFocus;
        StartTime := Now;
      end;

    ttEvenOdd:
      begin
        State := gsQuestionActive;
        Num1 := Random(100);
        LabelInstruction.Caption := Format('🔍Is  %d  even of oneven?', [Num1]);
        ButtonEven.Visible := True;
        ButtonOdd.Visible  := True;
        StartTime := Now;
      end;
  end;
end;

procedure TForm1.EndRound(const IsCorrect: Boolean; const TimeTakenSec: Double; const ExtraMsg: string);
var
  Earned: Integer;
  TimeStr: string;
begin
  Timer1.Enabled := False;
  HideAnswerControls;
  Color := $002B2B2B;

  if TimeTakenSec >= 0 then
    TimeStr := FormatFloat('0.00', TimeTakenSec) + 's'
  else
    TimeStr := '-';

  if IsCorrect then
  begin
    Earned := PointsForTime(TimeTakenSec);
    TotalScore := TotalScore + Earned;
    Score.Caption := 'Score: ' + TotalScore.ToString;
    LabelResult.Font.Color := $0040D040;
    LabelResult.Caption := Format('✅Goed!  Tijd: %s  |  +%d punten', [TimeStr, Earned]);
  end
  else
  begin
    LabelResult.Font.Color := $000040E0;
    if ExtraMsg <> '' then
      LabelResult.Caption := '❌Fout jongeh!  ' + ExtraMsg
    else
      LabelResult.Caption := '❌Fout!';
  end;

  State := gsResult;

  Application.ProcessMessages;
  PostMessage(Handle, WM_NEXT_ROUND, 0, 0);
end;



procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if Task <> ttReaction then Exit;

  if State = gsWaitingGreen then
  begin
    State := gsGreenShowing;
    Color := $0020A020;
    LabelInstruction.Caption := 'KLIK NU!';
    LabelResult.Caption := '';
    StartTime := Now;
    Timer1.Interval := 100 + Random(400);
    Timer1.Enabled  := True;
  end
  else if State = gsGreenShowing then
  begin
    State := gsWaitingGreen;
    Color := $000000CC;
    LabelInstruction.Caption := 'Reaction test — wacht op GROEN, dan klikken!';
    LabelResult.Font.Color := $000040E0;
    StartTime := Now;
    LabelResult.Caption := 'Te laat! Wacht opnieuw op groen...';
    Timer1.Interval := Random(2000) + 1000;
    Timer1.Enabled  := True;
  end;
end;

procedure TForm1.WMNextRound(var Msg: TMessage);
var
  i: Integer;
begin
  // 1.5 sec wachten zonder ui te blokkeren
  for i := 1 to 30 do
  begin
    Sleep(50);
    Application.ProcessMessages;  //scherm hertekenen
  end;
  if State = gsResult then
    StartRound;
end;


procedure TForm1.ButtonStartClick(Sender: TObject);
begin
  if State in [gsIdle, gsResult] then
    StartRound;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TimeTaken: Double;
begin
  if Task <> ttReaction then Exit;

  case State of
    gsWaitingGreen:
      begin
        Timer1.Enabled := False;
        LabelResult.Font.Color := $000040E0;
        LabelResult.Caption := '❌ Te vroeg! Wacht op groen...';
        Color := $000000CC;
        LabelInstruction.Caption := 'Reaction test — wacht op GROEN, dan klikken!';
        Timer1.Interval := Random(2000) + 1000;
        Timer1.Enabled  := True;
      end;

    gsGreenShowing:
      begin
        Timer1.Enabled := False;
        TimeTaken := SecondsSince(StartTime);
        EndRound(True, TimeTaken);
      end;
  end;
end;

procedure TForm1.ButtonSubmitClick(Sender: TObject);
var
  Answer: Integer;
  TimeTaken: Double;
begin
  if (Task <> ttMultiply) or (State <> gsQuestionActive) then Exit;

  if not TryStrToInt(EditAnswer.Text, Answer) then
  begin
    LabelResult.Caption := 'Vul een geldig getal in.';
    Exit;
  end;

  TimeTaken := SecondsSince(StartTime);

  if Answer = CorrectAnswer then
    EndRound(True, TimeTaken)
  else
    EndRound(False, TimeTaken, Format('Juist antwoord was %d.', [CorrectAnswer]));
end;

procedure TForm1.ButtonEvenClick(Sender: TObject);
var
  TimeTaken: Double;
begin
  if (Task <> ttEvenOdd) or (State <> gsQuestionActive) then Exit;
  TimeTaken := SecondsSince(StartTime);

  if Num1 mod 2 = 0 then
    EndRound(True, TimeTaken)
  else
    EndRound(False, TimeTaken, 'Dit getal is oneven, wist je dat niet ofzo.');
end;

procedure TForm1.ButtonOddClick(Sender: TObject);
var
  TimeTaken: Double;
begin
  if (Task <> ttEvenOdd) or (State <> gsQuestionActive) then Exit;
  TimeTaken := SecondsSince(StartTime);

  if Num1 mod 2 <> 0 then
    EndRound(True, TimeTaken)
  else
    EndRound(False, TimeTaken, 'Dit getal is even, basiskennis he.');
end;

end.
