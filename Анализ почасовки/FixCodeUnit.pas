unit FixCodeUnit;
// ��������� ��� �������� ������������� �����,
// ��������� � ������� ��� ������ � ���� ������
// ���� ������ ��������� � ������ "0"

interface

uses SysUtils;

type
  TCodeRecord = record
    code      : string[13];  //���������������� ��� ���-13
    scannum   : byte;        //����� �������
    group     : byte;        //����� ������ �����
    name      : string[255]; //������������
    note      : string[255]; //����������
    sound     : string[255]; //��� ����� �����
  end;

  TCodeList = class
  private
    FCount : integer;
    FItem  : array of TCodeRecord;
    function GetItem(ind : integer):TCodeRecord;
    procedure SetItem(ind:integer;itm:TCodeRecord);
  public
    constructor Create;
    property    Count:integer read FCount write FCount;
    property    Item[ind:integer]:TCodeRecord read GetItem write SetItem;
    function    LoadFromFile(fname : string):boolean;
    function    IndByCode(code : string):integer;
  end;

implementation

constructor TCodeList.Create;
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



end.
