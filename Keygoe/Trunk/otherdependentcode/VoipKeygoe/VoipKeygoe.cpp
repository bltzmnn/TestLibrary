// VoipKeygoe.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include "VoipKeygoe.h"
#include "VoipDeviceRes.h"
#include "VoipLog.h"
#include "VoipEvent.h"
#include "VoipString.h"
#include <io.h>
#include <exception>
#include "VoipToneCfg.h"

#include <time.h>

#pragma comment(lib, ".\\Lib\\DJacsAPI.lib")

extern int				g_iTotalTrunkOpened;
extern StartCallIn		StartCallInState[TRUNK_NUM_MAX];
//extern TYPE_XMS_DSP_DEVICE_RES_DEMO	AllDeviceRes[MAX_DSP_MODULE_NUMBER_OF_XMS];
extern TYPE_XMS_DSP_DEVICE_RES_DEMO	AllDevice;
extern int					g_TrunkFlg;

extern ACSHandle_t			g_acsHandle;
extern int					g_iTotalModule;		

extern DJ_S8				MapTable_Module[2]; //MAX_DSP_MODULE_NUMBER_OF_XMS

extern TYPE_CHANNEL_MAP_TABLE	MapTable_Trunk[MAX_TRUNK_NUM_IN_THIS_DEMO];

extern TYPE_CHANNEL_MAP_TABLE	MapTable_Voice[MAX_TRUNK_NUM_IN_THIS_DEMO];

//char	cfg_VocPath[128] = "C:\\DJKeygoe\\Samples\\XMSDemoFlat\\prompt";

extern char g_SendFax_info[255];
extern char g_RecvFax_info[255];

//����¼����ʾ
extern int  g_SendFax_RecordFlg;
extern int  g_RecvFax_RecordFlg;


BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	switch( ul_reason_for_call ) 
    { 
        case DLL_PROCESS_ATTACH:
			// Initialize once for each new process.
			// Return FALSE to fail DLL load.
            break;
        case DLL_THREAD_ATTACH:
			// Do thread-specific initialization.
            break;
        case DLL_THREAD_DETACH:
			// Do thread-specific cleanup.

            break;
        case DLL_PROCESS_DETACH:
			// Perform any necessary cleanup.
			AddLog("DllMain end", 1);
            break;
    }
    return TRUE;
}

int InitKeygoeSystem(const char* configFile)
{
	int iRet  = 1 ;
	try
	{	
		iRet = InitSystem(configFile);
	}catch (exception &e) 
	{
		char ex[255] = {0};
		sprintf(ex, e.what());
		AddMsg(ex);
		AddLog("raise InitKeygoeSystem %d", 1);
	}
	return iRet;
}

int ExitKeygoeSystem()
{
	try
	{
		ExitSystem();
		Sleep(2000);
	}catch (exception &e) 
	{
		char ex[255] = {0};
		sprintf(ex, e.what());
		AddMsg(ex);
		AddLog("raise ExitKeygoeSystem %d", 1);
	}
	return 1;
}

int ClearTrunk(const int iTrunk)
{
	int iRet = -1;	
	TRUNK_STRUCT* pOneTrunk =  NULL;

	AddLog("ClearTrunk iTrunk is %d", iTrunk);
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);
	if (pOneTrunk->State != TRK_FREE || pOneTrunk->iLineState != DCS_FREE)
	{
		ResetTrunk(pOneTrunk);
	}
	int i = 0;
	int seconds = 60;
	while (i++ < seconds)
	{
		if (pOneTrunk->State == TRK_FREE && pOneTrunk->iLineState == DCS_FREE)
		{
			iRet = 1;
			break;
		}
		Sleep(1000);
	}
	return iRet;
}

/*
���iTrunk�Ƿ�׼����
*/
int WaitTrunkReady()
{
	AddLog("WaitTrunkReady ", 1);
	int count = 2;
	int i = 0;
	while (i++ < 30)
	{
		if (g_iTotalTrunkOpened >= count)
		{
			break;
		}
		 Sleep(1000);
	}
	if (g_iTotalTrunkOpened < count)
	{
		AddLog("CheckTrunkReady fial times is %d", i);
		return -1;
	}
	
	//ǰ��̶�count = 2, �ٵ�5�룬��������trunk����OK
	Sleep(5000);

	AddLog("g_TrunkFlg is %d", g_TrunkFlg);
	return g_TrunkFlg;
}

