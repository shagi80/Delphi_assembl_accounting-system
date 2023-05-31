unit DiagramClass;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TRectanglesData = record
    TopStrRct, ColumnRCt, BtmStr1Rct,BtmStr2Rct : Trect;
    TopStrFnt,BtmStrFnt : integer;
  end;

  TColumnValues = record
    Btm1Str,Btm2Str : string;
    Val1,Val2,Val3  : integer;
    Bonus           : real;
  end;

  TDiagram = class (TPaintBox)
  private
    FrstLeft,
    FrstTop     : integer;
    FColCount   : integer;
    FMaxVal     : integer;
    FLineHght   : integer;
    FValMst     : real;
    FColWidth   : integer;
    FColHeight  : integer;
    FCurColInd  : integer;
    FRectangles : TRectanglesData;
    FVal1Color,
    FVal2Color,
    FVal3Color  : TColor;
    FColumnVal  : array of TColumnValues;
    FBadSpeed,
    FMdlSpeed,
    FNrmSpeed   : real;
    FBevProc    : real;
    FCurSpeed   : real;
    procedure PaintColumn(i:integer);
    procedure Paint(sender : TObject); reintroduce;
    function  SetFontSize(txt:string;wdth,hght:integer):integer;
    procedure CalcRectangle;
  public
    { Public declarations }
    property Bevel:real read FBevProc write FBevProc;
    property CurColInd:integer read FCurColInd write FCurColInd;
    property CurSpeed:real read FCurSpeed write FCurSpeed;
    property Val1Color:TColor read FVal1Color write FVal1Color;
    property Val2Color:TColor read FVal2Color write FVal2Color;
    property Val3Color:TColor read FVal3Color write FVal3Color;
    property BadSpeed:real read FBadSpeed write FBadSpeed;
    property MdlSpeed:real read FMdlSpeed write FMdlSpeed;
    property NrmSpeed:real read FNrmSpeed write FNrmSpeed;
    constructor Create(AOwner:TComponent); reintroduce;
    destructor  Destroy;override;
    procedure   AddColumn(BtmStr1,BtmStr2:string;val1,val2,val3:integer);
    procedure   ChangeValue(col,valnum,val : integer);
    procedure   ChangeBonus(col:integer; val : real);
  end;

  THorDiagram = class (TPaintBox)
  private
    FBevProc    : real;
    FMaxVal     : integer;
    FLineWdth   : integer;
    FValMst     : real;
    FVal1Color,
    FVal2Color,
    FVal3Color  : TColor;
    FVal1,
    FVal2,
    FVal3,
    FBonus      : Integer;
    FBadSpeed,
    FMdlSpeed,
    FNrmSpeed   : real;
    procedure MyPaint(sender : TObject);
    function  SetFontSize(txt:string;wdth,hght:integer):integer;
  public
    { Public declarations }
    property Bevel:real read FBevProc write FBevProc;
    property Val1Color:TColor read FVal1Color write FVal1Color;
    property Val2Color:TColor read FVal2Color write FVal2Color;
    property Val3Color:TColor read FVal3Color write FVal3Color;
    property BadSpeed:real read FBadSpeed write FBadSpeed;
    property MdlSpeed:real read FMdlSpeed write FMdlSpeed;
    property NrmSpeed:real read FNrmSpeed write FNrmSpeed;
    property Bonus:integer read FBonus write FBonus;
    constructor Create(AOwner:TComponent);override;
    destructor  Destroy;override;
    procedure   SetValue(val1,val2,val3:integer);
  end;


implementation

//----------------------- Вертикальная диаграмма -------------------------------

constructor TDiagram.Create(AOwner:TComponent);
begin
  inherited;
  self.OnPaint :=self.Paint;
  self.FBevProc:=0.2;
  self.FColCount:=0;
  SetLength(self.FColumnVal,self.FColCount);
  self.FCurColInd:=-1;
  self.FCurSpeed:=MaxInt;
end;

destructor TDiagram.Destroy;
begin
  inherited;
end;

function TDiagram.SetFontSize(txt:string;wdth,hght:integer):integer;
var
  ws,hs,old : integer;
