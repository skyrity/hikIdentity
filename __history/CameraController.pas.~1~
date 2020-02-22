unit CameraController;

interface
Uses
    UsbCameraSDK,SysUtils,HikGlobalFunc;

Type
    TUsbCamera=class(TObject)
    Private
        FFilePath:String;
        Fm_iHandle:Integer;             //设备开启句柄
        Fm_iPreviewHandle:Integer;      //预览句柄
        Fw_pHandle:Pointer;             //绑定窗口句柄
        procedure Init;
        procedure SetLogFile(path:String);
    Protected
    Public
        constructor Create;
        destructor Destroy;override;
        //获得文件存放地址
        property FilePath :String read FFilePath write FFilePath;
        property m_iHandle :Integer read Fm_iHandle write Fm_iHandle;
        property m_iPreviewHandle :Integer read Fm_iPreviewHandle write Fm_iPreviewHandle;
        property w_pHandle :Pointer read Fw_pHandle write Fw_pHandle;

        function EnumDeviceStart(pHandle:Pointer;Var strErr:String):Boolean;
        function CameraStart(pHandle:Pointer;Var strErr:String):Boolean;
        function SnapShot(Var strErr:String):Boolean;
    end;

implementation

constructor TUsbCamera.Create;
begin
    inherited;
    FilePath :=  ExtractFilePath(ParamStr(0))+ SDK_FILE;
    Init;
    SetLogFile(FilePath);
    m_iHandle := -1;
    m_iPreviewHandle := -1;
end;

procedure TUsbCamera.Init;
begin
    USBCamera_Init();
end;

procedure TUsbCamera.SetLogFile(path:String);
begin
    USBCamera_SetLogToFile(ord(LOG_LEVEL_ENUM.ENUM_INFO_LEVEL), path, true);
end;

function TUsbCamera.EnumDeviceStart(pHandle:Pointer;Var strErr:String):Boolean;
Var
    bEnum:Integer;
    tHandle: Pointer;
//    struDevInfo:USB_CAMERA_DEVICE_INFO_EXTEN;
    flag:Boolean;
begin
    m_iHandle:=-1;
    strErr:='';
    flag := false;
    Try
        bEnum := USBCamera_EnumDevice(tHandle, 0);
        if(bEnum <= 0) then
        begin
            strErr := '当前无设备！' ;
            result:=flag;
            Exit;
        end;
        //默认开启设备
        m_iHandle := USBCamera_OpenDevice(0);
        if(m_iHandle < 0) then
        begin
            strErr := '开启设备失败！' ;
            result:=flag;
            Exit;
        end;
//        bEnum := USBCamera_EnumDevice(@struDevInfo, sizeof(USB_CAMERA_DEVICE_INFO_EXTEN) * bEnum);
        CameraStart(pHandle,strErr);
    Finally
        result:=flag;
    End;
end;

function TUsbCamera.CameraStart(pHandle:Pointer;Var strErr:String):Boolean;
Var
    flag:Boolean;
    struCong:USB_CAMERA_CONFIG;
    struResolution:MEDIA_RESOLUTION_INFO;
    struStreamCfg:USB_CAMERA_SRC_STREAM_CFG;
    lpPreviewParam:USB_CAMERA_PREVIEW_PARAM;
    pTempInBuf:Pointer;
    index:Integer;
//    iErr:Int64;
begin
    flag:=false;
    try
        strErr:='';
        //配置相机帧率
        index:=30;
        pTempInBuf:=@index;
        struCong.dwInSize := 4;
        struCong.pInBuf := pTempInBuf;

        flag:= USBCamera_SetConfig(m_iHandle,USBCAMERA_SET_FRAMERATE,@struCong,SizeOf(struCong));
//        flag:= USBCamera_SetConfig(m_iHandle,USBCAMERA_SET_FRAMERATE,@struCong,sizeof(USB_CAMERA_CONFIG));
        if not(flag) then  strErr:= strErr + '错误代码：' + IntToStr(USBCamera_GetLastError());

        //配置相机分辨率
        struResolution.dwWidth := 640;
        struResolution.dwHeight := 480;
        struCong.pInBuf := @struResolution;
        struCong.dwInSize := SizeOf(struResolution);

        flag:= USBCamera_SetConfig(m_iHandle,USBCAMERA_SET_RESOLUTION,@struCong,SizeOf(struCong));
        if not(flag) then
        begin
            Result:=flag;
            Exit;
        end;

        //配置原始码流类型
        struStreamCfg.dwStreamType := USBCAMERA_STREAM_MJPEG;
        struStreamCfg.bUseAudio := false;

        struCong.pInBuf := @struStreamCfg;
        struCong.dwInSize := SizeOf(struStreamCfg);
        flag:= USBCamera_SetConfig(m_iHandle,USBCAMERA_SET_SRCSTREAMTYPE,@struCong,SizeOf(struCong));
        if not(flag) then
        begin
            Result:=flag;
            Exit;
        end;

        //开启预览
        lpPreviewParam.dwStreamType := USBCAMERA_STREAM_PS_H264;
        lpPreviewParam.bUseAudio := false;
        lpPreviewParam.bUseFD := false;
        lpPreviewParam.hWindow := pHandle;
        lpPreviewParam.dwSize := SizeOf(lpPreviewParam);
        m_iPreviewHandle :=  USBCamera_StartPreview(m_iHandle,@lpPreviewParam);
        if(m_iPreviewHandle < 0) then
        begin
            strErr:= strErr + ' 预览失败！';
            Result:=flag;
            Exit;
        end;
        flag:=true;
    finally
        Result:=flag;
    end;
end;

function TUsbCamera.SnapShot(Var strErr:String):Boolean;
Var
    lpCaptuerParam:USB_CAMERA_CAPTURE_PARAM;
    flag:Boolean;
    path:String;
    index:Integer;
begin
    flag  :=false;
    strErr  :='';
    try
        lpCaptuerParam.bCaptureFacePic := false;
        path  := ExtractFilePath(ParamStr(0)) + IMAGE_FILE + '\test.jpg';
        StrToRawByteBufB(trim(path),260,lpCaptuerParam.szFilePath);
        index := 10 * 1024 * 1024;
        lpCaptuerParam.pBuf := @index;
        flag:= USBCamera_Capture(m_iHandle, @lpCaptuerParam);
        if not(flag) then strErr := '抓图失败！'
        else  strErr := '抓图成功！';
    finally
        result:=flag;
    end;
end;

destructor TUsbCamera.Destroy;
begin
   USBCamera_Fini;
end;

end.