int CheckTrunkReady(const int iTrunk)
{
	int iBit = 0;
	if (iTrunk > 15 || iTrunk < 0) return -1;

	iBit = (1 << iTrunk);
	if (iBit != (iBit & g_TrunkFlg))
	{
		AddLog("CheckTrunkReady error iTrunk is %d", iTrunk);
		return -1;
	}else
	{
		return 1;
	}
}
/*
����ժ��
*/
int	CallOutOffHook(const int iTrunk)
{	
	int				iRet = -1;
	DeviceID_t		FreeTrkDeviceID;
	DeviceID_t		FreeVocDeviceID;
	TRUNK_STRUCT	*pLinkTrunk = NULL;
	RetCode_t		r;
	char			MsgStr[256];
	int				iRCode;

	AddLog("CallOutOffHook iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	iRCode = GetOneFreeTrunk ( iTrunk,  &FreeTrkDeviceID );

	if ( iRCode >= 0 )
	{
		pLinkTrunk = &M_OneTrunk(FreeTrkDeviceID);

		// ====================Added for Analog Trunk
		if ( FreeTrkDeviceID.m_s16DeviceMain == XMS_DEVMAIN_INTERFACE_CH &&
			FreeTrkDeviceID.m_s16DeviceSub == XMS_DEVSUB_ANALOG_TRUNK )
		{
			if ( SearchOneFreeVoice ( pLinkTrunk,  &FreeVocDeviceID ) >= 0 )
			{
				pLinkTrunk->VocDevID = FreeVocDeviceID;
				M_OneVoice(FreeVocDeviceID).UsedDevID = pLinkTrunk->deviceID; 

				My_DualLink(&FreeTrkDeviceID,&FreeVocDeviceID);
				SetGtd_AnalogTrunk(&FreeVocDeviceID); 
			}
			else
			{
				sprintf ( MsgStr, "No VoiceDevice is Free, SearchOneFreeVoice Failed!");
				AddMsg( MsgStr );
				return iRet;
			}
		}

		r = XMS_ctsMakeCallOut ( g_acsHandle, &FreeTrkDeviceID, "888", "888", NULL );
		if ( r <= 0 )
		{
			sprintf ( MsgStr, "XMS_ctsMakeCallOut() FAIL! ret = %d", r );
			AddMsg ( MsgStr );
			return iRet;
		}
		Change_State ( pLinkTrunk, TRK_SIM_CALLOUT );
	}
	else
	{
		sprintf ( MsgStr, "FAIL! No OneFreeTrunk");
		AddMsg ( MsgStr );
		return iRet;
	}	
	
	//�ȴ�ժ���ɹ���Ϣ
	int i = 0;
	while (i++ < 5) //5��
	{
		if (pLinkTrunk->State == TRK_SIM_ANALOG_OFFHOOK)
		{
			iRet = 1;
			AddLog("wait callout offhook ok %d", i);	
			break;
		}
		else if (pLinkTrunk->State == TRK_FAIL)
		{			
			AddLog("wait callout offhook ok %d", i);	
			iRet =  -1;
			break;
		}
		Sleep(1000);
	}
	return iRet;
}

int	Dial(const int iTrunk, const int iLen, const char* CallNumber)
{
	int iRet  = -1;
	TRUNK_STRUCT* pOneTrunk = NULL;		
	char TmpStr[255] = {0};	
	RetCode_t r;
	
	AddLog("Dial iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);
	
	if (pOneTrunk->iLineState != DCS_CONNECT)
	{
		AddLog("cur Linkstate is %d,can not Dial", pOneTrunk->iLineState);
		return iRet;
	}	
	//log
	DeviceID_t*  pSrcDevice = NULL;
	pSrcDevice = &(pOneTrunk->VocDevID);
	AddLog (GetString_DeviceMain(pSrcDevice->m_s16DeviceMain),3 );

	r = XMS_ctsSendIOData(g_acsHandle, 
							&pOneTrunk->VocDevID,
							XMS_IO_TYPE_DTMF,
							iLen,
							(void*)CallNumber);
	if( r <= 0 )
	{
		AddLog( "dial fail %d", r);
		ResetTrunk(pOneTrunk);//,pAcsEvt);
		return iRet;
	}
	Change_State(pOneTrunk, TRK_SIM_ANALOG_DIALING);

	//�жϲ����Ƿ����
	int i = 0;
	while (i++ < 5) //5��
	{
		if (pOneTrunk->State == TRK_SIM_ANALOG_DIAL_OK)
		{
			AddLog("Dial ok seconds %d", i);
			iRet = 1;
			break;
		}	
		Sleep(1000);
	}
	return iRet;
}

/*
����������ݵ�buf
*/
int ClearRecvData(const int iTrunk)
{
	TRUNK_STRUCT* pOneTrunk =  NULL;

	AddLog("ClearRecvData iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	pOneTrunk->DtmfCount = 0;
	pOneTrunk->DtmfBuf[0] = 0;

	return 1;
}
/*�������� ����������Ƿ��ͳɹ�
DTMF
*/
int SendData(const int iTrunk, const char* dtmf)
{
	int iRet = -1;
	TRUNK_STRUCT* pOneTrunk =  NULL;
	TRUNK_STRUCT* pDestTrunk =  NULL;
	

	AddLog("SendData iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);	

	char Tmpstr[255] = {0};
	sprintf(Tmpstr, "senddata is %s", dtmf);
	AddMsg(Tmpstr);
	
	//ʲô״̬�ſ��Է����� 
	if (pOneTrunk->iLineState != DCS_CONNECT)
	{
		AddLog("Linkstate is %d��can not send data", pOneTrunk->iLineState);
		return iRet;
	}
	
	Sleep(100);
	//���Զ�END

	AddLog("send data vocDev is %d" , (pOneTrunk->VocDevID).m_s16ChannelID);
	
	int r = PlayDTMF(&pOneTrunk->VocDevID, dtmf);
	if (r <= 0)
	{
		AddLog("PlayDTMF fail %d", r);
		return iRet;
	}
	Change_State(pOneTrunk, TRK_CALL_SEND_DATA);

	//�ȴ����ݷ������
	int i = 0;
	while (i++ < 10) //10��
	{
		if (pOneTrunk->State == TRK_CALL_SEND_OK)
		{
			AddLog("SendData ok %d", i);
			iRet = 1;
			break;
		}	
		Sleep(1000);
	}
	return iRet;	
}
/*
��ȡ�յ�������
*/
char* GetRecvData(const int iTrunk, const int ilen, const int seconds)
{
	int iRet = -1;
	TRUNK_STRUCT* pOneTrunk =  NULL;
	char buf[255] = {0};
	char info[255] = {0};
	int iNeedLen = 1; //����һ��

	AddLog("GetRecvData iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return "";
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	Sleep(1000);
	sprintf(info, "GetRecvData:%s, size is %d", pOneTrunk->DtmfBuf, pOneTrunk->DtmfCount);
	AddMsg(info);
	
	return pOneTrunk->DtmfBuf;	
}

/*��鵱ǰ�Ƿ���TRK_CALL_IN�¼��������״̬*/
int CheckCallIn(const int iTrunk, const int seconds /*= 10*/)
{
	int iRet = -1;	
	TRUNK_STRUCT* pOneTrunk =  NULL;
	
	AddLog("CheckCallIn iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);
	
	int i = 0;
	while (i++ < seconds)
	{
		if (pOneTrunk->State == TRK_CALL_IN)
		{
			iRet = 1;
			AddLog("CheckCallIn ok times %d", i);
			break;
		}	
		Sleep(1000);
	}
	return iRet;
}

/*����ժ��
���ж�ժ���Ƿ�ɹ�*/
int CallInOffHook(const int iTrunk)
{
	int iRet = -1;	
	TRUNK_STRUCT* pOneTrunk =  NULL;
	RetCode_t r;

	AddLog("CallInOffHook iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	r = XMS_ctsAlertCall ( g_acsHandle, &pOneTrunk->deviceID, NULL );	
	if (r <= 0)
	{
		AddLog("XMS_ctsAlertCall fail %d", r);
		return iRet;
	}
	r = XMS_ctsAnswerCallIn ( g_acsHandle, &pOneTrunk->deviceID, NULL );
	if (r <= 0)
	{
		AddLog("XMS_ctsAlertCall fail %d", r);
		return iRet;
	}	
	Change_State ( pOneTrunk, TRK_CALL_IN_WAIT_ANSWERCALL );

	//�ж�ժ���Ƿ����
	int i = 0;
	while (i++ < 5) //5��
	{
		if (pOneTrunk->State == TRK_CALL_IN_LINKOK)
		{
			AddLog("CallInOffHook ok times %d", i);
			iRet = 1;
			break;
		}	
		Sleep(1000);
	}
	return iRet;
}

/*
��һ�β�����ɺ� GET��ȡ
*/
int GetCallInRingTimes(const int iTrunk, const int seconds/* = 30000*/)
{
	int iTimes = 0;
	TRUNK_STRUCT* pOneTrunk =  NULL;

	AddLog("GetCallInRingTimes iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	//�ж���������Ƿ���� ������ȫ����ô��#TODO 
	int i = 0;
	while (i++ < seconds) //
	{
		//�����峬ʱ���豸�Զ���ΪDCS_FREE
		if (pOneTrunk->iLineState != DCS_CALLIN)
		{
			AddLog( "GetCallInRingTimes seconds is %d", i);
			break;
		}	
		Sleep(1000);
	}
	if (i >= seconds)
	{
		AddLog("seconds (%d) is not big ", seconds);
		return -1;
	}

	iTimes = StartCallInState[iTrunk].RingTimes;
	AddLog( "ALL RingTimes is: %d", iTimes);
	return iTimes;
}

int ClearCall(const int iTrunk)
{
	int iRet = -1;
	TRUNK_STRUCT* pOneTrunk =  NULL;
	RetCode_t r ;
	
	AddLog( "ClearCall iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);	

	//�ϲ� �κ�״̬�¶����Թһ�������������жϣ����ⲻ��Ҫ�Ĺһ����� modified by jias 20131211
	if (DCS_FREE == pOneTrunk->iLineState) 
	{
		AddLog("Cur State is DCS_FREE, not need clear.", 1);
		if (pOneTrunk->State != TRK_FREE)
		{
			AddLog("Cur State is not TRK_FREE, reset to TRK_FREE", 1);
			Change_State(pOneTrunk, TRK_FREE);
		}
		return 1;
	}
	r = XMS_ctsClearCall ( g_acsHandle, &pOneTrunk->deviceID, 0, NULL );
	if (r <= 0)
	{
		AddLog("XMS_ctsClearCall fial %d", r);
		return iRet;
	}
	Change_State ( pOneTrunk, TRK_HANGUP );
	
	//�жϹһ��Ƿ����
	int i = 0;
	while (i++ < 60) //5��
	{
		if (pOneTrunk->iLineState == DCS_FREE) //�����һ�֮����callin modified 20131220
		{
			if (pOneTrunk->State != TRK_FREE)
			{
				AddLog("after XMS_ctsClearCall State is not TRK_FREE, reset to TRK_FREE", 1);
				Change_State(pOneTrunk, TRK_FREE);
			}
			iRet = 1;
			break;
		}	
		Sleep(1000);
	}	
	if (iRet < 0)
	{
		AddLog("ClearCall err %d", i);
		AddLog("State is %d", pOneTrunk->State );
		AddLog("iLineState is %d", pOneTrunk->iLineState );
	}
	else
	{
		AddLog("ClearCall OK %d", i);
	}
	return iRet;
}

int GetTrunkState(const int iTrunk)
{
	TRUNK_STRUCT* pOneTrunk =  NULL;
	char TmpStr[255] = {0};
	
	AddLog("GetTrunkState Trunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	GetString_State(TmpStr, pOneTrunk->State);
	AddLog(TmpStr, 1);
	
	return pOneTrunk->State;
}

int SetTrunkStateToSendData(const int iTrunk)
{
	TRUNK_STRUCT* pOneTrunk =  NULL;
		
	AddLog("SetTrunkState Trunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	Change_State(pOneTrunk, TRK_CALL_SEND_DATA);	
	return 1;
}

int GetTrunkLinkState(const int iTrunk)
{
	TRUNK_STRUCT* pOneTrunk =  NULL;
	char TmpStr[255] = {0};
	
	AddLog("GetTrunkLinkState Trunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);
	
	GetString_LineState(TmpStr, pOneTrunk->iLineState);
	AddLog(TmpStr, 1);

	return pOneTrunk->iLineState;

}

int SendFax_prepare(const int iTrunk)
{
	int iRet				= -1;
	DeviceID_t				FreeVocDeviceID_ForFax;
	DeviceID_t				FreeFaxDeviceID;
	TRUNK_STRUCT			* pOneTrunk =  NULL;
	char					MsgStr[255] = {0};

	AddLog("SendFax_prepare Trunk is %d", iTrunk);	
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	if ( SearchOneFreeFax ( &FreeFaxDeviceID ) >= 0 )
	{
		
		if ( ( SearchOneFreeVoice ( pOneTrunk , &FreeVocDeviceID_ForFax) ) >= 0 )
		{
					
			// free the original Voc Device
			My_DualUnlink ( &pOneTrunk->deviceID, &pOneTrunk->VocDevID );
			FreeOneFreeVoice ( &pOneTrunk->VocDevID );

			memset ( &M_OneVoice(pOneTrunk->VocDevID).UsedDevID, 0, sizeof(DeviceID_t) );		// 0: didn't alloc Device
			memset ( &pOneTrunk->VocDevID, 0, sizeof(DeviceID_t) );		// 0: didn't alloc Device

			// remember now Voc & Fax Device
			pOneTrunk->VocDevID = FreeVocDeviceID_ForFax;
			M_OneVoice(FreeVocDeviceID_ForFax).UsedDevID = pOneTrunk->deviceID; 
			pOneTrunk->FaxDevID = FreeFaxDeviceID;
			M_OneFax(FreeFaxDeviceID).UsedDevID = pOneTrunk->deviceID; 

			My_DualLink ( &pOneTrunk->deviceID, &pOneTrunk->VocDevID );	

			//�޸�ΪECMģʽ
			SetFaxEcm(&pOneTrunk->FaxDevID, XMS_FAX_ECM_MODE_TYPE_ECM);
			
			iRet = 1;
		}
		else
		{
			FreeOneFax ( &FreeFaxDeviceID );
			AddLog("SearchOneFreeVoice error", 1);
			return iRet;
		}
	}
	else
	{
		AddLog("SearchOneFreeFax error", 1);
		return iRet;
	}
	return iRet;
}

int SendFax(const int iTrunk, 
			const int iBps, 
			char* filename, 
			const int seconds, 
			char*& info,
			const int recordflg,
			char* recordfilename_send/* = NULL*/,
			char* recordfilename_recv/* = NULL*/)
{
	int						iRet = -1;
	RetCode_t				r;	
	TRUNK_STRUCT			* pOneTrunk =  NULL;
	char					MsgStr[255] = {0};


	AddLog("SendFax Trunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);
	
	if (SetFaxBps(&pOneTrunk->FaxDevID, iBps) < 0)
	{
		AddLog("SendFax:SetFaxBps fail", 1);
		return iRet;
	}
	// add ¼��test
	if ( recordflg > 0)
	{		
		g_SendFax_RecordFlg = 1; //¼����ʾ

		RecordProperty_t	recordProperty;	
		DeviceID_t			FreeVocDeviceID_ForFax1;
		SearchOneFreeVoice (  pOneTrunk , &FreeVocDeviceID_ForFax1);
		//��¼
		pOneTrunk->VocDevIDRecordLinkVoc = FreeVocDeviceID_ForFax1;
		M_OneVoice(pOneTrunk->VocDevIDRecordLinkVoc).UsedDevID = pOneTrunk->deviceID; 
		r = XMS_ctsLinkDevice ( g_acsHandle, &(pOneTrunk->VocDevID), &(pOneTrunk->VocDevIDRecordLinkVoc), NULL ); 
		AddLog( "send XMS_ctsLinkDevice return ss is %d ", r);

		recordProperty.m_u8TaskID = (DJ_U8)(GetTickCount() % 128);
		recordProperty.m_s8IsMixEnable = 1;

		recordProperty.m_u8EncodeType = XMS_Alaw_type;
		recordProperty.m_u8SRCMode = XMS_SRC_8K;
		recordProperty.m_u8StopMode = XMS_Normal_Stop;
		recordProperty.m_s8IsAppend = 0;

		recordProperty.m_MixerControl.m_u8SRC1_Ctrl  = XMS_MIXER_FROM_INPUT;
		recordProperty.m_MixerControl.m_u16SRC_ChID1 = FreeVocDeviceID_ForFax1.m_s16ChannelID;
		recordProperty.m_MixerControl.m_u8SRC2_Ctrl  = XMS_MIXER_FROM_NULL;
		recordProperty.m_MixerControl.m_u16SRC_ChID2 = 0;
		strcpy(recordProperty.m_s8FileName, recordfilename_send);

		recordProperty.m_u32MaxSize = 0;
		recordProperty.m_u32MaxTime = 0;

		r = XMS_ctsRecord ( g_acsHandle, &FreeVocDeviceID_ForFax1, &recordProperty, NULL );
		AddLog( "send XMS_ctsRecord return is %d ", r);

		//¼����һ��ͨ�� 
		RecordProperty_t	recordProperty2;
		DeviceID_t			FreeVocDeviceID_ForFax2;

		SearchOneFreeVoice (  pOneTrunk , &FreeVocDeviceID_ForFax2);
		//��¼
		pOneTrunk->VocDevIDRecordLinkTrunk = FreeVocDeviceID_ForFax2;
		M_OneVoice(pOneTrunk->VocDevIDRecordLinkTrunk).UsedDevID = pOneTrunk->deviceID; 
		//r = XMS_ctsLinkDevice ( g_acsHandle, &(pOneTrunk->deviceID), &(pOneTrunk->VocDevIDRecordLinkTrunk), NULL ); 
		//AddLog( "send XMS_ctsLinkDevice return sr is %d ", r);

		recordProperty2.m_u8TaskID = (DJ_U8)(GetTickCount() % 128);
		recordProperty2.m_s8IsMixEnable = 1;

		recordProperty2.m_u8EncodeType = XMS_Alaw_type;
		recordProperty2.m_u8SRCMode = XMS_SRC_8K;
		recordProperty2.m_u8StopMode = XMS_Normal_Stop;
		recordProperty2.m_s8IsAppend = 0;
		//¼�� �ֿ� 20131216
		recordProperty2.m_MixerControl.m_u8SRC1_Ctrl  = XMS_MIXER_FROM_INPUT;
		recordProperty2.m_MixerControl.m_u16SRC_ChID1 = (pOneTrunk->VocDevID).m_s16ChannelID;//FreeVocDeviceID_ForFax2.m_s16ChannelID;
		recordProperty2.m_MixerControl.m_u8SRC2_Ctrl  = XMS_MIXER_FROM_NULL; 
		recordProperty2.m_MixerControl.m_u16SRC_ChID2 = 0;
		strcpy(recordProperty2.m_s8FileName, recordfilename_recv);

		recordProperty2.m_u32MaxSize = 0;
		recordProperty2.m_u32MaxTime = 0;

		r = XMS_ctsRecord ( g_acsHandle, &FreeVocDeviceID_ForFax2, &recordProperty2, NULL );
		AddLog( "recv XMS_ctsRecord return is %d ", r);
		
	}
	//add end
	
	r = XMS_ctsSendFax ( g_acsHandle, 
							&pOneTrunk->FaxDevID,
							&pOneTrunk->VocDevID,
							filename, 
							"DJ83636988", 
							NULL );
	if ( r < 0 )
	{
		sprintf ( MsgStr, "XMS_ctsSendFax ( %s ) Fail! ret = %d", filename, r );
		AddMsg ( MsgStr );
		return iRet;
	}			
	Change_State ( pOneTrunk, TRK_FAX_SEND );			
	//�ȴ��������
	int i = 0;
	while ((i++ < seconds) || (seconds == 0))
	{
		if (pOneTrunk->State != TRK_FAX_SEND)
		{
			if (pOneTrunk->State == TRK_FAX_SEND_ERROR)
			{
				iRet = -1;
			}
			else if (pOneTrunk->State == TRK_FAX_SEND_OK)
			{
				iRet = 1;
			}
			else
			{
				AddLog( "error:SendFax end state is %d", pOneTrunk->State);
			}
			break;
		}
		Sleep(1000);
	}	

	//���ڷ� ��ֹͣ
	if (pOneTrunk->State == TRK_FAX_SEND)
	{
		AddLog("XMS_ctsStopSendFax call", 1);
		r = XMS_ctsStopSendFax ( g_acsHandle, 
							&pOneTrunk->FaxDevID,
							NULL );
		if ( r < 0 )
		{
			sprintf ( MsgStr, "XMS_ctsStopSendFax Fail! ret = %d", r );
			AddMsg ( MsgStr );
			return -1;
		}		
	}
	AddLog( "SendFax times is %d", i);
	
	info = g_SendFax_info;
	return iRet;
}
int RecvFax_prepare(const int iTrunk)
{
	int iRet = -1;
	DeviceID_t				FreeVocDeviceID_ForFax;
	DeviceID_t				FreeFaxDeviceID;
	TRUNK_STRUCT* pOneTrunk =  NULL;
	char MsgStr[255] = {0};

	AddLog("RecvFax_prepare Trunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	if ( SearchOneFreeFax ( &FreeFaxDeviceID ) >= 0 )
	{
		if ( ( SearchOneFreeVoice ( pOneTrunk , &FreeVocDeviceID_ForFax) ) >= 0 )
		{				
			// free the original Voc Device
			My_DualUnlink ( &pOneTrunk->deviceID, &pOneTrunk->VocDevID );
			FreeOneFreeVoice ( &pOneTrunk->VocDevID );

			memset ( &M_OneVoice(pOneTrunk->VocDevID).UsedDevID, 0, sizeof(DeviceID_t) ); // 0: didn't alloc Device
			memset ( &pOneTrunk->VocDevID, 0, sizeof(DeviceID_t) );		// 0: didn't alloc Device

			// remember now Voc & Fax Device
			pOneTrunk->VocDevID = FreeVocDeviceID_ForFax;
			M_OneVoice(FreeVocDeviceID_ForFax).UsedDevID = pOneTrunk->deviceID; 
			pOneTrunk->FaxDevID = FreeFaxDeviceID;
			M_OneFax(FreeFaxDeviceID).UsedDevID = pOneTrunk->deviceID; 

			My_DualLink ( &pOneTrunk->deviceID, &pOneTrunk->VocDevID );


			//�޸�ΪECMģʽ
			SetFaxEcm(&pOneTrunk->FaxDevID, XMS_FAX_ECM_MODE_TYPE_ECM);
			
			iRet = 1;				
		}
		else
		{
			AddLog("SearchOneFreeVoice error", 1);
			FreeOneFax ( &FreeFaxDeviceID );
		}
	}
	else
	{
		AddLog("SearchOneFreeFax error", 1);	
	}

	return iRet;
}
		
int StartRecvFax(const int iTrunk, 
				 const int iBps, 
				 char* filename,
				 const int recordflg,
				 char* recordfilename_send/* = NULL*/,
				 char* recordfilename_recv/* = NULL*/)
{
	int iRet = -1;
	TRUNK_STRUCT* pOneTrunk =  NULL;

	char MsgStr[255] = {0};
	RetCode_t              r;	
	
	AddLog("StartRecvFax Trunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);
	//check faxdev

	//set �ٶ�
	if (SetFaxBps(&pOneTrunk->FaxDevID, iBps) < 0)
	{
		AddLog("StartRecvFax:SetFaxBps fail", 1);
		return iRet;
	}

	//add ¼��test
	if ( recordflg > 0)
	{
		g_RecvFax_RecordFlg = 1;
		
		RecordProperty_t	recordProperty;		
		DeviceID_t			FreeVocDeviceID_ForFax1;
			
		SearchOneFreeVoice (  pOneTrunk , &FreeVocDeviceID_ForFax1);
		//��¼
		pOneTrunk->VocDevIDRecordLinkVoc = FreeVocDeviceID_ForFax1;
		M_OneVoice(pOneTrunk->VocDevIDRecordLinkVoc).UsedDevID = pOneTrunk->deviceID; 
		r = XMS_ctsLinkDevice ( g_acsHandle, &(pOneTrunk->VocDevID), &(pOneTrunk->VocDevIDRecordLinkVoc), NULL ); 
		AddLog( "recv XMS_ctsLinkDevice return rs is %d ", r);

		recordProperty.m_u8TaskID = (DJ_U8)(GetTickCount() % 128);
		recordProperty.m_s8IsMixEnable = 1;

		recordProperty.m_u8EncodeType = XMS_Alaw_type;
		recordProperty.m_u8SRCMode = XMS_SRC_8K;
		recordProperty.m_u8StopMode = XMS_Normal_Stop;
		recordProperty.m_s8IsAppend = 0;
		//¼�� �ֿ� 20131216
		recordProperty.m_MixerControl.m_u8SRC1_Ctrl  = XMS_MIXER_FROM_INPUT;
		recordProperty.m_MixerControl.m_u16SRC_ChID1 = FreeVocDeviceID_ForFax1.m_s16ChannelID;
		recordProperty.m_MixerControl.m_u8SRC2_Ctrl  = XMS_MIXER_FROM_NULL; 
		recordProperty.m_MixerControl.m_u16SRC_ChID2 = 0;
		strcpy(recordProperty.m_s8FileName, recordfilename_send);


		recordProperty.m_u32MaxSize = 0;
		recordProperty.m_u32MaxTime = 0;

		r = XMS_ctsRecord ( g_acsHandle, &FreeVocDeviceID_ForFax1, &recordProperty, NULL );
		AddLog( "recv XMS_ctsRecord return is %d ", r);
		
		//¼����һ��ͨ�� 
		RecordProperty_t	recordProperty2;				
		DeviceID_t			FreeVocDeviceID_ForFax2;
		
		SearchOneFreeVoice (  pOneTrunk , &FreeVocDeviceID_ForFax2);
		//��¼
		pOneTrunk->VocDevIDRecordLinkTrunk = FreeVocDeviceID_ForFax2;
		M_OneVoice(pOneTrunk->VocDevIDRecordLinkTrunk).UsedDevID = pOneTrunk->deviceID; 
		//r = XMS_ctsLinkDevice ( g_acsHandle, &(pOneTrunk->deviceID), &(pOneTrunk->VocDevIDRecordLinkTrunk), NULL ); 
		//AddLog( "recv XMS_ctsLinkDevice return  rr is %d ", r);
		

		recordProperty2.m_u8TaskID = (DJ_U8)(GetTickCount() % 128);
		recordProperty2.m_s8IsMixEnable = 1;

		recordProperty2.m_u8EncodeType = XMS_Alaw_type;
		recordProperty2.m_u8SRCMode = XMS_SRC_8K;
		recordProperty2.m_u8StopMode = XMS_Normal_Stop;
		recordProperty2.m_s8IsAppend = 0;
		//¼�� �ֿ� 20131216
		recordProperty2.m_MixerControl.m_u8SRC1_Ctrl  = XMS_MIXER_FROM_INPUT;
		recordProperty2.m_MixerControl.m_u16SRC_ChID1 = (pOneTrunk->VocDevID).m_s16ChannelID;//FreeVocDeviceID_ForFax2.m_s16ChannelID;
		recordProperty2.m_MixerControl.m_u8SRC2_Ctrl  = XMS_MIXER_FROM_NULL; 
		recordProperty2.m_MixerControl.m_u16SRC_ChID2 = 0;
		strcpy(recordProperty2.m_s8FileName, recordfilename_recv);

		recordProperty2.m_u32MaxSize = 0;
		recordProperty2.m_u32MaxTime = 0;

		r = XMS_ctsRecord ( g_acsHandle, &FreeVocDeviceID_ForFax2, &recordProperty2, NULL );
		AddLog( "recv XMS_ctsRecord return is %d ", r);
		
	}


	// add  end
	r = XMS_ctsReceiveFax ( g_acsHandle, 
							&pOneTrunk->FaxDevID,
							&pOneTrunk->VocDevID,
							filename, 
							"DJ83636988", 
							NULL );
	if ( r < 0 )
	{
		sprintf ( MsgStr, "XMS_ctsReceiveFax ( %s ) Fail ret = %d !", filename, r );
		AddMsg ( MsgStr );
	}
	iRet = 1;
	
	Change_State ( pOneTrunk, TRK_FAX_RECEIVE );	
	return iRet;
}

int GetRecvFaxResult(const int iTrunk, const int seconds, char*& info)
{
	int iRet = -1;
	TRUNK_STRUCT* pOneTrunk =  NULL;
	
	AddLog("GetRecvFaxResult Trunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	//�ȴ��������
	int i = 0;
	while (i++ < seconds)
	{
		if (pOneTrunk->State != TRK_FAX_RECEIVE)
		{
			if (pOneTrunk->State == TRK_FAX_RECEIVE_ERROR)
			{
				iRet = -1;
			}
			else if (pOneTrunk->State == TRK_FAX_RECEIVE_OK)
			{
				iRet = 1;
			}
			else
			{
				//test
				AddLog( "error:GetRecvFaxResult end state is %d", pOneTrunk->State);
			}
			break;
		}
		Sleep(1000);
	}
	AddLog("GetRecvFaxResult times is %d", i);
	info = g_RecvFax_info;
	return iRet;
}

int SetFlash(const int iTrunk) //�Ĳ�
{
	int iRet = -1;
	TRUNK_STRUCT* pOneTrunk =  NULL;
	RetCode_t r;
	CmdParamData_AnalogTrunkFlash_t   ATrunkFlash;
	
	AddLog("SetFalse iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);	

	ATrunkFlash.m_u8Channel_Enable = 1; //1��ʹ��ͨ�����ܡ�
	ATrunkFlash.m_u8Type = 0;     //0��������ֵ
	ATrunkFlash.m_u8Tx_State = 2; //2��Flash��ģ���м��Ĳ��
	ATrunkFlash.m_u8Rx_State = 0; //0��������ֵ

	r = XMS_ctsSetParam( g_acsHandle, 
						&pOneTrunk->deviceID,  
						ANALOGTRUNK_PARAM_SETFLASH, 
						sizeof(CmdParamData_AnalogTrunkFlash_t), 
						(DJ_Void *)&ATrunkFlash );
	if ( r < 0 )
	{
		AddLog("SetFalse:XMS_ctsSetParam fail r= %d", r);
		pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);	
	}
	else
	{
		AddLog("SetFalse:XMS_ctsSetParam OK", r);
		iRet = 1;
	}
	Sleep(1000);

	return iRet;
}

int SetFlashTime(const int iTimes) //�����Ĳ�ʱ��
{
	int iRet = -1;
	DeviceID_t *pDevice = NULL;
	RetCode_t r;
	CmdParamData_TrunkFlashParam_t   FlashParam;
	
	AddLog("SetFalseTime ", 1);	
	pDevice = &(AllDevice.deviceID);

	FlashParam.m_u8HookFlashTime = iTimes;  // time = iTimes * 20ms

	r = XMS_ctsSetParam( g_acsHandle, 
						pDevice,  
						BOARD_PARAM_SETTRUNKFLASH, 
						sizeof(CmdParamData_TrunkFlashParam_t), 
						(DJ_Void *)&FlashParam );
	if ( r < 0 )
	{
		AddLog("SetFalseTime:XMS_ctsSetParam fail r= %d", r);
	}
	else
	{
		AddLog("SetFalseTime:XMS_ctsSetParam OK", r);
		iRet = 1;
	}
	Sleep(1000);

	return iRet;
}


int SetFaxFile(const int iTrunk, char* filename) //���ô����ļ�
{
	//deviceID ΪFAX �豸
	int iRet = -1;
	TRUNK_STRUCT* pOneTrunk =  NULL;
	RetCode_t r;
	Acs_TransAddFile   TransAddFile;
	
	AddLog("SetFaxFile iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);		

	TransAddFile.m_u32Op = 2;
	memset(TransAddFile.m_strFileName, 0, sizeof(TransAddFile.m_strFileName));
	sprintf(TransAddFile.m_strFileName, filename);

	//	XMS_FAX_M_FILE_SET_TYPE
	r = XMS_ctsSetParam( g_acsHandle, 
						&pOneTrunk->FaxDevID,  
						FAX_PARAM_ADDFAXFILE, 
						sizeof(Acs_TransAddFile), 
						(DJ_Void *)&TransAddFile );
	if ( r < 0 )
	{
		AddLog("SetFaxFile:XMS_ctsSetParam fail r= %d", r);
	}
	else
	{
		AddLog("SetFaxFile:XMS_ctsSetParam OK", r);
		iRet = 1;
	}
	Sleep(300);

	return iRet;
}

int SetFaxBps(DeviceID_t* pFaxDevID, const int iBps )//���ô�������
{
	//deviceID ΪFAX �豸
	int iRet = -1;
	RetCode_t r;
	Acs_SetFaxBps   FaxBps;
	
	AddLog("SetFaxBps ", 1);
	if ( pFaxDevID == NULL)
	{
		AddLog("SetFaxBps: pFaxDevID is null ", 1);
		return iRet;
	}

	switch(iBps) {  //XMS_FAX_BPS_TYPE
	case 2400:
		FaxBps.m_u8BPS = XMS_BPS_2400;
		break;
	case 4800:
		FaxBps.m_u8BPS = XMS_BPS_4800;
		break;
	case 7200:
		FaxBps.m_u8BPS = XMS_BPS_7200;
		break;
	case 9600:
		FaxBps.m_u8BPS = XMS_BPS_9600;
		break;
	case 12000:
		FaxBps.m_u8BPS = XMS_BPS_12000;
		break;
	case 14400:
		FaxBps.m_u8BPS = XMS_BPS_14400;
		break;
	default:		
		FaxBps.m_u8BPS = XMS_BPS_9600;
		break;
	}	
	AddLog("FaxBps.m_u8BPS code is %d", FaxBps.m_u8BPS);
	r = XMS_ctsSetParam( g_acsHandle, 
						pFaxDevID,  
						FAX_PARAM_BPS, 
						sizeof(Acs_SetFaxBps), 
						(DJ_Void *)&FaxBps );
	if ( r < 0 )
	{
		AddLog("SetFaxBps:XMS_ctsSetParam fail r= %d", r);
	}
	else
	{
		AddLog("SetFaxBps:XMS_ctsSetParam OK %d", iBps);
		iRet = 1;
	}
	Sleep(500);
	return iRet;
}

int WaitSomeTone(const int iTrunk, char* Tones, const int milliseconds)
{
	int iRet = -1;	
	TRUNK_STRUCT* pOneTrunk =  NULL;
	RetCode_t r;
	char  c;
	char* p = NULL;

	if (Tones == NULL)
	{
		AddLog("Tones is Null", 1);
		return iRet;
	}
	p = Tones;
	c = *p;

	AddLog("WaitSomeTone iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);	
	
	ResetToneTimes(iTrunk);
	r = XMS_ctsSetDevTimer ( g_acsHandle, 
							&pOneTrunk->deviceID, 
							milliseconds);
	if (r != ACSPOSITIVE_ACK)
	{
		AddLog("WaitSomeTone:XMS_ctsSetDevTimer fail %d", r);
		return iRet;
	}
	
	int i = 0;
	int iSeconds = 300; //���ʱ��5����
	//����Ƿ��յ���
	while (GetToneTimesTimeOut(iTrunk) < 1 && i++ < iSeconds)
	{		
		if (GetToneTimes(iTrunk, c) > 0)
		{
			iRet = 1;
			break;
		}
		Sleep(1000);
	}
	
	//û�г�ʱ �����ʱ��
	r = XMS_ctsSetDevTimer ( g_acsHandle, 
						&pOneTrunk->deviceID, 
						0);
	if (r != ACSPOSITIVE_ACK)
	{
		AddLog("WaitSomeTone:XMS_ctsSetDevTimer clear fail %d", r);
		return -1;
	}

	return iRet;
}

int UpdateTones()
{
	int iRet = -1;
	int iRetCode = -1;
	DeviceID_t *pDevice = NULL;

	
	AddLog("UpdateTones here",1);

	iRetCode =  ReadToneCfg ();
	if (iRetCode != 0 )
	{
		AddLog("ReadToneCfg fial %d", iRetCode);
		return iRetCode;
	}

	pDevice = &(AllDevice.deviceID);
	if ( pDevice != NULL )
	{
		SetGTD_ToneParam(pDevice);
		iRet = 1;
	}
	return iRet;
}

int StartRecord(const int iTrunk, char* filename)
{
	TRUNK_STRUCT* pOneTrunk =  NULL;
	RetCode_t r;
	
	AddLog("startRecord iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);
	
	RecordProperty_t	recordProperty;	
	recordProperty.m_u8SRCMode = XMS_SRC_8K; //�������ݲ�����
	recordProperty.m_u8EncodeType = XMS_Alaw_type; //�������ݱ����ʽ
	recordProperty.m_u8StopMode = XMS_Normal_Stop; //ֹͣ��ʽu32StopMode ??
	recordProperty.m_s8IsAppend = XMS_REC_FILE_TRUNC;

	recordProperty.m_s8IsMixEnable = 1;  //¼�����������ʹ�� 0 ? 1
	recordProperty.m_u8TaskID = (DJ_U8)(GetTickCount() % 128);
	
	recordProperty.m_MixerControl.m_u8SRC1_Ctrl  = XMS_MIXER_FROM_INPUT;
	recordProperty.m_MixerControl.m_u16SRC_ChID1 = pOneTrunk->VocDevID.m_s16ChannelID;
	recordProperty.m_MixerControl.m_u8SRC2_Ctrl  = XMS_MIXER_FROM_NULL;
	recordProperty.m_MixerControl.m_u16SRC_ChID2 = 0;
	strcpy(recordProperty.m_s8FileName, filename);
	
	//test
	char MsgStr[255] = {0};
	sprintf ( MsgStr, "start record file is %s", filename);
	AddMsg ( MsgStr );

	r = XMS_ctsRecord ( g_acsHandle, &pOneTrunk->VocDevID, &recordProperty, NULL );

	if (r != ACSPOSITIVE_ACK)
	{
		AddLog("StartRecord:XMS_ctsRecord  fail %d", r);
		return -1;
	}
	return 1;
}

int StopRecord(const int iTrunk)
{
	TRUNK_STRUCT* pOneTrunk =  NULL;
	RetCode_t r;
	
	AddLog("StopRecord iTrunk is %d", iTrunk);
	if (CheckTrunkReady(iTrunk) < 0) return -1;
	pOneTrunk = &M_OneTrunk(MapTable_Trunk[iTrunk]);

	ControlRecord_t ControlRecord;	
	ControlRecord.m_u32ControlType = XMS_STOP_RECORD; //ֹͣ¼��

	r = XMS_ctsControlRecord ( g_acsHandle, &pOneTrunk->VocDevID, &ControlRecord, NULL );

	if (r != ACSPOSITIVE_ACK)
	{
		AddLog("StopRecord:XMS_ctsControlRecord  fail %d", r);
		return -1;
	}
	return 1;
}

int SetFaxEcm(DeviceID_t* pFaxDevID, const int mode )//���ô���ģʽ
{
	//deviceID ΪFAX �豸
	int iRet = -1;
	RetCode_t r;
	Acs_SetECM   FaxEcm;
	
	AddLog("SetFaxEcm ", 1);
	if ( pFaxDevID == NULL)
	{
		AddLog("SetFaxEcm: pFaxDevID is null ", 1);
		return iRet;
	}

	if ((mode == XMS_FAX_ECM_MODE_TYPE_NORMAL)
		|| (mode == XMS_FAX_ECM_MODE_TYPE_ECM))
	{
		FaxEcm.m_u8FaxECMMode = mode;
		
		AddLog("FaxEcm.m_u8FaxECMMode code is %d", FaxEcm.m_u8FaxECMMode);
		r = XMS_ctsSetParam( g_acsHandle, 
							pFaxDevID,  
							FAX_PARAM_ECM, 
							sizeof(Acs_SetFaxBps), 
							(DJ_Void *)&FaxEcm );
		if ( r < 0 )
		{
			AddLog("SetFaxEcm:XMS_ctsSetParam fail r= %d", r);
		}
		else
		{
			AddLog("SetFaxEcm:XMS_ctsSetParam OK mode is %d", mode);
			iRet = 1;
		}
		Sleep(500);
	}
	return iRet;	
}