begin
  hs:=maxint;
  ws:=maxint;
  old:=self.Canvas.Font.Size;
  wdth:=wdth-4;
  if wdth>0 then
    begin
      self.Canvas.Font.Size:=6;
      while(self.Canvas.TextWidth(txt)<wdth)do self.Canvas.Font.Size:=self.Canvas.Font.Size+1;
      ws:=self.Canvas.Font.Size-1;
    end;
  hght:=hght-4;
  if hght>0 then
    begin
      self.Canvas.Font.Size:=6;
      while(self.Canvas.TextHeight(txt)<hght)do self.Canvas.Font.Size:=self.Canvas.Font.Size+1;
      hs:=self.Canvas.Font.Size-1;
    end;
  self.Canvas.Font.Size:=old;
  if(ws>=hs)then result:=hs else result:=ws;
end;

procedure TDiagram.CalcRectangle;
const
  TopStrMask='000';
  BtmStrMask='00:00';
var
  rct : TRect;
begin
  if self.FBevProc<0.2 then self.FBevProc:=0.2;
  //Расчет высоты и ширины столбцов
  self.FColHeight:=round(self.ClientHeight*0.9);
  self.FColWidth:=round(self.Width*0.9/self.FColCount);
  //Прямоугольник второй нижней сточки
  rct:=Rect(0,0,self.FColWidth-round(self.FColWidth*0.1),self.FColHeight);
  self.FRectangles.BtmStrFnt:=self.SetFontSize(BtmStrMask,(rct.Right-rct.Left),0);
  self.Canvas.Font.Size:=self.FRectangles.BtmStrFnt;
  DrawText(self.Canvas.Handle,PChar(bTMStrMask),length(bTMStrMask),
    self.FRectangles.BtmStr2Rct,DT_CALCRECT);
  self.FRectangles.BtmStr2Rct.Left:=rct.Left;
  self.FRectangles.BtmStr2Rct.Right:=rct.Right;
  self.FRectangles.BtmStr2Rct.Top:=rct.Bottom-(self.FRectangles.BtmStr2Rct.Bottom-
  self.FRectangles.BtmStr2Rct.Top);
  self.FRectangles.BtmStr2Rct.Bottom:=rct.Bottom;
  //Прямоугольник 1ой нижней строчки
  self.FRectangles.BtmStr1Rct.Left:=rct.Left;
  self.FRectangles.BtmStr1Rct.Right:=rct.Right;
  self.FRectangles.BtmStr1Rct.Bottom:=self.FRectangles.BtmStr2Rct.Top-
    round((self.FRectangles.BtmStr2Rct.Bottom-self.FRectangles.BtmStr2Rct.Top)*0);
  self.FRectangles.BtmStr1Rct.Top:=self.FRectangles.BtmStr1Rct.Bottom-
    (self.FRectangles.BtmStr2Rct.Bottom-self.FRectangles.BtmStr2Rct.Top);
  //Прямоугольник максимально верхней подписи столбца
  rct:=Rect(0,0,self.FColWidth-round(self.FColWidth*self.FBevProc),self.FColHeight);
  self.FRectangles.TopStrFnt:=self.SetFontSize(TopStrMask,(rct.Right-rct.Left),0);
  self.Canvas.Font.Size:=self.FRectangles.TopStrFnt;
  DrawText(self.Canvas.Handle,PChar(TopStrMask),length(TopStrMask),
    self.FRectangles.TopStrRct,DT_CALCRECT);
  self.FRectangles.TopStrRct.Left:=rct.Left;
  self.FRectangles.TopStrRct.Right:=rct.Right;
  self.FRectangles.TopStrRct.Bottom:=rct.Top+(self.FRectangles.TopStrRct.Bottom-
        self.FRectangles.TopStrRct.Top);
  self.FRectangles.TopStrRct.Top:=rct.Top;
  // Прямоугольник самого столбца
  self.FRectangles.ColumnRCt.Left:=rct.Left;
  self.FRectangles.ColumnRCt.Right:=rct.Right;
  self.FRectangles.ColumnRCt.Top:=self.FRectangles.TopStrRct.Bottom+
    round((self.FRectangles.TopStrRct.Bottom-self.FRectangles.TopStrRct.Top)*0.1);
  self.FRectangles.ColumnRct.Bottom:=self.FRectangles.BtmStr1Rct.Top-
    round((self.FRectangles.BtmStr1Rct.Bottom-self.FRectangles.BtmStr1Rct.Top)*0.5);
  //Рассчет ширины единичной линии в столбце и коэф масштабирования значений
  if (self.FMaxVal<((self.FRectangles.ColumnRCt.Bottom-self.FRectangles.ColumnRCt.Top)/3))
    and(self.FMaxVal>0) then
    begin
      self.FLineHght:=trunc((self.FRectangles.ColumnRCt.Bottom-self.FRectangles.ColumnRCt.Top)/(self.FMaxVal*1.5));
      self.FValMst:=1;
    end else
    begin
      self.FLineHght:=2;
      self.FValMst:=trunc((self.FMaxVal*3)/(self.FRectangles.ColumnRCt.Bottom-self.FRectangles.ColumnRCt.Top));
      self.FValMst:=self.FValMst+1;
    end;
