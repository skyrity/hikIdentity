unit UsbCameraSDK;

interface
Uses
    Types,Winapi.Messages,windows;

Const
    {$REGION '���������'}
    USBCAMERA_GET_VIDEO_CAP       = 1;                  // ��ȡ��Ƶ������
    USBCAMERA_GET_AUDIO_CAP       = 2;                  // ��ȡ��Ƶ������
    USBCAMERA_GET_VIDEO_FORMAT    = 3;                  // ��ȡ��Ƶ������ʽ
    USBCAMERA_SET_VIDEO_FORMAT    = 4;                  // ��ȡ��Ƶ������ʽ
    USBCAMERA_GET_AUDIO_FORMAT    = 5;                  // ��ȡ��Ƶ������ʽ
    USBCAMERA_SET_AUDIO_FORMAT    = 6;                  // ������Ƶ������ʽ
    USBCAMERA_GET_RESOLUTION      = 7;                  // ��ȡ��Ƶ�ֱ���
    USBCAMERA_SET_RESOLUTION      = 8;                  //������Ƶ�ֱ���
    USBCAMERA_SET_FRAMERATE       = 10;                 //������Ƶ֡��
    USBCAMERA_SET_SRCSTREAMTYPE   = 16;                 // ����ԭʼ��������
    {$ENDREGION}
    {$REGION '��������: ��Ƶ+(��Ƶ)����'}
    (************************************************************************
        *
    ************************************************************************)
    USBCAMERA_STREAM_MJPEG        = 101;                // MJPEG������
    USBCAMERA_STREAM_YUV          = 102;                // YUV������
    USBCAMERA_STREAM_H264         = 103;                // H264������(�����֧��H264�������)
    USBCAMERA_STREAM_PS_H264      = 104;                // PS��װH264����
    USBCAMERA_STREAM_PS_MJPEG     = 105;                // PS��װH264+PCM����
    {$ENDREGION}
     MAX_PATH                     = 260;
     SDK_FILE                     = 'USBSdkLog';
     IMAGE_FILE                   = 'images';
