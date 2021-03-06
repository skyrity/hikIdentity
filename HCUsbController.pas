unit HCUsbController;

interface
Uses
    HCUsbSDK,HikGlobalFunc,Windows,SysUtils,Math,Vcl.Dialogs,IdentityCardProc;
Const
    CARDPROTO : ARRAY[0..3] OF STRING = ('0-TypeA M1卡','1-TypeA CPU卡','2-TypeB','3-125KHz ID卡');

Type
    TCardInfo = Class(TObject)
    Private
        FProtocol:String;
        FSerialLen:Integer;
        FSerialNum:String;
        FSelectVerifyLen:Integer;
        FSelectVerify:String;
    Public
        constructor Create;

        property Protocol :String read FProtocol write FProtocol;
        property SerialLen :Integer read FSerialLen write FSerialLen;
        property SerialNum :String read FSerialNum write FSerialNum;
        property SelectVerifyLen :Integer read FSelectVerifyLen write FSelectVerifyLen;
        property SelectVerify :String read FSelectVerify write FSelectVerify;
    End;

    THCUsb=class(TObject)
    Private
        FUserName:String;                               //用户名/账号
        FPassWord:String;                               //密码
        FSerialNum:String;                              //设备序列号
        FVID:LongWord;                                  //设备VID
        FPID:LongWord;                                  //设备PID
        FTimeOut:LongWord;                              //登录超时时间（单位：毫秒）
        FDeviceName:String;                             //设备名称
        FSoftwareVersion:LongWord;                      //软件版本号，高16位是主版本，低16位是次版本
        FUserId:Integer;                                //用户Id
        FSDKVerSion:String;                             //SDK版本号
        FWaitSecond:Integer;                            //操作等待时间：秒 (0-255)

        Fm_PicInfo : String;
        Fm_FingerPrintInfo : String;
        Fm_WordInfo : String;

        FIdCard:TChinaIdentity;
        //初始化
        Function Init:Boolean;
        //反初始化
        Function ClearUp:Boolean;
    Protected
    Public
        constructor Create;
        destructor Destroy; override;
        property UserName :String read FUserName write FUserName;
        property PassWord :String read FPassWord write FPassWord;
        property SerialNum :String read FSerialNum write FSerialNum;
        property TimeOut :LongWord read FTimeOut write FTimeOut;
        property VID :LongWord read FVID write FVID;
        property PID :LongWord read FPID write FPID;
        property DeviceName :String read FDeviceName write FDeviceName;
        property SoftwareVersion :LongWord read FSoftwareVersion write FSoftwareVersion;
        property UserId :Integer read FUserId write FUserId;
        property m_PicInfo :String read Fm_PicInfo write Fm_PicInfo;
        property m_FingerPrintInfo :String read Fm_FingerPrintInfo write Fm_FingerPrintInfo;
        property m_WordInfo :String read Fm_WordInfo write Fm_WordInfo;
        property SDKVerSion :String read FSDKVerSion write FSDKVerSion;
        property IdCard :TChinaIdentity read FIdCard write FIdCard;
        property WaitSecond :Integer read FWaitSecond write FWaitSecond;

        //枚举设备
        Function GetEnumDevice(pUser:Pointer):Boolean;
        //登录设备
        Function Usb_Login():Integer;
        //注销设备
        Function Usb_LogOut():Boolean;
        //获取错误码
        Function GetErrorId():LongWord;
        //获取错误信息
        Function GetErrorMsg():String;
        //配置日志信息
        Function SetLog(dwLogLevel:LongWord;Var strError:String):Boolean;

        {$REGION 'Config'}
        //设置设备配置
        Function SetDeviceConfig(dwCommand:LongWord;
                                  Var pInputInfo:USB_CONFIG_INPUT_INFO;
                                  Var pOutputInfo:USB_CONFIG_OUTPUT_INFO):Boolean;
        //读取设备配置
        Function GetDeviceConfig(dwCommand:LongWord;
                                  pInputInfo:LPUSB_CONFIG_INPUT_INFO;
                                  pOutputInfo:LPUSB_CONFIG_OUTPUT_INFO):Boolean;
        //蜂鸣器及显示灯配置设定
        Function SetBeepAndFlicker(byBeepType,byBeepCount,byFlickerType,byFlickerCount:Integer;Var strError:String):Boolean;
        //身份证信息获取
        Function GetIdentityInfo(Var strError:String):Boolean;
        //身份证信息下发
        Function SetIdentityInfo(Var strError:String):Boolean;
        //获取SDK版本号
        Function GetSdkVerSion():String;
        //激活卡操作
        Function ActivateCard(Var strError:String):TCardInfo;
        //获取身份证追加地址
        Function GetAddAddress(Var strError:String):String;
        //身份证卡片检测
        Function IsIdentityCard(Var strError:String):Boolean;
        {$ENDREGION}
    end;