end;

procedure TDiagram.Paint(sender: TObject);
var
  i   : integer;
begin
  self.Perform(WM_SETREDRAW, 0, 0);
  //Задание базовых прямоугольников
  self.CalcRectangle;
  //Вывод столбцов
  for I := 0 to self.FColCount - 1 do self.PaintColumn(i);
  self.Perform(WM_SETREDRAW, 1, 0);
end;

procedure TDiagram.PaintColumn(i:integer);
var
  str           : string;
  j,LnBev,LnTop : integer;
  BCol,PCol,FCol: TColor;
  Str2Rct, rct  : TRect;
  Speed         : real;
begin
  if self.FValMst=0 then self.CalcRectangle;
  LnTop:=0;
  if self.FBevProc<0.2 then self.FBevProc:=0.2;
  //Центнировка по горизонтале и вертикале
  FrstLeft:=round((self.Width-self.FColCount*self.FColWidth)/2);
  FrstTop :=round((self.Height-self.FColHeight)/2);
  //Закрашивание области
  rct.Left:=FrstLeft+i*self.FColWidth;
  rct.Right:=FrstLeft+(i+1)*self.FColWidth;
  rct.Top:=0;
  rct.Bottom:=self.Height;
  self.Canvas.Rectangle(rct);
  //Запоминаем параметры кисти
  BCol:=self.Canvas.Brush.Color;
  PCol:=self.Canvas.Pen.Color;
  FCol:=self.Canvas.Font.Color;
  //Вывод подписи столбцоы
  self.Canvas.Font.Size:=self.FRectangles.BtmStrFnt;
  if i<>self.FCurColInd then self.Canvas.Font.Color:=clSilver
    else self.Canvas.Font.Color:=clWhite;
  rct:=self.FRectangles.BtmStr1Rct;
  rct.Left:=rct.Left+FrstLeft+i*self.FColWidth+round(self.FColWidth*0.05);
  rct.Top:=rct.Top+FrstTop;
  rct.Right:=rct.Left+rct.Right;
  rct.Bottom:=rct.Bottom+FrstTop;
  //
  self.Canvas.Font.Size:=self.SetFontSize(self.FColumnVal[i].Btm1Str,(rct.Right-rct.Left),0);
  //
  DrawText(self.Canvas.Handle,PChar(self.FColumnVal[i].Btm1Str),length(self.FColumnVal[i].Btm1Str),rct,DT_CENTER);
  rct:=self.FRectangles.BtmStr2Rct;
  rct.Left:=rct.Left+FrstLeft+i*self.FColWidth+round(self.FColWidth*0.05);
  rct.Top:=rct.Top+FrstTop;
  rct.Right:=rct.Left+rct.Right;
  rct.Bottom:=rct.Bottom+FrstTop;
  DrawText(self.Canvas.Handle,PChar(self.FColumnVal[i].Btm2Str),length(self.FColumnVal[i].Btm2Str),rct,DT_CENTER);
  //Линя горизонтальной оси
  self.Canvas.Pen.Color:=clSilver;
  self.Canvas.Pen.Width:=3;
  self.Canvas.MoveTo(FrstLeft,self.FRectangles.ColumnRct.Bottom+FrstTop+self.FLineHght);
  self.Canvas.LineTo(self.Width-FrstLeft,self.FRectangles.ColumnRct.Bottom+FrstTop+self.FLineHght);
  self.Canvas.Pen.Width:=1;
  LnBev:=trunc(self.FLineHght/2);
  //Значение 1
  rct:=self.FRectangles.ColumnRct;
  rct.Left:=rct.Left+FrstLeft+i*self.FColWidth+round(self.FColWidth*self.FBevProc/2);
  rct.Top:=rct.Top+FrstTop;
  rct.Right:=rct.Left+rct.Right;
  rct.Bottom:=rct.Bottom+FrstTop;
  //if (self.FColumnVal[i].Val1=0)then self.FColumnVal[i].Val1:=self.FColumnVal[i].Val2;
  if (self.FColumnVal[i].Val1>0)and(self.FColumnVal[i].Val1>self.FColumnVal[i].Val2) then
    begin
      if i<>self.FCurColInd then
        begin
          self.Canvas.Font.Color:=self.FVal1Color;
          self.Canvas.Brush.Color:=self.FVal1Color;
          self.Canvas.Pen.Color:=self.FVal1Color;
        end
        else
          begin
            self.Canvas.Font.Color:=clWhite;
            self.Canvas.Brush.Color:=clWhite;
            self.Canvas.Pen.Color:=clWhite;
          end;
      for j := 0 to trunc(self.FColumnVal[i].Val1/self.FValMst) - 1 do
        begin
          LnTop:=rct.Bottom-self.FLineHght*(j+1)-trunc(LnBev*j);
          self.Canvas.Rectangle(rct.Left,LnTop,rct.Right,LnTop+self.FLineHght);
        end;
      self.Canvas.Font.Size:=self.FRectangles.TopStrFnt;
      rct.Bottom:=LnTop;
      rct.Top:=rct.Bottom-(self.FRectangles.TopStrRct.Bottom-self.FRectangles.TopStrRct.Top);
      str:=inttostr(self.FColumnVal[i].Val1);
      self.Canvas.Brush.Color:=BCol;
      //
      self.Canvas.Font.Size:=self.SetFontSize(Str,(rct.Right-rct.Left),(rct.Bottom-rct.Top));
      //
      DrawText(self.Canvas.Handle,PChar(str),length(str),rct,DT_CENTER);
    end;
  //Значение 2 (только прямоугольники)
  rct:=self.FRectangles.ColumnRCt;
  rct.Left:=rct.Left+FrstLeft+i*self.FColWidth+round(self.FColWidth*self.FBevProc/2);
  rct.Top:=rct.Top+FrstTop;
  rct.Right:=rct.Left+rct.Right;
  rct.Bottom:=rct.Bottom+FrstTop;
  if self.FColumnVal[i].Val2>0 then
    begin
      self.Canvas.Pen.Color:=self.FVal2Color;
      self.Canvas.Brush.Color:=self.FVal2Color;
      for j := 0 to trunc(self.FColumnVal[i].Val2/self.FValMst) - 1 do
        begin
          LnTop:=rct.Bottom-self.FLineHght*(j+1)-trunc(LnBev*j);
          self.Canvas.Rectangle(rct.Left,LnTop,rct.Right,LnTop+self.FLineHght);
        end;
      rct.Bottom:=LnTop+round((self.FRectangles.TopStrRct.Bottom-self.FRectangles.TopStrRct.Top)/2);
      rct.Top:=rct.Bottom-(self.FRectangles.TopStrRct.Bottom-self.FRectangles.TopStrRct.Top);
      Str2Rct:=rct;
    end;
  //Значение 3
  rct:=self.FRectangles.ColumnRCt;
  rct.Left:=rct.Left+FrstLeft+i*self.FColWidth+round(self.FColWidth*self.FBevProc/2);
  rct.Top:=rct.Top+FrstTop;
  rct.Right:=rct.Left+rct.Right;
  rct.Bottom:=rct.Bottom+FrstTop;
  if self.FColumnVal[i].Val3>0 then
    begin
      self.Canvas.Pen.Color:=self.FVal3Color;
      self.Canvas.Brush.Color:=self.FVal3Color;
      for j := 0 to trunc(self.FColumnVal[i].Val3/self.FValMst) - 1 do
        begin
          LnTop:=rct.Bottom-self.FLineHght*(j+1)-trunc(LnBev*j);
          self.Canvas.Rectangle(rct.Left,LnTop,rct.Right,LnTop+self.FLineHght);
        end;
      self.Canvas.Font.Size:=self.FRectangles.TopStrFnt;
      rct.Bottom:=LnTop;
      rct.Top:=rct.Bottom-(self.FRectangles.TopStrRct.Bottom-self.FRectangles.TopStrRct.Top);
      str:=inttostr(self.FColumnVal[i].Val3);
      self.Canvas.Brush.Style:=bsClear;
      self.Canvas.Font.Color:=self.FVal3Color;
      self.Canvas.Font.Style:=[fsBold];
      DrawText(self.Canvas.Handle,PChar(str),length(str),rct,DT_CENTER);
      self.Canvas.Brush.Style:=bsSolid;
      self.Canvas.Font.Style:=[];
    end;
  //Вывод количество по 2-му столбцу (факт собранно)
  if self.FColumnVal[i].Val2>0 then
    begin
      Str2Rct.Right:=(Str2Rct.Right-Str2Rct.Left);
      Str2Rct.Left:=Str2Rct.Left-round(Str2Rct.Right*0.1);
      Str2Rct.Right:=Str2Rct.Left+round(Str2Rct.Right*1.2);
      Str2Rct.Top:=Str2Rct.Top-round((Str2Rct.Right-Str2Rct.Left)/2);
      Str2Rct.Bottom:=Str2Rct.Top+(Str2Rct.Right-Str2Rct.Left);
      self.Canvas.Pen.Width:=3;
      self.Canvas.Pen.Color:=self.FVal2Color;
      if self.FColumnVal[i].Val1>0 then
        begin
          //если это не текущий столбец определям скорость ьотностельно плана
          //если текущий - береме скорость из свойства "текущая скорость"
          if i<>self.FCurColInd then Speed:=self.FColumnVal[i].Val2/self.FColumnVal[i].Val1
            else Speed:=self.FCurSpeed;
          if Speed<=self.FBadSpeed then self.Canvas.Brush.Color:=clRed;
          if (Speed<=self.FMdlSpeed)and(Speed>self.FBadSpeed) then self.Canvas.Brush.Color:=clYellow;
          if (Speed<=self.FNrmSpeed)and(Speed>self.FMdlSpeed) then self.Canvas.Brush.Color:=clAqua;
          if (Speed>self.FNrmSpeed) then self.Canvas.Brush.Color:=clLime;
        end else self.Canvas.Brush.Color:=clWhite;
      self.Canvas.Ellipse(Str2Rct);
      self.Canvas.Pen.Width:=1;
      str:=inttostr(self.FColumnVal[i].Val2);
      self.Canvas.Font.Style:=[fsBold];
      self.Canvas.Font.Color:=clBlack;
      self.Canvas.Brush.Style:=bsClear;
      DrawText(self.Canvas.Handle,PChar(str),length(str),Str2Rct,(DT_SINGLELINE OR DT_VCENTER OR DT_CENTER));
      j:=(Str2rct.Top-Str2rct.Bottom);
      //вывод значения "бонуса"
      if self.FColumnVal[i].Bonus<>0 then begin
        self.Canvas.Font.Color:=clFuchsia;
        Str2Rct.Top:=Str2rct.Top+round(j*0.65);
        Str2Rct.Bottom:=Str2rct.Bottom+round(j*0.65);
        str:=FormatFloat('##0.##',self.FColumnVal[i].Bonus);
        if self.FColumnVal[i].Bonus>0 then str:='+'+str;        
        j:=DrawText(self.Canvas.Handle,PChar(str),length(str),Str2Rct,(DT_SINGLELINE OR DT_VCENTER OR DT_CENTER));
        Str2Rct.Top:=Str2rct.Top+round(j*0.75);
        self.Canvas.Font.Size:=round(self.Canvas.Font.Size*0.5);
        str:='рублей';
        DrawText(self.Canvas.Handle,PChar(str),length(str),Str2Rct,(DT_SINGLELINE OR DT_VCENTER OR DT_CENTER));
      end;
    end;
  // Восстановление цветов и стилей
  self.Canvas.Font.Style:=[];
  self.Canvas.Brush.Color:=BCol;
  self.Canvas.Pen.Color:=PCol;
  self.Canvas.Font.Color:=FCol;
