unit DataUnit;

interface

uses SysUtils;

type
  TCodeRecord = record
    code      : string[13];  //непостредственно код ЕАН-13
    scnum     : byte;        //номер сканера
    group     : byte;        //номер группы кодов
    name      : string[255]; //наименование
    note      : string[255]; //примечание
    sound     : string[255]; //имя файла звука
  end;

  TCodeList = class
  private
    FCount : integer;
    FItem  : array of TCodeRecord;
    function GetItem(ind : integer):TCodeRecord;
    procedure SetItem(ind:integer;itm:TCodeRecord);
  public
    constructor Create;
    procedure   SaveToFile(fname : string);
    property    Count:integer read FCount write FCount;
    property    Item[ind:integer]:TCodeRecord read GetItem write SetItem;
    function    LoadFromFile(fname : string):boolean;
    function    Add(newitem : TCodeRecord):integer;
    function    IndByCode(code : string):integer;
    procedure   Clear;
    procedure   Delete(ind:integer);
  end;

implementation

constructor TCodeList.Create;
begin
  FCount:=0;
  SetLength(FItem,0);
end;

procedure TCodeList.Clear;
begin
  FCount:=0;
  SetLength(FItem,0);
end;

function TCodeList.GetItem(ind: Integer):TCodeRecord;
begin
  result:=self.FItem[ind];
end;

procedure TCodeList.SetItem(ind: Integer; itm : TCodeRecord);
begin
  self.FItem[ind]:=itm;
end;

function TCodeList.IndByCode(code: string):integer;
var
  i : integer;
begin
  i:=0;
  while(i<self.FCount)and(self.FItem[i].code<>code)do inc(i);
  if (i<self.FCount)and(self.FItem[i].code=code) then result:=i else result:=-1;
end;

procedure TCodeList.SaveToFile(fname: string);
var
  myfile : File of TCodeRecord;
  i      : integer;
begin
  assignfile(myfile,fname);
  try
  rewrite(myfile);
  for i := 0 to self.FCount - 1 do write(myfile,self.FItem[i]);
  finally
  closefile(myfile);
  end;
end;

function TCodeList.LoadFromFile(fname: string):boolean;
var
  myfile : file of TCodeRecord;
  i      : integer;
begin
  result:=false;
  if FileExists(fname) then begin
    assignfile(myfile,fname);
    try
    reset(myfile);
    i:=0;
    while not EoF(myfile)do begin
        inc(i);
        SetLength(self.FItem,i);
        read(myfile,self.FItem[i-1]);
      end;
    self.FCount:=i;
    if i>0 then result:=true;
    finally
    closefile(myfile);
    end;
  end;
end;

function TCodeList.Add(newitem:TCodeRecord):integer;
var
  i : integer;
begin
  result:=-1;
  i:=0;
  while(i<self.FCount)and(self.FItem[i].code<>newitem.code)do inc(i);
  if (i=self.FCount) then begin
    inc(self.FCount);
    SetLength(self.FItem,self.FCount);
    self.FItem[self.FCount-1]:=newitem;
    result:=self.FCount-1;
  end;
end;

procedure TCodeList.Delete(ind: Integer);
var
  i : integer;
begin
  i:=ind;
  while(i<self.FCount-1)do begin
    self.FItem[i]:=self.Fitem[i+1];
    inc(i);
  end;
  dec(self.FCount);
  SetLength(self.FItem,self.FCount); 
end;

end.