implementation
Var
    g_nEnumDevIndex : Integer = INITIALIZED_INDEX;
    m_aHidDevInfo : ARRAY[0..63] OF USB_SDK_DEVICE_INFO;

{$REGION 'CallBack'}
Procedure OnEnumDeviceCallBack(Var pDevceInfo:USB_SDK_DEVICE_INFO;pUser :Pointer);stdcall;
Var
    CopyDeviceInfo:USB_SDK_DEVICE_INFO;
begin
    CopyDeviceInfo :=  pDevceInfo;
    CopyDeviceInfo.dwSize := SizeOf(CopyDeviceInfo);
    if(g_nEnumDevIndex = 64) then
    begin
        ShowMessage('设备数量异常：请确认设备数量不超过64个！');
        Exit;
    end;
    m_aHidDevInfo[g_nEnumDevIndex - 1] :=  CopyDeviceInfo;
    g_nEnumDevIndex := g_nEnumDevIndex + 1;
end;
{$ENDREGION}

{$REGION 'Base Controll'}
Function THCUsb.Init:Boolean;
begin
    Result := USB_SDK_Init();
end;

Function THCUsb.ClearUp:Boolean;
begin
    Result := USB_SDK_Cleanup();
end;

constructor THCUsb.Create;
begin
    inherited;
    Init;
    FUserName:='';
    FPassWord:='';
    FSerialNum:='';
    FVID:=0;
    FPID:=0;
    FTimeOut:=0;
    FDeviceName:='';
    FSoftwareVersion:=0;
    FSDKVerSion:='';
    FUserId:=-1;
    FWaitSecond:=5;
    IdCard := TChinaIdentity.Create;
end;

destructor THCUsb.Destroy;
begin
   IdCard.Free;
   Usb_LogOut;
   ClearUp;
   inherited;
end;

Function THCUsb.GetEnumDevice(pUser:Pointer):Boolean;
begin
    ZeroMemory(@m_aHidDevInfo[0],MAX_USB_DEV_LEN);
    g_nEnumDevIndex := 1;
    Result := USB_SDK_EnumDevice(@OnEnumDeviceCallBack,pUser);
end;

Function THCUsb.Usb_Login():Integer;
Var
    s_UsbLoginInfo:USB_SDK_USER_LOGIN_INFO;
    s_DevRegRes:USB_SDK_DEVICE_REG_RES;
//    resId:Int64;
begin
    Result := -1;
    if(self.UserName = '') then Exit;
    if(self.PassWord = '') then Exit;
    if(self.SerialNum = '') then Exit;
    if(self.VID = 0) then Exit;
    if(self.PID = 0) then Exit;
    if(self.TimeOut = 0) then Exit;