end;

procedure TDiagram.AddColumn(BtmStr1,BtmStr2:string;val1,val2,val3:integer);
var
  max,i : integer;
begin
  inc(self.FColCount);
  SetLength(self.FColumnVal,self.FColCount);
  self.FColumnVal[self.FColCount-1].Btm1Str:=BtmStr1;
  self.FColumnVal[self.FColCount-1].Btm2Str:=BtmStr2;
  self.FColumnVal[self.FColCount-1].Val1:=val1;
  self.FColumnVal[self.FColCount-1].Val2:=val2;
  self.FColumnVal[self.FColCount-1].Val3:=val3;
  //Уст-ка максимального значенеия
  max:=0;
  for i := 0 to self.FColCount - 1 do
    begin
      if self.FColumnVal[i].Val1>max then max:=self.FColumnVal[i].Val1;
      if self.FColumnVal[i].Val2>max then max:=self.FColumnVal[i].Val2;
      if self.FColumnVal[i].Val3>max then max:=self.FColumnVal[i].Val3;
    end;
  self.FMaxVal:=max;
end;

procedure TDiagram.ChangeValue(col,valnum,val : integer);
var
  max,i : integer;
begin
  if(col<self.FColCount)then
    if (valnum=1)and(self.FColumnVal[col].Val1<>val) then self.FColumnVal[col].Val1:=val
      else if (valnum=2)and(self.FColumnVal[col].Val2<>val) then self.FColumnVal[col].Val2:=val
        else if (valnum=3)and(self.FColumnVal[col].Val3<>val) then self.FColumnVal[col].Val3:=val
          else exit;
  //Контроль максимальнго значения
  max:=0;
  for i := 0 to self.FColCount - 1 do
    begin
      if self.FColumnVal[i].Val1>max then max:=self.FColumnVal[i].Val1;
      if self.FColumnVal[i].Val2>max then max:=self.FColumnVal[i].Val2;
      if self.FColumnVal[i].Val3>max then max:=self.FColumnVal[i].Val3;
    end;
  if (max>self.FMaxVal)or(col=(self.FColCount - 1)) then begin
      self.FMaxVal:=max;
      self.Repaint;
    end else self.PaintColumn(col);
