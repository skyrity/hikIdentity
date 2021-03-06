unit HikGlobalFunc;

interface
 uses windows,System.StrUtils,SysUtils,Classes;

  function IPBufToStr(IPBuf:Array of AnsiChar):string;
  function ArrayBufToStr(ArrayBuf:Array of AnsiChar ;ACount:WORD):string;
  function ArrayBufBToStr(ArrayBuf:Array of Byte ;ACount:WORD):string;
  function StrToArrayBufB(strBuf:String; Acount:Word; Var arrBuf:Array of Byte):Boolean;
  function BytesToUTF8String(ArrayBuf:Array of Byte ;ACount:WORD):string;
  function BytesToString(ArrayBuf:Array of Byte ;ACount:WORD):string;
  function StrToRawByteBufB(const strBuf:String; Acount:Word; Var arrBuf:Array of Byte):Boolean;
  function BytesToRawByteString(ArrayBuf:Array of Byte):String;
  function StrToArrayAnsiChar(const strBuf:String; Acount:Word; Var arrBuf:Array of AnsiChar):Boolean;
  function TimeStandardization(hour,minute,second,msSec:Integer):TDatetime;
  //更换字符串
  //S：更换的内容
  //OldPattern：需要替换的目标
  //NewPattern：替换后的文字
  //Result:更换后的新字符串
  function Replacing(const S,OldPattern,NewPattern:String):String;

  function ByteToHex(InByte:byte):string;
  function BinArrayToString(aArray: array of Byte): string;overload;
  function BinArrayToString(aArray: array of Byte; index:integer): string;overload;
implementation
function IPBufToStr(IPBuf:Array of AnsiChar):String;
var
  s:string;
  i:integer;
begin
  SetLength(s,20);
  CopyMemory(@s[1],@IPBuf,20);
  i := Pos(chr(0),s);
  if i>20 then i:=20;
  Result := String(LeftStr(s,i-1));
end;

function StrToArrayAnsiChar(const strBuf:String; Acount:Word; Var arrBuf:Array of AnsiChar):Boolean;
Var
    index:Integer;
    asStr:AnsiString;
begin
    fillchar(arrBuf,SizeOf(arrBuf),#0);
    asStr:= AnsiString(strBuf);
    if(length(asStr) < Acount) then
    begin
      Acount :=  length(asStr);
    end;
    for index := 0 to Acount - 1 do
    begin
       arrBuf[index] := AnsiChar(strBuf[index +1]);
    end;
    result := true;
end;
function ArrayBufToStr(ArrayBuf:Array of AnsiChar ;ACount:WORD):string;
var
  s:AnsiString;
  i:integer;
begin
  SetLength(s,ACount);
  CopyMemory(@s[1],@ArrayBuf,ACount);
  i := Pos(Chr(0),String(s));
  if i>ACount then i:=ACount;
  Result := String(LeftStr(s,i-1));
//  Result := String(s);
end;

function ArrayBufBToStr(ArrayBuf:Array of Byte ;ACount:WORD):string;
var
  s:String;
  i:integer;
begin
  SetLength(s,ACount);
  CopyMemory(@s[1],@ArrayBuf,ACount);
  i := Pos(chr(0),s);
  if i>ACount then i:=ACount;
  Result :=LeftStr(s,i-1);
end;

function BytesToString(ArrayBuf:Array of Byte ;ACount:WORD):string;
var
    s:AnsiString;
begin
    SetLength(s,ACount);
    Result:=String(StrLCopy(PansiChar(S),@ArrayBuf,ACount));
end;



function StrToArrayBufB(strBuf:String; Acount:Word; Var arrBuf:Array of Byte):Boolean;
 var
    asStr:AnsiString;
 begin
    fillchar(arrBuf,SizeOf(arrBuf),0);
    asStr:= AnsiString(strBuf);
    if(length(asStr) < Acount) then
    begin
      Acount :=  length(asStr);
    end;
    CopyMemory(@arrBuf,PAnsiChar(asStr),Acount);
    result := true;
 end;


(*********************Bytes - UTF8 - String 相互转化方法****************************************)
 function StrToRawByteBufB(const strBuf:String; Acount:Word; Var arrBuf:Array of Byte):Boolean;
 var
    rbStr:RawByteString;
 begin
    fillchar(arrBuf,SizeOf(arrBuf),0);
    rbStr := UTF8Encode(strBuf);
    if(length(rbStr) < Acount) then
    begin
      Acount :=  length(rbStr);
    end;
    CopyMemory(@arrBuf,PAnsiChar(rbStr),Acount);
    result := true;
 end;
function BytesToUTF8String(ArrayBuf:Array of Byte ;ACount:WORD):string;
var
    s:AnsiString;
begin
    SetLength(s,ACount);
    Result:=String(Utf8ToAnsi(StrLCopy(PansiChar(S),@ArrayBuf,ACount)));
end;
function BytesToRawByteString(ArrayBuf:Array of Byte):String;
var
    rbStr:RawByteString;
begin
     SetLength(rbStr, Length(ArrayBuf));
     if Length(ArrayBuf) > 0 then
     begin
        Move(ArrayBuf[0], rbStr[1], Length(ArrayBuf));
     end;
     result:=UTF8ToString(rbStr);
 end;
(*********************Bytes - UTF8 - String 相互转化方法****************************************)
 function TimeStandardization(hour,minute,second,msSec:Integer):TDatetime;
 Var
    time:TDatetime;
 begin
    if(hour >= 24) then
    begin
        time :=EncodeTime(23,59,59,0);
    end
    else if (minute >= 60) then
    begin
        time :=EncodeTime(hour,59,59,0);
    end
    else if (second >= 60) then
    begin
        time :=EncodeTime(hour,minute,59,0);
    end
    else if (msSec >= 1000) then
    begin
        time :=EncodeTime(hour,minute,second,999);
    end
    else
    begin
        time :=EncodeTime(hour,minute,second,msSec);
    end;
    result := time;
 end;

//更换字符串
function Replacing(const S,OldPattern,NewPattern:String):String;
begin
  Result:=StringReplace(S,OldPattern,NewPattern,[rfReplaceAll, rfIgnoreCase]);
end;

function ByteToHex(InByte:byte):string;
    const Digits:array[0..15] of char='0123456789ABCDEF';
  begin
    result:=digits[InByte shr 4]+digits[InByte and $0F];
  end;

function BinArrayToString(aArray: array of Byte): string;
  var
    i: integer;
  begin
    result:='';
    for i:= Low(aArray) to High(aArray) do
    begin
      result:= result + ByteToHex(aArray[i]);
    end;
//    Result:= IntToStr(StrToInt('$'+result));
  end;
 function BinArrayToString(aArray: array of Byte; index:integer): string;
  var
    i: integer;
  begin
    result:='';
    for i:=0 to index - 1 do
    begin
      result:= result + ByteToHex(aArray[i]);
    end;
//    Result:= IntToStr(StrToInt('$'+result));
  end;
end.