//    if(self.DeviceName = '') then Exit;
//    if(self.SoftwareVersion = 0) then Exit;

    ZeroMemory(@s_UsbLoginInfo,SizeOf(USB_SDK_USER_LOGIN_INFO));
    s_UsbLoginInfo.dwSize := SizeOf(USB_SDK_USER_LOGIN_INFO);
    CopyMemory(@s_UsbLoginInfo.szUserName,PAnsiChar(AnsiString(self.UserName)),Length(AnsiString(self.UserName)));
    CopyMemory(@s_UsbLoginInfo.szPassword,PAnsiChar(AnsiString(self.PassWord)),Length(AnsiString(self.PassWord)));
    CopyMemory(@s_UsbLoginInfo.szSerialNumber,PAnsiChar(AnsiString(self.SerialNum)),Length(AnsiString(self.SerialNum)));
    s_UsbLoginInfo.dwTimeout := self.TimeOut;
    s_UsbLoginInfo.dwVID := self.VID;
    s_UsbLoginInfo.dwPID := self.PID;

    ZeroMemory(@s_DevRegRes,SizeOf(USB_SDK_DEVICE_REG_RES));
    s_DevRegRes.dwSize := SizeOf(USB_SDK_DEVICE_REG_RES);
//    CopyMemory(@s_DevRegRes.szDeviceName,PAnsiChar(AnsiString(self.DeviceName)),Length(AnsiString(self.DeviceName)));
//    CopyMemory(@s_DevRegRes.szSerialNumber,PAnsiChar(AnsiString(self.SerialNum)),Length(AnsiString(self.SerialNum)));
//    s_DevRegRes.dwSoftwareVersion := self.SoftwareVersion;
//    s_UsbLoginInfo.dwSize := SizeOf(USB_SDK_USER_LOGIN_INFO) ;
//    s_UsbLoginInfo.dwTimeout := self.TimeOut;
//    s_UsbLoginInfo.dwVID := self.VID;
//    s_UsbLoginInfo.dwPID := self.PID;
//    s_UsbLoginInfo.szUserName := PAnsiChar(AnsiString(self.UserName);
//    s_UsbLoginInfo.szPassword :='';
//    s_UsbLoginInfo.szSerialNumber :=

    Result := USB_SDK_Login(s_UsbLoginInfo,s_DevRegRes);
    if(Result > 0) then
    begin
        self.SoftwareVersion := s_DevRegRes.dwSoftwareVersion;
        self.DeviceName := ArrayBufToStr(s_DevRegRes.szDeviceName,MAX_DEVICE_NAME_LEN);
        self.SerialNum := ArrayBufToStr(s_DevRegRes.szSerialNumber,MAX_SERIAL_NUM_LEN);
        self.UserId := Result;
    end;
//    Result:=resId;
end;

Function THCUsb.Usb_LogOut():Boolean;
begin
    Result:=false;
    if(self.UserId > 0) then
    begin
        Result:=USB_SDK_Logout(self.UserId);
        self.UserId := -1;
    end;
end;

Function THCUsb.GetErrorId():LongWord;
begin
    Result:= USB_SDK_GetLastError;
end;

Function THCUsb.GetErrorMsg():String;
Var
    errorId:LongWord;
    str:PAnsiChar;
begin
    errorId:= GetErrorId;
    str:=  USB_SDK_GetErrorMsg(errorId);
    Result:=IntToStr(errorId)+':'+ String(StrPas(str));
end;

Function THCUsb.SetLog(dwLogLevel:LongWord;Var strError:String):Boolean;
Var
    level:LongWord;
    path:String;
    flag:Boolean;
