unit MsgUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ImgList;

const
  mtInfo=0;
  mtWarn=1;

type
  TMsgForm = class(TForm)
    Timer: TTimer;
    ImageList: TImageList;
    MainPn: TPanel;
    Panel1: TPanel;
    CaptionLB: TLabel;
    TextLB: TLabel;
    Img: TImage;
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure MessageFormShow(msgtype:byte; capt,text : string; tm:byte=0);

implementation

{$R *.dfm}

procedure MessageFormShow(msgtype:byte; capt,text : string; tm:byte=0);
var
  MsgForm: TMsgForm;
begin
  MsgForm:=TMsgForm.Create(application);
  MsgForm.CaptionLB.Caption:=capt;
  MsgForm.TextLB.Caption:=text;
  if tm>0 then begin
    MsgForm.Timer.Interval:=tm*1000;
    MsgForm.Timer.Enabled:=true;
  end else MsgForm.Timer.Enabled:=false;
  case msgtype of
    mtInfo: begin
              MsgForm.ImageList.GetBitmap(0,MsgForm.Img.Picture.Bitmap);
              MsgForm.CaptionLB.Color:=clInactiveCaption;
            end;
    mtWarn: begin
              MsgForm.ImageList.GetBitmap(1,MsgForm.Img.Picture.Bitmap);
              MsgForm.CaptionLB.Color:=clRed;
            end;
  end;
  MsgForm.ShowModal;
end;

procedure TMsgForm.TimerTimer(Sender: TObject);
begin
  self.Close;
end;

end.
