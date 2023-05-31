unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Tabs, DockTabSet, ExtCtrls, ToolWin, ActnList,
  Buttons, Grids, ImgList, Menus;

type
  TEditor = class(TForm)
    ToolBar1: TToolBar;
    MainPn: TPanel;
    StatusBar1: TStatusBar;
    ListPn: TPanel;
    Tabs: TDockTabSet;
    CapLb: TLabel;
    ActionList1: TActionList;
    NewFile: TAction;
    ToolButton1: TToolButton;
    NewItem: TAction;
    EdiitItem: TAction;
    ToolButton2: TToolButton;
    SaveFile: TAction;
    SaveDLG: TSaveDialog;
    OpenDLG: TOpenDialog;
    ToolButton3: TToolButton;
    OpenFile: TAction;
    Grid: TStringGrid;
    BtmPn: TPanel;
    EditPn: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpeedButton1: TSpeedButton;
    SaveItmBtn: TBitBtn;
    NameED: TEdit;
    CodeED: TEdit;
    NoteED: TEdit;
    GroupCB: TComboBox;
    CodeGenBtn: TBitBtn;
    DeleteItem: TAction;
    ToolButton4: TToolButton;
    ImageList1: TImageList;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    SaveFileAs: TAction;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    Label5: TLabel;
    SoundED: TEdit;
    procedure N11Click(Sender: TObject);
    procedure SaveFileAsExecute(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DeleteItemExecute(Sender: TObject);
    procedure CodeGenBtnClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormResize(Sender: TObject);
    procedure OpenFileExecute(Sender: TObject);
    procedure SaveFileExecute(Sender: TObject);
    procedure EdiitItemExecute(Sender: TObject);
    procedure SaveItmBtnClick(Sender: TObject);
    procedure NewItemExecute(Sender: TObject);
    procedure NewFileExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateList;
    function  SaveCngDlg:boolean;
    procedure ShowHint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Editor: TEditor;


implementation

{$R *.dfm}

uses DataUnit;

var
  CodeList : TCodeList;
  FName    : string;
  CngList  : boolean;

procedure TEDitor.ShowHint(Sender: TObject);
begin
  self.StatusBar1.SimpleText:=Application.Hint;
end;

procedure TEditor.CodeGenBtnClick(Sender: TObject);
var
  newcode:string;
begin
  if MessageDLG('Подобрать код?',mtWarning,[mbYes,mbNo],0)=mrYes then begin
    repeat
      newcode:='';
      randomize;
      newcode:=IntToStr(random(MaxInt));
      while Length(newcode)<11 do newcode:='0'+newcode;
      newcode:=IntToStr(GroupCB.ItemIndex)+newcode;
    until (CodeList.IndByCode(newcode)=-1) ;
    CodeED.Text:=newcode;
  end;
end;

function TEditor.SaveCngDlg:boolean;
begin
  result:=(MessageDLG('Сохранить изменения ?',mtWarning,[mbYes,mbNo],0)=mrYes);
end;

procedure TEditor.DeleteItemExecute(Sender: TObject);
var
  ind : integer;
begin
  if Grid.Selection.Top>=0 then begin
    ind:=CodeList.IndByCode(Grid.Cells[0,Grid.Selection.Top]);
    if ind>=0 then begin
      CodeList.Delete(ind);
      BtmPN.Visible:=false;
      CngList:=true;
      self.UpdateList;
    end;
  end;
end;

procedure TEditor.EdiitItemExecute(Sender: TObject);
var
  ind : integer;
begin
  if (sender is TPanel) then begin
    ind:=(sender as TPanel).Tag;
    CodeED.Text:=CodeList.Item[ind].code;
    NameED.Text:=CodeList.Item[ind].name;
    NoteED.Text:=CodeList.Item[ind].note;
    SoundED.Text:=CodeList.Item[ind].sound;
    GroupCB.ItemIndex:=CodeList.Item[ind].group;
    BtmPn.Visible:=true;
  end;
end;

procedure TEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if CngList then if self.SaveCngDlg then self.SaveFileExecute(self);
end;

procedure TEditor.FormCreate(Sender: TObject);
begin
  CodeList:=TCodeList.Create;
  self.NewFileExecute(self);
  GroupCB.Items:=Tabs.Tabs;
  Application.OnHint:=ShowHint;
end;

procedure TEditor.FormResize(Sender: TObject);
begin
  Grid.ColWidths[0]:=round(Grid.ClientWidth*0.2);
  Grid.ColWidths[1]:=round(Grid.ClientWidth*0.3);
  Grid.ColWidths[2]:=Grid.ClientWidth-Grid.ColWidths[0]-Grid.ColWidths[1]-5;
  EditPn.Left:=round((BtmPn.ClientWidth-EditPn.Width)/2);
end;

procedure TEditor.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  //определяем индекс записи в списке и передаем панели редактирования
  //через свойство TAG
  EditPn.Tag:=CodeList.IndByCode(grid.Cells[0,ARow]);
  if EditPn.Tag>=0 then  self.EdiitItemExecute(EditPn);
end;

procedure TEditor.N11Click(Sender: TObject);
var
  str : string;
begin
  str:='Редактор записей о кодах. Версия 1.0.'+chr(13);
  str:=str+'Вспомогательное приложение для системы учета брака на РМ ОТК СБЦ.'+chr(13);
  str:=str+'Шагинян С.В., 2015 г.';
  MessageDLG(str,mtInformation,[mbOK],0);
end;

procedure TEditor.N6Click(Sender: TObject);
begin
  self.Close;
end;

procedure TEditor.NewFileExecute(Sender: TObject);
begin
  if CngList then if self.SaveCngDlg then self.SaveFileExecute(self);
  fname:='newlist.cdl';
  CodeList.Clear;
  self.UpdateList;
  BtmPn.Visible:=false;
  CngList:=false;
end;

procedure TEditor.NewItemExecute(Sender: TObject);
begin
  NameED.Text:='';
  NoteED.Text:='';
  CodeED.Text:='';
  GroupCB.ItemIndex:=0;
  SoundED.Text:='';
  EditPn.Tag:=-1; // "-1" указывает на создание новой записи
  BtmPn.Visible:=true;
end;

procedure TEditor.OpenFileExecute(Sender: TObject);
begin
  if CngList then if self.SaveCngDlg then self.SaveFileExecute(self);
  if OpenDLG.Execute then begin
    fname:=OpenDLG.FileName;
    CodeList.LoadFromFile(fname);
    BtmPn.Visible:=false;
    CngList:=false;
    self.UpdateList;
  end;
end;

procedure TEditor.SaveFileAsExecute(Sender: TObject);
begin
  if SaveDLG.Execute then begin
      fname:=SaveDLG.FileName;
      CodeList.SaveToFile(fname);
      CngList:=false;
    end;
end;

procedure TEditor.SaveFileExecute(Sender: TObject);
begin
  if FileExists(fname) then CodeList.SaveToFile(fname)
    else if SaveDLG.Execute then begin
      fname:=SaveDLG.FileName;
      CodeList.SaveToFile(fname);
    end;
  CngList:=false;
end;

procedure TEditor.SaveItmBtnClick(Sender: TObject);
var
  NewItm : TCodeRecord;
  ind    : integer;
  code   : string;
begin
  if (Length(CodeED.Text)=0) or (Length(NameED.Text)=0) then begin
    MessageDLG('Поля "Код" и "Наименовине" должны быть заполнены !',mtError,[mbOk],0);
    Abort;
  end;
  code :=CodeEd.Text;
  if Length(code)<>12 then begin
    MessageDLG('Код должен содержать 12 цифр !',mtError,[mbOK],0);
    Abort;
  end;
  ind:=1;
  while(ind<=Length(CodeED.Text))and(CodeED.Text[ind] in ['0'..'9'])do inc(ind);
  if(ind<=Length(CodeED.Text))and(not(CodeED.Text[ind] in ['0'..'9']))then begin
    MessageDLG('В коде долждны быть только цифры !',mtError,[mbOK],0);
    Abort;
  end;
  ind:=EditPn.Tag;
  if (ind=-1)or(MessageDLG('Перезаписать данные ?',
    mtWarning,[mbYes,mbNo],0)=mrYes) then begin
      NewItm.code:=CodeED.Text;
      NewItm.name:=NameED.Text;
      NewItm.note:=NoteED.Text;
      NewItm.group:=GroupCB.ItemIndex;
      NewItm.sound:=SoundED.Text;
      if ind=-1 then ind:=CodeList.Add(NewItm) else CodeList.Item[ind]:=NewItm;
      if ind=-1 then MessageDLG('Запись с таким кодом уже существует !',mtError,[mbOK],0)
        else begin
          CngList:=true;
          BtmPn.Visible:=false;
          self.UpdateList;
        end;
    end;
end;

procedure TEditor.SpeedButton1Click(Sender: TObject);
begin
  EditPn.Tag:=-1;
  BtmPn.Visible:=false;
end;

procedure TEditor.UpdateList;
var
  i,trow     : integer;
begin
  CapLB.Caption:='  '+ExtractFileName(fname);
  trow:=Grid.TopRow;
  Grid.RowCount:=CodeList.Count;
  for I := 0 to CodeList.Count - 1 do
    if CodeList.Item[i].group=Tabs.TabIndex then begin
      Grid.Cells[0,i]:=CodeList.Item[i].code;
      Grid.Cells[1,i]:=CodeList.Item[i].name;
      Grid.Cells[2,i]:=CodeList.Item[i].note;
    end;
  Grid.Visible:=(CodeList.Count>0);
  if grid.Visible then begin
    if trow<=grid.RowCount then grid.TopRow:=trow;
    self.FormResize(self);
  end;
end;

end.