begin
    strError := '';
    case dwLogLevel of
        0:  level := ord(LOG_LEVEL_ENUM.ENUM_LOG_CLOSE) ;
        1:  level := ord(LOG_LEVEL_ENUM.ENUM_ERROR_LEVEL) ;
        2:  level := ord(LOG_LEVEL_ENUM.ENUM_DEBUG_LEVEL) ;
        else level := ord(LOG_LEVEL_ENUM.ENUM_INFO_LEVEL) ;
    end;
    path := ExtractFilePath(ParamStr(0)) + LOG_PATH + '\';
    path := Replacing(path,'\','\\');
    flag:=USB_SDK_SetLogToFile(level,PAnsiChar(AnsiString(path)),false);
    if not(flag) then  strError := GetErrorMsg;
    Result := flag;
end;
{$ENDREGION}

{$REGION 'Set Config'}
Function THCUsb.SetDeviceConfig(dwCommand:LongWord;
                                  Var pInputInfo:USB_CONFIG_INPUT_INFO;
                                  Var pOutputInfo:USB_CONFIG_OUTPUT_INFO):Boolean;
begin
    Result:=False;
    if UserId < 0 then Exit;
    Result := USB_SDK_SetDeviceConfig(UserId,dwCommand,pInputInfo,pOutputInfo);
end;

Function THCUsb.SetBeepAndFlicker(byBeepType,byBeepCount,byFlickerType,byFlickerCount:Integer;Var strError:String):Boolean;
Var
    s_InputInfo: USB_CONFIG_INPUT_INFO;
    s_OutputInfo: USB_CONFIG_OUTPUT_INFO;
    struBeepAndFlicker:USB_SDK_BEEP_AND_FLICKER;
begin
    Result:=False;
    strError:='';
    if UserId < 0 then
    begin
        strError  := '用户Id无效，请重新登录设备！';
        Exit;
    end;
    if(byBeepType > 4) OR (byFlickerType >4) then
    begin
        strError  := '蜂鸣器或指示灯类型异常，请选择正确类型！';
        Exit;
    end;
    if((byBeepType = 2) OR (byBeepType = 3)) AND
        ((byBeepCount < 0) OR (byBeepCount > 255)) then
    begin
        strError  := '蜂鸣次数异常，慢鸣和快鸣的蜂鸣次数必须在0(不含)-255(含)之间！';
        Exit;
    end;
    if((byFlickerType = 2) OR (byFlickerType = 3)) AND
        ((byFlickerCount < 0) OR (byFlickerCount > 255)) then
    begin
        strError  := '闪烁次数异常，错误和正确的闪烁次数必须在0(不含)-255(含)之间！';
        Exit;
    end;
    struBeepAndFlicker.dwSize := sizeof(USB_SDK_BEEP_AND_FLICKER);
    struBeepAndFlicker.byBeepType := byBeepType;
    struBeepAndFlicker.byBeepCount := byBeepCount;
    struBeepAndFlicker.byFlickerType := byFlickerType;
    struBeepAndFlicker.byFlickerCount := byFlickerCount;

    s_InputInfo.dwCondBufferSize := 0;
    s_InputInfo.lpCondBuffer := nil;
    s_InputInfo.dwInBufferSize := sizeof(struBeepAndFlicker);
    s_InputInfo.lpInBuffer := @struBeepAndFlicker;

    Result :=  self.SetDeviceConfig(USB_SDK_SET_BEEP_AND_FLICKER,s_InputInfo,s_OutputInfo);
    if not (Result) then
    begin
        strError:= self.GetErrorMsg;
    end;
end;

//身份证信息下发
Function THCUsb.SetIdentityInfo(Var strError:String):Boolean;
Var
    s_InputInfo: USB_CONFIG_INPUT_INFO;
    s_OutputInfo: USB_CONFIG_OUTPUT_INFO;
    s_IdentifyInfo:USB_SDK_IDENTITY_INFO_CFG;
    iPicSize,iFingerPrintSize : Integer;
begin
    Result:=False;
    strError:='';
    if UserId < 0 then
    begin
        strError  := '用户Id无效，请重新登录设备！';
        Exit;
    end;

    s_IdentifyInfo.dwSize := SizeOf(USB_SDK_IDENTITY_INFO_CFG);
    iPicSize := Length(m_PicInfo);
    iFingerPrintSize := Length(m_FingerPrintInfo);

    s_IdentifyInfo.wPicInfoSize := ifthen(iPicSize > PIC_LEN,PIC_LEN,iPicSize);
    s_IdentifyInfo.wFingerPrintInfoSize := ifthen(iFingerPrintSize > FINGER_PRINT_LEN,FINGER_PRINT_LEN,iFingerPrintSize);

    StrToRawByteBufB(self.m_PicInfo,s_IdentifyInfo.wPicInfoSize,s_IdentifyInfo.byPicInfo);
    StrToRawByteBufB(self.m_FingerPrintInfo,s_IdentifyInfo.wFingerPrintInfoSize,s_IdentifyInfo.byFingerPrintInfo);

    s_InputInfo.dwInBufferSize := SizeOf(s_IdentifyInfo);
    s_InputInfo.lpInBuffer := @s_IdentifyInfo;

    Result := USB_SDK_SetDeviceConfig(UserId,USB_SDK_SET_IDENTITY_INFO,s_InputInfo,s_OutputInfo);
    if not (Result) then
    begin
        strError:= self.GetErrorMsg;
    end;
end;
{$ENDREGION}

{$REGION 'Controll Device'}

{$ENDREGION}

{$REGION 'Get BaseInfo'}
Function THCUsb.GetSdkVerSion():String;
Var
    version:LongWord;
begin
    version:=USB_SDK_GetSDKVersion;
    if(version > 0) then
    begin
        self.SDKVerSion:=Format('SDK版本:%u.%u.%u.%u',[($ff000000 and version) Shr 24,($00ff0000 and version) Shr 16,($0000ff00 and version) Shr 8,($000000ff and version)]);
        Result:=self.SDKVerSion;
    end
    else
    begin
        Result := self.GetErrorMsg();
    end;
end;
{$ENDREGION}

{$REGION 'Get Config'}
Function THCUsb.GetDeviceConfig(dwCommand:LongWord;
                                  pInputInfo:LPUSB_CONFIG_INPUT_INFO;
                                  pOutputInfo:LPUSB_CONFIG_OUTPUT_INFO):Boolean;
begin
    Result:=False;
    if UserId < 0 then Exit;
    Result := USB_SDK_GetDeviceConfig(UserId,dwCommand,pInputInfo,pOutputInfo);
end;

//身份证信息获取
Function THCUsb.GetIdentityInfo(Var strError:String):Boolean;
Var
    s_CertificateInfo : USB_SDK_CERTIFICATE_INFO;
    s_OutputInfo: USB_CONFIG_OUTPUT_INFO;
//    s_InputInfo: USB_CONFIG_INPUT_INFO;
//    bName:array[0..31] of byte;
begin
    strError:='测试';
//    if UserId < 0 then
//    begin
//        strError  := '用户Id无效，请重新登录设备！';
//        Exit;
//    end;

    s_CertificateInfo.dwSize := SizeOf(USB_SDK_CERTIFICATE_INFO);
    s_OutputInfo.dwOutBufferSize := s_CertificateInfo.dwSize;
    s_OutputInfo.lpOutBuffer := @s_CertificateInfo;
    Result := USB_SDK_GetDeviceConfig(UserId,USB_SDK_GET_CERTIFICATE_INFO,nil,@s_OutputInfo);
    if not(Result) then
    begin
        strError := self.GetErrorMsg;
        Exit;
    end;

    IdCard.CertificateInfo := s_CertificateInfo;
    IdCard.IsReader := true;

    self.m_WordInfo := IdCard.ReadChineseIDcardName + #13#10 +
                        IdCard.ReadChineseCardSex + #13#10 +
                        IdCard.ReadChineseNationality + #13#10 +
                        IdCard.ReadBirthDate + #13#10 +
                        IdCard.ReadHomeAddress + #13#10 +
                        IdCard.ReadIDnum;
end;
//激活卡操作
Function THCUsb.ActivateCard(Var strError:String):TCardInfo;
Var
    item: TCardInfo;
    s_WaitSecond:USB_SDK_WAIT_SECOND;
    s_Input:USB_CONFIG_INPUT_INFO;
    s_ActivateRes:USB_SDK_ACTIVATE_CARD_RES;
    s_Output:USB_CONFIG_OUTPUT_INFO;
    flag:Boolean;
begin
    item := TCardInfo.Create;
    strError:='test';
    if UserId < 0 then
    begin
        Result:=nil;
        Exit;
    end;
    try
        s_WaitSecond.dwSize := SizeOf(USB_SDK_WAIT_SECOND);
        s_WaitSecond.byWait := self.WaitSecond;

        s_Input.dwInBufferSize := s_WaitSecond.dwSize;
        s_Input.lpInBuffer := @s_WaitSecond;

        s_ActivateRes.dwSize := SizeOf(USB_SDK_ACTIVATE_CARD_RES);
        s_Output.dwOutBufferSize := s_ActivateRes.dwSize;
        s_Output.lpOutBuffer := @s_ActivateRes;

        flag := USB_SDK_GetDeviceConfig(UserId,USB_SDK_GET_ACTIVATE_CARD, @s_Input,@s_Output);
        if not(flag) then
        begin
            strError := self.GetErrorMsg;
            Result:=nil;
            Exit;
        end;
        item.Protocol := CARDPROTO[s_ActivateRes.byCardType];
        item.SerialLen := s_ActivateRes.bySerialLen;
        item.FSelectVerifyLen := s_ActivateRes.bySelectVerifyLen;

        item.FSerialNum  := BinArrayToString(s_ActivateRes.bySerial,item.SerialLen);
        item.FSelectVerify :=  BinArrayToString(s_ActivateRes.bySelectVerify,item.FSelectVerifyLen);
    finally
        Result:=item;
    end;
end;
//获取身份证追加地址
Function THCUsb.GetAddAddress(Var strError:String):String;
Var
    s_CertificateAddAddrInfo : USB_SDK_CERTIFICATE_ADD_ADDR_INFO;
    s_OutputInfo: USB_CONFIG_OUTPUT_INFO;
    flag:Boolean;
    bAddress:array[0..ADDR_LEN-1] of byte;
begin
    Result:='';
    strError:='';
    if UserId < 0 then Exit;

    s_CertificateAddAddrInfo.dwSize := SizeOf(USB_SDK_CERTIFICATE_ADD_ADDR_INFO);
    s_OutputInfo.dwOutBufferSize := s_CertificateAddAddrInfo.dwSize;
    s_OutputInfo.lpOutBuffer := @s_CertificateAddAddrInfo;
    flag := USB_SDK_GetDeviceConfig(UserId,USB_SDK_GET_CERTIFICATE_ADD_ADDR_INFO,nil,@s_OutputInfo);
    if not(flag) then
    begin
        strError := self.GetErrorMsg;
        Exit;
    end;
    ZeroMemory(@bAddress,ADDR_LEN);
    copyMemory(@bAddress, @s_CertificateAddAddrInfo.byAddAddrInfo,s_CertificateAddAddrInfo.wAddrInfoSize);
    Result := trim(StrPas(Pchar(@bAddress)));
end;
//身份证卡片检测
Function THCUsb.IsIdentityCard(Var strError:String):Boolean;
Var
    s_DetectCardCond : USB_SDK_DETECT_CARD_COND;
    s_DetectCardCfg : USB_SDK_DETECT_CARD_CFG;
    s_Input:USB_CONFIG_INPUT_INFO;
    s_OutputInfo: USB_CONFIG_OUTPUT_INFO;
    flag:Boolean;
begin
    Result:=false;
    strError:='';
    if UserId < 0 then Exit;

    s_DetectCardCond.dwSize := SizeOf(USB_SDK_DETECT_CARD_COND);
    s_DetectCardCond.byWait := self.WaitSecond;

    s_DetectCardCfg.dwSize := SizeOf(USB_SDK_DETECT_CARD_CFG);

    s_Input.dwInBufferSize :=  s_DetectCardCond.dwSize;
    s_Input.lpInBuffer := @s_DetectCardCond;

    s_OutputInfo.dwOutBufferSize :=  s_DetectCardCfg.dwSize;
    s_OutputInfo.lpOutBuffer := @s_DetectCardCfg;

    flag :=  USB_SDK_GetDeviceConfig(UserId,USB_SDK_DETECT_CARD,@s_Input,@s_OutputInfo);
    if not(flag) then
    begin
        strError := self.GetErrorMsg;
        Exit;
    end;
    If(s_DetectCardCfg.byCardStatus = 1) then  Result:=true;
end;
{$ENDREGION}

{$REGION 'Card Info'}
constructor TCardInfo.Create;
begin
    inherited;
    FProtocol := '';
    FSerialLen := 0;
    FSerialNum := '';
    FSelectVerifyLen := 0;
    FSelectVerify := '';
end;
{$ENDREGION}
end.