//     {$REGION '��־����'}
//     ERROR_LEVEL                  = 1;                  //ERROR����ֻ���ERROR��Ϣ��
//     DEBUG_LEVEL                  = 2;                  //DEBUG�������DEBUG��Ϣ + ERROR��Ϣ��
//     INFO_LEVEL                   = 3;                  //INFO�������INFO��Ϣ + DEBUG��Ϣ + ERROR��Ϣ��
//     {$ENDREGION}
Type
    {$REGION 'Enum'}
    LOG_LEVEL_ENUM=( ENUM_ERROR_LEVEL = 1,           //ERROR����ֻ���ERROR��Ϣ��
                        ENUM_DEBUG_LEVEL = 2,           //DEBUG�������DEBUG��Ϣ + ERROR��Ϣ��
                        ENUM_INFO_LEVEL = 3);           //INFO�������INFO��Ϣ + DEBUG��Ϣ + ERROR��Ϣ��
    {$ENDREGION}

    {$REGION '�ṹ��'}
    LPUSB_CAMERA_DEVICE_INFO_EXTEN = ^USB_CAMERA_DEVICE_INFO_EXTEN;
    USB_CAMERA_DEVICE_INFO_EXTEN = RECORD
        nIndex      :   INTEGER;
        cDevPath    :   ARRAY[0..MAX_PATH-1] of BYTE;
        cDevName    :   ARRAY[0..MAX_PATH-1] of BYTE;
        bHaveAudio  :   BYTE;
        byRes       :   ARRAY[0..30] of BYTE;
    end;

    LPUSB_CAMERA_CONFIG = ^USB_CAMERA_CONFIG;
    USB_CAMERA_CONFIG  = RECORD
        pCondBuf    :   POINTER;                        //[in]����������ָ�룬���ʾͨ���ŵ�
        dwCondSize  :   LONGWORD;                       //[in]��pCondBufָ������ݴ�С
        pInBuf      :   POINTER;                        //[in]������ʱ��Ҫ�õ���ָ��ṹ���ָ��\
        dwInSize    :   LONGWORD;                       //[in], pInBufָ������ݴ�С
        pOutBuf     :   POINTER;                        //[out]����ȡʱ��Ҫ�õ���ָ��ṹ���ָ�룬�ڴ����ϲ����
        dwOutSize   :   LONGWORD;                       //[in]����ȡʱ��Ҫ�õ�����ʾpOutBufָ����ڴ��С��
        byRes       :   ARRAY[0..39] of BYTE;           //����
    end;
    LPUSB_CAMERA_PREVIEW_PARAM = ^USB_CAMERA_PREVIEW_PARAM;
    USB_CAMERA_PREVIEW_PARAM = RECORD
        dwSize      :   LONGWORD;
        dwStreamType:   LONGWORD;                       //��������
        hWindow     :   POINTER;                        //���ھ��
        bUseFD      :   BOOLEAN;                        // �Ƿ����������
        bUseAudio   :   BOOLEAN;                        //�Ƿ�Ԥ����Ƶ
        byRes       :   ARRAY[0..19] of BYTE;           //����
    END;
    LPUSB_CAMERA_CAPTURE_PARAM = ^USB_CAMERA_CAPTURE_PARAM;
    USB_CAMERA_CAPTURE_PARAM =  RECORD
        dwSize      :   LONGWORD;
        dwStreamType:   LONGWORD;
        pBuf        :   POINTER;
        dwBufSize   :   LONGWORD;
        dwDataLen   :   LONGWORD;
        szFilePath  :   ARRAY[0..MAX_PATH-1] of BYTE;   // ͼƬ�ļ��洢·��
        bCaptureFacePic:BOOLEAN;                        // �Ƿ�ץ������ͼƬ
        byRes       :   ARRAY[0..39] of BYTE;           //����
    END;
    LPUSB_CAMERA_SRC_STREAM_CFG = ^USB_CAMERA_SRC_STREAM_CFG;
    USB_CAMERA_SRC_STREAM_CFG = RECORD
        dwStreamType:   INTEGER;                        // ԭʼ��������
        bUseAudio   :   BOOLEAN;                        // �Ƿ�ʹ����Ƶ
        byRes       :   ARRAY[0..3] of BYTE;            //����
    END;
    LPMEDIA_RESOLUTION_INFO = ^MEDIA_RESOLUTION_INFO;
    MEDIA_RESOLUTION_INFO =  RECORD
        dwWidth     :   INTEGER;
        dwHeight    :   INTEGER;
    END;
    {$ENDREGION}

    {$REGION 'dllimport'}
    FUNCTION USBCamera_Init():BOOLEAN;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_SetLogToFile(dwLogLevel:INTEGER;pLogDir:STRING;bAutoDel:BOOLEAN):BOOLEAN;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_Fini():BOOLEAN;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_EnumDevice(lpDevInfoList:POINTER;dwSize:INTEGER):INTEGER;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_SetConfig(handle,dwCommand:INTEGER;lpConfigint:POINTER;dwConfigSize:INTEGER):BOOLEAN;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_GetConfig(handleint,dwCommand:INTEGER;lpConfig:POINTER;dwConfigSize:INTEGER):BOOLEAN;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_OpenDevice(iIndex:INTEGER):INTEGER;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_CloseDevice(iGraphHandle,iIndex:INTEGER):BOOLEAN;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_StartPreview(handle:INTEGER;lpPreviewParam:LPUSB_CAMERA_PREVIEW_PARAM):INTEGER;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_Capture(handle:INTEGER;lpCaptuerParam:LPUSB_CAMERA_CAPTURE_PARAM):BOOLEAN;stdcall;external 'USBCameraSDK.dll';

    FUNCTION USBCamera_GetLastError():INT64;stdcall;external 'USBCameraSDK.dll';
    {$ENDREGION}

implementation

end.