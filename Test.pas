unit Test;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,HCUsbController,RegularExpressions,
  Vcl.ComCtrls,Vcl.Imaging.jpeg,HCUsbSDK;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    pal_CameraArea: TPanel;
    btn_Start: TButton;
    btn_CatchImg: TButton;
    Panel3: TPanel;
    btn_IdReader: TButton;
    REditDebug: TRichEdit;
    Panel4: TPanel;
    Panel5: TPanel;
    imgPhoto: TImage;
    btn_BmpRead: TButton;
    btn_Check: TButton;
    procedure btn_StartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn_IdReaderClick(Sender: TObject);
    procedure btn_BmpReadClick(Sender: TObject);
    procedure btn_CheckClick(Sender: TObject);
  private
    { Private declarations }
//    FCamera:TUsbCamera;
    FUSB:THCUsb;
    userId:Integer;
    procedure DebugPrint(StrText: String; Color: TColor);

    procedure ShowImage(path:String);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}
procedure TfrmMain.DebugPrint(StrText:String;Color:TColor);
var
  A: TArray<string>;
  i:integer;
begin
  REditDebug.SelAttributes.Color := Color;
//  REditDebug.Lines.Add(StrText);
  A :=  TRegEx.Split(StrText,';');//SplitString(StrText,';');
  for i := 0 to Length(A) -1 do
  begin
    REditDebug.Lines.Add(A[i]);
  end;
end;
procedure TfrmMain.ShowImage(path:String);
Var
    imgStream: TMemoryStream;
    jpg:TJpegImage;
    Buffer:Word;
begin
    imgStream:= TMemoryStream.Create;
    jpg:=TJpegImage.Create;
    try
        imgStream.LoadFromFile(path);
        imgStream.Position:=0;
        imgStream.ReadBuffer(Buffer,2);
        if(Buffer=$D8FF) or (Buffer=$4947) then
        begin
            imgStream.Position := 0;
            jpg.LoadFromStream(imgStream);
            self.imgPhoto.Picture.Bitmap.Assign(jpg);
        end
        else if(Buffer=$4D42)then
        begin
            imgStream.Position := 0;
            self.imgPhoto.Picture.Bitmap.LoadFromStream(imgStream);
        end
        else  DebugPrint('��ȡͼƬʧ�ܣ�',clRed);
    finally
        imgStream.Free;
        jpg.Free;
    end;
end;
procedure TfrmMain.btn_BmpReadClick(Sender: TObject);
Var
//    path:String;
    item:TCardInfo;
    strErr:String;
begin
//    item := TCardInfo.Create;
     if(userId > 0) then
     begin
          REditDebug.Clear;
     end
     else
     begin
        FUSB.UserName := 'admin';
        FUSB.PassWord := '12345';
        FUSB.SerialNum := 'E05261066';
        FUSB.VID := 1155;
        FUSB.PID := 22352;
        FUSB.TimeOut := 5000;
        FUSB.GetEnumDevice(nil);
        userId := FUSB.Usb_Login;
        DebugPrint('��¼�ɹ����û�Id=' + IntToStr(FUSB.UserId) + ';�豸����=' + FUSB.DeviceName + ';�豸���к�=' + FUSB.SerialNum + ';�����汾=' + IntToStr(FUSB.SoftwareVersion),clGreen);
     end;
//    path := ExtractFilePath(ParamStr(0)) + IMAGE_FOLDER + '\' + IMAGE_FILE;
////    self.imgPhoto.Picture.Bitmap.LoadFromFile(path);
//    DebugPrint('����֤ͼƬ��ַ=' + path,clGreen);
//    ShowImage(path);
    strErr:='';
    item:= FUSB.ActivateCard(strErr);
    if not(item = nil) then
    begin
        DebugPrint('��Э������=' + item.Protocol,clGreen);
        DebugPrint('���кų���=' + IntToStr(item.SerialLen),clGreen);
        DebugPrint('���к�=' + item.SerialNum,clGreen);
        DebugPrint('ѡ��ȷ������=' + IntToStr(item.SelectVerifyLen),clGreen);
        DebugPrint('ѡ��ȷ��=' + item.SelectVerify,clGreen);
    end
    else
    begin
        DebugPrint('���ʧ�ܣ�' + strErr,clRed);
    end;