end;

procedure TDiagram.ChangeBonus(col:integer;val : real);
begin
  self.FColumnVal[col].Bonus:=val;
end;

//-------------------- Горизонтральная диаграмма -------------------------------

constructor THorDiagram.Create(AOwner:TComponent);
begin
  inherited;
  self.OnPaint :=self.MyPaint;
  self.FBevProc:=0;
  self.FVal1Color:=clSilver;
  self.FVal2Color:=clGreen;
  self.FVal3Color:=clRed;
  self.FBadSpeed:=0.3;
  self.FMdlSpeed:=0.6;
  self.FNrmSpeed:=0.8;
end;

destructor THorDiagram.Destroy;
begin
  inherited;
end;

function THorDiagram.SetFontSize(txt:string;wdth,hght:integer):integer;
var
  ws,hs,old : integer;
begin
  hs:=maxint;
  ws:=maxint;
  old:=self.Canvas.Font.Size;
  wdth:=wdth-4;
  if wdth>0 then
    begin
      self.Canvas.Font.Size:=6;
      while(self.Canvas.TextWidth(txt)<wdth)do self.Canvas.Font.Size:=self.Canvas.Font.Size+1;
      ws:=self.Canvas.Font.Size-1;
    end;
  hght:=hght-4;
  if hght>0 then
    begin
      self.Canvas.Font.Size:=6;
      while(self.Canvas.TextHeight(txt)<hght)do self.Canvas.Font.Size:=self.Canvas.Font.Size+1;
      hs:=self.Canvas.Font.Size-1;
    end;
  self.Canvas.Font.Size:=old;
  if(ws>=hs)then result:=hs else result:=ws;