end;

procedure TfrmMain.btn_CheckClick(Sender: TObject);
Var
    strErr:String;
begin
    if(userId > 0) then
     begin
          REditDebug.Clear;
     end
     else
     begin
        FUSB.UserName := 'admin';
        FUSB.PassWord := '12345';
        FUSB.SerialNum := 'E05261066';
        FUSB.VID := 1155;
        FUSB.PID := 22352;
        FUSB.TimeOut := 5000;
        FUSB.GetEnumDevice(nil);
        userId := FUSB.Usb_Login;
        DebugPrint('��¼�ɹ����û�Id=' + IntToStr(FUSB.UserId) + ';�豸����=' + FUSB.DeviceName + ';�豸���к�=' + FUSB.SerialNum + ';�����汾=' + IntToStr(FUSB.SoftwareVersion),clGreen);
     end;
     strErr:='';
     if(FUSB.IsIdentityCard(strErr)) then DebugPrint('��⵽��Ƭ!' ,clGreen)
     else DebugPrint('δ��⵽��Ƭ:' + strErr,clRed);
end;

procedure TfrmMain.btn_IdReaderClick(Sender: TObject);
Var
//    flag:Boolean;
    strErr,path:String;
begin
    strErr := '';
    FUSB.UserName := 'admin';
    FUSB.PassWord := '12345';
    FUSB.SerialNum := 'E05261066';
    FUSB.VID := 1155;
    FUSB.PID := 22352;
    FUSB.TimeOut := 5000;
    if(userId > 0) then
    begin
        FUSB.IdCard.Free;
        FUSB.IdCard.Create;
        REditDebug.Clear;
    end
    else
    begin
        FUSB.GetEnumDevice(nil);
        userId := FUSB.Usb_Login;
        DebugPrint('��¼�ɹ����û�Id=' + IntToStr(FUSB.UserId) + ';�豸����=' + FUSB.DeviceName + ';�豸���к�=' + FUSB.SerialNum + ';�����汾=' + IntToStr(FUSB.SoftwareVersion),clGreen);
    end;
//
    if(userId > 0) then
    begin
        if not(FUSB.GetIdentityInfo(strErr)) then
        begin
            DebugPrint('��ȡ����֤��Ϣʧ�ܣ�' + strErr,clRed);
        end
        else
        begin
            DebugPrint('����֤����=' + FUSB.m_WordInfo + ';ͼƬ=' + FUSB.m_PicInfo + ';ָ��=' + FUSB.m_FingerPrintInfo,clGreen);
            if not(FUSB.IdCard.IsPicDone) then
            begin
                FUSB.IdCard.IDpictureProcess;
            end;
            path := FUSB.IdCard.PicAddr;
            DebugPrint('����֤ͼƬ��ַ=' + path,clGreen);
            ShowImage(path);
            DebugPrint('����֤׷�ӵ�ַ=' + FUSB.GetAddAddress(strErr),clGreen);
        end;
    end
    else
    begin
        DebugPrint('��¼ʧ�ܣ�',clRed);
    end;

end;

procedure TfrmMain.btn_StartClick(Sender: TObject);
Var
//    flag : Boolean;
    strError : String;
begin
    strError := '';
//    flag := FCamera.EnumDeviceStart(Pointer(self.pal_CameraArea.Handle),strError);
end;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
//    FCamera:= TUsbCamera.Create;
    FUSB := THCUsb.Create;
    userId:=0;
    DebugPrint(FUSB.GetSdkVerSion,clBlue);
end;

end.