end;

procedure THorDiagram.MyPaint(sender: TObject);
const
  StrMask='000';
  BaseBevel=0.1;
var
  BCol,PCol,FCol : TColor;
  rct, Str2Rct,
  ClntRct        : Trect;
  i,Wdth,
  LnLeft, LnBev  : integer;
  str            : string;
  Speed          : real;
begin
  if self.FBevProc<0.1 then self.FBevProc:=0.1;
  //Задание рабочей области
  ClntRct.Left:=round(self.ClientWidth*BaseBevel/1.5);
  ClntRct.Top:=round(self.ClientHeight*BaseBevel);
  ClntRct.Right:=self.ClientWidth-round(self.ClientWidth*BaseBevel*1.5);
  ClntRct.Bottom:=self.ClientHeight-round(self.ClientHeight*BaseBevel);
  //Если первое значени (план) равно 0 - ничего не рисуем
  if self.FVal1=0 then begin
    self.Canvas.Rectangle(ClntRct);
    str:='данных о производстве нет';
    self.Canvas.Font.Size:=14;
    self.Canvas.Font.Style:=[fsBold];
    DrawText(self.Canvas.Handle,PChar(str),length(str),ClntRct,
        (DT_WORDBREAK OR DT_CENTER));
    exit;
  end;
  //Задание высоты диаграммы и размера шрифта
  rct.Top:=ClntRct.Top+round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc);
  rct.Bottom:=ClntRct.Bottom-round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc);
  self.Canvas.Font.Size:=self.SetFontSize(StrMask,0,(Rct.Bottom-Rct.Top));
  //Запоминаем параметры цветов
  BCol:=self.Canvas.Brush.Color;
  PCol:=self.Canvas.Pen.Color;
  FCol:=self.Canvas.Font.Color;
  //Закрашываем рабочую область
  self.Canvas.Rectangle(clntrct);
  LnBev:=trunc(self.FLineWdth/2);
  self.Canvas.Brush.Style:=bsSolid;
  //Рассчет ширины единичной линии и коэф масштабирования значений
  Wdth:=ClntRct.Right-ClntRct.Left;
  self.FMaxVal:=0;
  if self.FVal1>self.FMaxVal then self.FMaxVal:=self.FVal1;
  if self.FVal2>self.FMaxVal then self.FMaxVal:=self.FVal2;
  if self.FVal3>self.FMaxVal then self.FMaxVal:=self.FVal3;
  if self.FMaxVal<(wdth/3) then
    begin
      self.FLineWdth:=trunc(wdth/(self.FMaxVal*1.5));
      self.FValMst:=1;
    end else
    begin
      self.FLineWdth:=2;
      self.FValMst:=trunc((self.FMaxVal*3)/wdth);
      self.FValMst:=self.FValMst+1;
    end;
  //Значение 1
  if (self.FVal1>0) then
    begin
      self.Canvas.Pen.Color:=self.FVal1Color;
      self.Canvas.Brush.Color:=self.FVal1Color;
      self.Canvas.Font.Color:=self.FVal1Color;
      self.Canvas.Font.Style:=[fsBold];
      LnLeft:=0;
      for i := 0 to trunc(self.FVal1/self.FValMst) - 1 do
        begin
          LnLeft:=ClntRct.Left+i*(self.FLineWdth+LnBev);
          self.Canvas.Rectangle(Lnleft,ClntRct.Top+round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc),
            Lnleft+self.FLineWdth,ClntRct.Bottom-round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc));
        end;
      str:=inttostr(self.FVal1);
      rct.Left:=Lnleft+self.FLineWdth*2;
      rct.Right:=rct.Left+self.Canvas.TextWidth(Str);
      self.Canvas.Brush.Style:=bsClear;
      DrawText(self.Canvas.Handle,PChar(str),length(str),Rct,
        (DT_SINGLELINE OR DT_VCENTER OR DT_Left));
      self.Canvas.Brush.Style:=bsSolid;
    end;
  //Значение 2 - без текста
  if self.FVal2>0 then
    begin
      self.Canvas.Pen.Color:=self.FVal2Color;
      self.Canvas.Brush.Color:=self.FVal2Color;
      LnLeft:=ClntRct.Left;
      for i := 0 to trunc(self.FVal2/self.FValMst) - 1 do
        begin
          LnLeft:=ClntRct.Left+i*(self.FLineWdth+LnBev);
          self.Canvas.Rectangle(Lnleft,ClntRct.Top+round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc),
            Lnleft+self.FLineWdth,ClntRct.Bottom-round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc));
        end;
      str:=inttostr(self.FVal2);
      Str2rct.Left:=Lnleft+self.FLineWdth*2-round(self.Canvas.TextWidth(StrMask)/2);
      Str2rct.Right:=Str2rct.Left+self.Canvas.TextWidth(StrMask);
    end;
  //Значение 3
  if self.FVal3>0 then
    begin
      self.Canvas.Pen.Color:=self.FVal3Color;
      self.Canvas.Brush.Color:=self.FVal3Color;
      self.Canvas.Font.Color:=self.FVal3Color;
      LnLeft:=0;
      for i := 0 to trunc(self.FVal3/self.FValMst) - 1 do
        begin
          LnLeft:=ClntRct.Left+i*(self.FLineWdth+LnBev);
          self.Canvas.Rectangle(Lnleft,ClntRct.Top+round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc),
            Lnleft+self.FLineWdth,ClntRct.Bottom-round((ClntRct.Bottom-ClntRct.Top)*self.FBevProc));
        end;
      str:=inttostr(self.FVal3);
      rct.Left:=Lnleft+self.FLineWdth*2;
      rct.Right:=rct.Left+self.Canvas.TextWidth(Str);
      self.Canvas.Brush.Style:=bsClear;
      DrawText(self.Canvas.Handle,PChar(str),length(str),Rct,
        (DT_SINGLELINE OR DT_VCENTER OR DT_Left));
      self.Canvas.Brush.Style:=bsSolid;
    end;

  if self.FVal2>0 then
    begin
      if round((Str2Rct.Right-Str2Rct.Left)*1.2)<(ClntRct.Bottom-ClntRct.Top) then
        begin
          wdth:=Str2Rct.Right-Str2Rct.Left;
          Str2Rct.Left:=Str2Rct.Left-round(wdth*0.1);
          Str2Rct.Right:=Str2Rct.Right+round(wdth*0.1);
          wdth:=ClntRct.Top+round((ClntRct.Bottom-ClntRct.Top)/2);
          Str2Rct.Top:=wdth-round((Str2Rct.Right-Str2Rct.Left)/2);
          Str2Rct.Bottom:=wdth+round((Str2Rct.Right-Str2Rct.Left)/2);
        end else
        begin
          wdth:=ClntRct.Bottom-ClntRct.Top;
          Str2Rct.Top:=ClntRct.Top;
          Str2Rct.Bottom:=ClntRct.Bottom;
          wdth:=Str2Rct.Left+round((Str2Rct.Right-Str2Rct.Left)/2);
          Str2Rct.Left:=wdth-round((Str2Rct.Bottom-Str2Rct.Top)/2);
          Str2Rct.Right:=wdth+round((Str2Rct.Bottom-Str2Rct.Top)/2);
          self.Canvas.Font.Size:=self.SetFontSize(StrMask,
           round((Str2Rct.Right-Str2Rct.Left)*0.9),round((Str2Rct.Right-Str2Rct.Left)*0.9));
        end;
      if self.FVal1>0 then
        begin
          Speed:=self.FVal2/self.FVal1;
          if Speed<self.FBadSpeed then self.Canvas.Brush.Color:=clRed;
          if (Speed<=self.FMdlSpeed)and(Speed>self.FBadSpeed) then self.Canvas.Brush.Color:=clYellow;
          if (Speed<=self.FNrmSpeed)and(Speed>self.FMdlSpeed) then self.Canvas.Brush.Color:=clAqua;
          if (Speed>self.FNrmSpeed) then self.Canvas.Brush.Color:=clLime;
        end else self.Canvas.Brush.Color:=clWhite;
      self.Canvas.Pen.Color:=self.FVal2Color;
      self.Canvas.Pen.Width:=3;
      self.Canvas.Ellipse(Str2Rct);
      self.Canvas.Pen.Width:=1;
      str:=inttostr(self.FVal2);
      self.Canvas.Brush.Style:=bsClear;
      self.Canvas.Font.Color:=clBlack;
      DrawText(self.Canvas.Handle,PChar(str),length(str),Str2Rct,
        (DT_SINGLELINE OR DT_VCENTER OR DT_CENTER));
      //
      if self.FBonus>0 then begin
        str:='+'+inttostr(self.FBonus)+' руб';
        wdth:=Str2Rct.Bottom-Str2Rct.Top;
        Str2Rct.Top:=Str2Rct.Top-round(wdth/2.5);
        Str2Rct.Bottom:=Str2Rct.Bottom-round(wdth/2);
        wdth:=Str2Rct.Right-Str2Rct.Left;
        Str2Rct.Left:=Str2Rct.Left-round(wdth*0.5);
        Str2Rct.Right:=Str2Rct.Left+wdth*2;
        self.Canvas.Font.Color:=clWhite;
        self.Canvas.Font.Size:=self.SetFontSize(Str,
           round((Str2Rct.Right-Str2Rct.Left)*0.9),round((Str2Rct.Right-Str2Rct.Left)*0.9));
        DrawText(self.Canvas.Handle,PChar(str),length(str),Str2Rct,
          (DT_SINGLELINE OR DT_VCENTER OR DT_CENTER));
      end;
      self.Canvas.Brush.Style:=bsSolid;
    end;

  // Восстановление цветов и стилей
  self.Canvas.Font.Style:=[];
  self.Canvas.Brush.Color:=BCol;
  self.Canvas.Pen.Color:=PCol;
  self.Canvas.Font.Color:=FCol;
end;

procedure THorDiagram.SetValue(val1,val2,val3:integer);
begin
  self.FVal1:=val1;
  self.FVal2:=val2;
  self.FVal3:=val3;
  self.Repaint;
end;

end.
