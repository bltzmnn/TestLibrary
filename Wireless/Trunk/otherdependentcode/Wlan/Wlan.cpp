/*
	nwf 2012-08-07   update
	1��API���سɹ���ʧ��	ʧ��ʱ����ʹ�� WLanGetDesc ���ʧ��ԭ��
	nwf 2013-01-14   update
	1��������������� ��չ֧�� ��������������name(���������Աʹ����������)
	nwf 2013-01-21
	2��+ unicode ��ssid + desc ֧��

	nwf 2013-03-11
	1  +WLanGetSignalQuality
	
	nwf 2013-03-12
	1  WLanQueryInterface ���� + connection	

	jias 2013-08-23
	1  ���log���
	2  ����errorcode = 6�Ĵ��� 
	3  ����errorcode = 1003�Ĵ��� 
	4  py��ɾ���ظ��ĳ�ʼ������

	jias 2013-09-09
	+ ���query_security_info��query_connection_attributes
*/

#include <windows.h>
#include <stdio.h>
#include <math.h>
#include <string>

#include "Wlanapi.h"
#pragma comment(lib, "wlanapi.lib")

#ifndef DECLSPEC_EXPORT
#define DECLSPEC_EXPORT __declspec(dllexport)
#endif // DECLSPEC_EXPORT BOOL APIENTRY


//------------------------------------------------------------------��-����
#define             BUFFER_SIZE_256      256 
#define             BUFFER_SIZE_1K       1024 
#define             BUFFER_SIZE_4K       (4*BUFFER_SIZE_1K) 


// nwf 2011-09-01;����ֵЭ��; 1=ok; -1=fail
#define				TCL_OK				(int)1
#define				TCL_ERROR			(int)-1
//add 2013-11-08
#define				TCL_DISCONNECT		(int)-2

//jias 2013-08-23
int PRINT_SUCCESS_LOG = (int)1;
int DO_TIMES = 2;

typedef struct tagTArgSetProfile
{
    wchar_t         strProfileXmlContent[BUFFER_SIZE_4K]; 
}TArgSetProfile;

typedef struct tagTArgConnect
{
    DWORD           dwTimeout;
}TArgConnect;

//add by jias 20130905
typedef struct _SecurityStruct  
{  
	_SecurityStruct():success(-1),b(-1),auth(-1),cipher(-1){};
	BOOL    success;
    BOOL    b;  
    int		auth;  
    int		cipher;  
} SecurityStruct, *PSecurityStruct;  

//add by jias 20130905
typedef struct _ConnectionAttrStruct  
{  
	_ConnectionAttrStruct():success(-1),istate(-1),
		signalquality(0),rxrate(-1),txrate(-1)
	{
		wmemset(ssid , 0, 35); //35*2
		wmemset(bssid, 0, 35);
	};
	BOOL    success;
	int			istate;
    wchar_t     ssid[35]; 
	wchar_t		bssid[35];
	int			signalquality;
	int			rxrate;
	int			txrate;
} ConnectionAttrStruct, *PConnectionAttrStruct;  

//--------------------------------------------------------------ȫ�ֱ���
HANDLE                          g_hWLan;
DWORD							g_dwInterfaceNum; 
PWLAN_INTERFACE_INFO_LIST		g_pInterfaceList;
PWLAN_PROFILE_INFO_LIST			g_apProfileList[WLAN_MAX_INTF_NUM];
wchar_t							g_strMsg[BUFFER_SIZE_4K];//log
int								g_nPosMsg;
wchar_t							g_strBuf[BUFFER_SIZE_4K];//return info
DWORD							g_dwInterfaceIndex;
LPWSTR                          g_pstrProfileXmlContent; // get xml 
TArgSetProfile                  g_stArgSetProfile; //cfg xml
wchar_t                         g_strSsid[MAX_PATH]; 
TArgConnect                     g_stArgConnect;


//-----------------------------------------------------------------����
int InitDll();
int ClearDll();
//nwf 2011-07-13;WLan ��Ҫʹ�õĽӿ�
extern "C" __declspec(dllexport) int WLanConnect(wchar_t* ssid, wchar_t* strIndex=L"", int nIndex=-1, int timeout=30); 
extern "C" __declspec(dllexport) int WLanDisconnect(wchar_t* strIndex=L"", int nIndex=-1); 
extern "C" __declspec(dllexport) int WLanSetProfile(wchar_t* content, wchar_t* strIndex=L"", int nIndex=-1); 
//nwf 2011-08-22; +
extern "C" __declspec(dllexport) int WLanGetAvailableNetworkList(wchar_t* strIndex=L"", int nIndex=-1); 
extern "C" __declspec(dllexport) int WLanQueryInterface(wchar_t* strIndex=L"", int nIndex=-1, int opCode=wlan_intf_opcode_interface_state); 
extern "C" __declspec(dllexport) int WLanGetProfile(wchar_t* ssid, wchar_t* strIndex=L"", int nIndex=-1);
extern "C" __declspec(dllexport) int WLanDeleteProfile(wchar_t* ssid, wchar_t* strIndex=L"", int nIndex=-1);
extern "C" __declspec(dllexport) int WLanGetDesc(wchar_t* &pDesc);
extern "C" __declspec(dllexport) int WLanGetRet(wchar_t* &pDesc);
extern "C" __declspec(dllexport) int WLanDeleteProfiles(wchar_t* strIndex=L"", int nIndex=-1);
//nwf 2013-01-21; +
extern "C" __declspec(dllexport) int WLanIndexExist(int nIndex);
//nwf 2013-03-11; +
extern "C" __declspec(dllexport) int WLanGetSignalQuality(wchar_t* ssid, wchar_t* strIndex=L"", int nIndex=-1);
//jias 2013-09-05; +
extern "C" __declspec(dllexport) PSecurityStruct WLanGetSecurityStruct(wchar_t* ssid, wchar_t* strIndex=L"", int nIndex=-1);
extern "C" __declspec(dllexport) PConnectionAttrStruct WLanQueryConnectionAttributes(wchar_t* strIndex=L"", int nIndex=-1);//, int opCode=wlan_intf_opcode_interface_state); 
/*
    ��ʼ�� ȫ�ֱ���
*/
int InitDll()
{
	int			nRet=TCL_ERROR;
	int			nRetApi;
    DWORD		pdwNegotiatedVersion;

    g_hWLan = NULL;
    g_pInterfaceList = NULL;
	wmemset(g_strBuf, 0, BUFFER_SIZE_4K);	
	wmemset(g_strMsg, 0, BUFFER_SIZE_4K);
	g_nPosMsg = 0;
    g_pstrProfileXmlContent = NULL;

	do 
	{	
		/*
dwClientVersion [in] 
The highest version of the WLAN API that the client supports. 

Value Meaning 
1  Client version for Windows XP with SP3 and Wireless LAN API for Windows XP with SP2.
 
2  Client version for Windows Vista and Windows Server 2008
 

  */
		nRetApi = WlanOpenHandle(2, NULL, &pdwNegotiatedVersion, &g_hWLan);
		if (ERROR_SUCCESS != nRetApi)
		{
			break;
		}		
		nRet = TCL_OK;

	} while(0);


	return nRet;
}


int  ClearDll()
{
	int		nRet=TCL_ERROR;

    if (g_pstrProfileXmlContent)
    {
        WlanFreeMemory(g_pstrProfileXmlContent);
        g_pstrProfileXmlContent = NULL;
    }

	if(g_pInterfaceList)
	{
        WlanFreeMemory(g_pInterfaceList);
        g_pInterfaceList = NULL;
	}	

	if (g_hWLan)
	{
		WlanCloseHandle(g_hWLan, NULL);
		g_hWLan = NULL;
	}

	return TCL_OK;
}


__stdcall DllMain(HANDLE hModule, DWORD dwReason, LPVOID lpReserved)
{
 // Perform actions based on the reason for calling.
    switch( dwReason ) 
    { 
        case DLL_PROCESS_ATTACH:
         // Initialize once for each new process.
         // Return FALSE to fail DLL load.

            InitDll();

            
            break;

        case DLL_THREAD_ATTACH:
         // Do thread-specific initialization.
			//MessageBox(0,"DLL_THREAD_ATTACH", "dll",MB_OK);


            break;

        case DLL_THREAD_DETACH:
         // Do thread-specific cleanup.

			//


            break;

        case DLL_PROCESS_DETACH:
         // Perform any necessary cleanup.
			
			ClearDll();

            break;
    }

	return TRUE;
} 
/*

  */
wchar_t*  ANSIToUnicode( const char* cstr )
{
	int  unicodeLen = ::MultiByteToWideChar( CP_ACP,
											0,
											cstr,
											-1,
											NULL,
											0 );  
	wchar_t *  pUnicode = new  wchar_t[unicodeLen];  
	if(!pUnicode)
    {
    	delete []pUnicode;
    }
	wmemset(pUnicode, 0, (unicodeLen));  
	::MultiByteToWideChar( CP_ACP,
							0,
							cstr,
							-1,
							(LPWSTR)pUnicode,
							unicodeLen);  
	return  pUnicode;  
	/*
	pch = (char*)pstSsid->ucSSID;
    pstSsid->ucSSID[pstSsid->uSSIDLength] = NULL;  // make sure null terminate
    DWORD dwNum = MultiByteToWideChar (CP_ACP, 0, pch, -1, NULL, 0);
    wchar_t *pwText;
    pwText = new wchar_t[dwNum];
    if(!pwText)
    {
    	delete []pwText; //never fail
    	pwText = NULL;
    }
    MultiByteToWideChar (CP_ACP, 0, pch, -1, pwText, dwNum);
	*/
}


//;nwf 2011-09-01;����ֵЭ��; 1=ok; -1=fail

int WlanReturn(int nRet)
{
    int     nRetNew=-1;

    if(nRet==TCL_OK)
    {
        nRetNew= 1;
    }

    return nRetNew;
}

int  Wlan_Init()
{
    //init
	wmemset(g_strMsg,0, BUFFER_SIZE_4K);
	g_nPosMsg = 0;
	
	wmemset(g_strBuf,0, BUFFER_SIZE_4K);

	return TCL_OK;
}

/*
	�Ƿ������ϣ����ã�
*/
int QueryInterface(int OpCode, wchar_t* &p, int &len)
{
	int						nRet = TCL_ERROR;
	int						nRetApi;	
    DWORD					dwDataSize;
    VOID*					pData=NULL;
    WLAN_OPCODE_VALUE_TYPE	WlanOpcodeValueType=wlan_opcode_value_type_query_only;
	WLAN_INTERFACE_STATE	stState;
	
	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
		nRetApi = WlanQueryInterface(g_hWLan,
									 &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
									 (WLAN_INTF_OPCODE)OpCode,
									 NULL,
									 &dwDataSize,
									 (PVOID *)&pData,
									 &WlanOpcodeValueType);		
		if (ERROR_SUCCESS != nRetApi)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanQueryInterface_errorcode(%d)", nRetApi);
			
			continue; //do once more
		}
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanQueryInterface");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}

	if (OpCode == wlan_intf_opcode_interface_state)
	{
    	stState = *(WLAN_INTERFACE_STATE*)pData;
    	len = swprintf(p, L"%d", stState); //int ����
    	p[len] = NULL;
	}
	else if (OpCode == wlan_intf_opcode_current_connection) //useless
	{
        WLAN_CONNECTION_ATTRIBUTES attrConn;
        WLAN_ASSOCIATION_ATTRIBUTES * pAttrAsso;
        int nSignalQuality;
        
    	attrConn = *(WLAN_CONNECTION_ATTRIBUTES*)pData;
        pAttrAsso = &(attrConn.wlanAssociationAttributes);
        nSignalQuality = pAttrAsso->wlanSignalQuality;
        nSignalQuality = nSignalQuality/2 - 100;  // 0~100 --> dbm

    	len = swprintf(p, L"%d", nSignalQuality); //int ���� 
    	p[len] = NULL;    		
	}				
    
	nRet = TCL_OK;                      

    if(pData)
    {
        WlanFreeMemory(pData);
        pData = NULL;
    }

	return nRet;
}


/*
	2013-09-05 add
*/
int QueryConnectionAttributes(PConnectionAttrStruct& attr)
{
	int						nRet = TCL_ERROR;
	int						nRetApi;	
	
	//��ǰ��WlanEnumInterfaces	
	PWLAN_INTERFACE_INFO pIfInfo = NULL;
	pIfInfo = (WLAN_INTERFACE_INFO *)&g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex];
	//g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__InterfaceState(%d)", pIfInfo->isState);	
	if (wlan_interface_state_connected != pIfInfo->isState)
	{
		g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__is_not_connected(%d)", pIfInfo->isState);
		
		attr->success = TCL_DISCONNECT;
		return nRet; //#û������
	}
	// If interface state is connected, call WlanQueryInterface
    // to get current connection attributes

	// variables used for WlanQueryInterfaces for opcode = wlan_intf_opcode_current_connection
    PWLAN_CONNECTION_ATTRIBUTES pConnectInfo = NULL;
    DWORD connectInfoSize = sizeof(WLAN_CONNECTION_ATTRIBUTES);	
    WLAN_OPCODE_VALUE_TYPE opCode = wlan_opcode_value_type_invalid;
	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
	
		nRetApi = WlanQueryInterface(g_hWLan,
									 &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
									 wlan_intf_opcode_current_connection,
									 NULL,
									 &connectInfoSize,
									 (PVOID *)&pConnectInfo,
									 &opCode);			
		if (ERROR_SUCCESS != nRetApi)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanQueryInterface_errorcode(%d)", nRetApi);
			
			continue; //do once more
		}
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanQueryInterface");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}

	wchar_t * pTmp = NULL;
	attr->istate = pConnectInfo->isState;
	DOT11_SSID dot_ssid = pConnectInfo->wlanAssociationAttributes.dot11Ssid;
	dot_ssid.ucSSID[dot_ssid.uSSIDLength] = NULL;
	pTmp = ANSIToUnicode((char*)dot_ssid.ucSSID);
	swprintf(attr->ssid, pTmp);
	if (pTmp)
	{
		delete[] pTmp;
		pTmp = NULL;
	}
	//
	int nPos = 0;
	for (int k = 0; k < sizeof(pConnectInfo->wlanAssociationAttributes.dot11Bssid); k++) 
	{
		if (k == 5)
		{
			//ȥ����\n ���ж��MACô��
			nPos += swprintf(attr->bssid + nPos, L"%.2X", pConnectInfo->wlanAssociationAttributes.dot11Bssid[k]);
		}
		else
		{
			nPos += swprintf(attr->bssid + nPos, L"%.2X-", pConnectInfo->wlanAssociationAttributes.dot11Bssid[k]);
		}
	}
	//
	attr->signalquality = pConnectInfo->wlanAssociationAttributes.wlanSignalQuality;
	attr->rxrate = pConnectInfo->wlanAssociationAttributes.ulRxRate;
	attr->txrate = pConnectInfo->wlanAssociationAttributes.ulTxRate;
	attr->success = TCL_OK;

	nRet = TCL_OK;                      
	return nRet;
}


/*
    �����ʽ: WlanGetProfile -i nIndex(default=0) -s ssid	
*/
int GetProfile(wchar_t* strSsid)
{
	int			        nRet=TCL_ERROR;
	int                 nRetApi;
    DWORD               dwGrantedAccess;  

    if(g_pstrProfileXmlContent)
    {
        WlanFreeMemory(g_pstrProfileXmlContent);
        g_pstrProfileXmlContent = NULL;
    }
   
	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{

        nRetApi = WlanGetProfile(g_hWLan,
                                   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
                                   strSsid,
                                   NULL,
                                   &(g_pstrProfileXmlContent),
                                   NULL,
                                   &dwGrantedAccess);                                
        if(ERROR_SUCCESS != nRetApi)
        {
            g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetProfile_errorcode(%d)", nRetApi);
            
			continue; //do once more
        }
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetProfile");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}
        
	//return
	wmemset(g_strMsg, 0, BUFFER_SIZE_4K);
	g_nPosMsg = 0;

    wcscpy((wchar_t*)g_strMsg, (wchar_t*)g_pstrProfileXmlContent);
	g_nPosMsg += (int)wcslen(g_pstrProfileXmlContent);

	nRet = TCL_OK;
    
    return nRet;    
}

/*
    �����ʽ: WlanDeleteProfile -i nIndex(default=0) -s ssid
	
*/
int DeleteProfile(wchar_t* strSsid)
{
	int			        nRet=TCL_ERROR;
	int                 nRetApi;  
	
	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
        nRetApi = WlanDeleteProfile(g_hWLan,
                                   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
                                   strSsid,
                                   NULL);          
		//modified by jias 2013-1107
		//not found == delete ok
        if(ERROR_SUCCESS !=nRetApi && ERROR_NOT_FOUND != nRetApi)
        {
            g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanDeleteProfile(%s)_errcode(%d)", strSsid, nRetApi);      
			continue; // do once more
        }
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanDeleteProfile(%s)", strSsid);
		}
        bFail = 0;
		break;

    }
	if (bFail)
	{
		return nRet;
	}
	
	nRet = TCL_OK;
    return nRet;
}


/*
	һ��ɾ������ profile
*/
int DeleteProfiles()
{
	int			        nRet=TCL_ERROR;
	int                 nRetApi;             
	PWLAN_PROFILE_INFO_LIST pProfiles=NULL;
    WCHAR*				strSsid=NULL;

	
	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
		nRetApi = WlanGetProfileList(g_hWLan, 
									&(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid), 
									NULL, 
									&pProfiles);
        if(ERROR_SUCCESS !=nRetApi)
        {
            g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetProfileList_errorcdoe(%d)", nRetApi);
            continue; //do once more
        }
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetProfileList");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}
		
	if (0 == pProfiles->dwNumberOfItems)
	{
		nRet = TCL_OK;
	}
	else
	{
		int err_count = 0;
		for(int i=0; i< pProfiles->dwNumberOfItems; i++)
		{
			
			strSsid = pProfiles->ProfileInfo[i].strProfileName;
			
			nRet = DeleteProfile(strSsid); 
			if (nRet == TCL_ERROR)
			{
				err_count ++;
			}
		}
		if (err_count > 0)
		{
			nRet = TCL_ERROR;
		}
		else
		{
			nRet = TCL_OK;
		}
	}

	if (pProfiles)
	{
		WlanFreeMemory(pProfiles);
		pProfiles = NULL;
	}

    return nRet;
}

int GetInterfaceIndex(PWLAN_INTERFACE_INFO_LIST pInterfaceList, wchar_t* index)
{
	int			nRet = -1;
    WLAN_INTERFACE_INFO *pInterfaceInfo;  

    for(int i= 0; i< pInterfaceList->dwNumberOfItems; i++)
    {
        pInterfaceInfo =  &pInterfaceList->InterfaceInfo[i];
        if (wcscmp(pInterfaceInfo->strInterfaceDescription, index) == 0)
        {
            nRet = i;
            break;
        }
    }
    return nRet;
}



/*
	�ж� ���������Ƿ����

	��ʼ��������������
	index  ;����������  �������ӵ� ����(�豸��)

*/
int InitWlan(wchar_t* index)
{
	int			nRet = TCL_ERROR;
	int			nRetApi;
	
	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
		
		//���� ��ÿ���û�����APIʱ�������Ȳ�ѯ�����Ƿ���ã�ʹ����API�� �ͷ�; 
		// Ϊ�˷���ʹ��  ����й©һ��
		if(g_pInterfaceList)
		{
			WlanFreeMemory(g_pInterfaceList);
			g_pInterfaceList = NULL;
		}
		//�������� ���ã�
		nRetApi = WlanEnumInterfaces (g_hWLan, NULL, &g_pInterfaceList);
		if (ERROR_SUCCESS != nRetApi)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanEnumInterfaces_errorcode(%d)", nRetApi);
			// ���ʧЧʱ�����³�ʼ��һ�� //add by jias 20130823
			if (ERROR_INVALID_HANDLE == nRetApi)
			{				
				DWORD pdwNegotiatedVersion;
				int nRet_tmp = WlanOpenHandle(2, NULL, &pdwNegotiatedVersion, &g_hWLan);	
				if (ERROR_SUCCESS != nRet_tmp)
				{				
					g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__Recall_WlanOpenHandle_errorcode(%d)", nRet_tmp);
					
					return nRet;	//��ʧ�ܣ�ûϷ��
				}
				if (PRINT_SUCCESS_LOG)
				{
					g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__Recall_WlanOpenHandle");
				}
			}
			continue; //do once more
		}
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanEnumInterfaces");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}

	g_dwInterfaceNum = g_pInterfaceList->dwNumberOfItems;
	if (0 ==g_dwInterfaceNum)
	{				
		return nRet; //û�п�
	}
	
    //int index ����
    if (g_dwInterfaceIndex == -1)
    {
        g_dwInterfaceIndex = GetInterfaceIndex(g_pInterfaceList, index);
    }		
	if (g_dwInterfaceIndex >= g_dwInterfaceNum )
	{
		g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__Wireless_card_index_error(%d)", g_dwInterfaceIndex);		
		return nRet;
	}
	if (PRINT_SUCCESS_LOG)
	{
		g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__Wireless_card_index(%d)", g_dwInterfaceIndex);
	}
	//
	PWLAN_INTERFACE_INFO pIfInfo = NULL;
	pIfInfo = (WLAN_INTERFACE_INFO *)&g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex];
	g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__InterfaceState(%d)", pIfInfo->isState);	
	
	nRet = TCL_OK;
	
	// del by jias :g_apProfileList û�б������ط�ʹ��
	/* 
	for (int i = 0; i < DO_TIMES; i++)
	{
		
		//��ǰ�������� ���� ��ʼ��
        if(g_apProfileList[g_dwInterfaceIndex])
        {
            WlanFreeMemory(g_apProfileList[g_dwInterfaceIndex]);
            g_apProfileList[g_dwInterfaceIndex] = NULL;
        }
		nRetApi = WlanGetProfileList(g_hWLan,
									&(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
									NULL,
									&(g_apProfileList[g_dwInterfaceIndex]) );

		if (nRetApi != ERROR_SUCCESS)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"WlanGetProfileList_errorcode(%d)", nRetApi);
			//do once more
			continue;
		}
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"WlanGetProfileList");
		}	

		nRet = TCL_OK;
		break;

	} ;
	*/
	return nRet;
}

/*
	����:�Ͽ�����

	�����ʽ= WlanConnect -i dwIndex(default=0)	
*/
int Disconnect()
{
	int			    nRet=TCL_ERROR;
	int             nRetApi;
	
	int bFial = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
        nRetApi = WlanDisconnect(g_hWLan,
                                 &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
                                NULL);
        if(ERROR_SUCCESS != nRetApi)
        {
            g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanDisconnect_errorcode(%d)", nRetApi);
            
			continue; //do once more
        }
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanDisconnect");
		}
        bFial = 0;
		break;
    }
	if (bFial)
	{
		return nRet;
	}
    
	nRet = TCL_OK;		
    return nRet;
}




/*
	����:��������
*/
int Connect()
{
	int							nRet=TCL_ERROR;
	int							nRetApi;
    DOT11_SSID					Dot11Ssid;
	PWLAN_CONNECTION_PARAMETERS pConnectionParameters;
    WCHAR*				        pWCh=NULL;
    int                         nState=0;
    int                         nWaitLoop;
    WCHAR                       buf[1024]={0};
    WCHAR*                      p=(WCHAR*)buf;
    int                         len;        

    pWCh = (wchar_t*)g_strSsid;
	Dot11Ssid.uSSIDLength = wcslen(pWCh);
	for (ULONG i = 0; i < Dot11Ssid.uSSIDLength; i++)
	{
		Dot11Ssid.ucSSID[i] = (UCHAR)(*(pWCh + i) );
	}

	pConnectionParameters = new WLAN_CONNECTION_PARAMETERS;
	memset(pConnectionParameters, 0, sizeof(WLAN_CONNECTION_PARAMETERS));
	pConnectionParameters->wlanConnectionMode = wlan_connection_mode_profile;
	pConnectionParameters->strProfile = pWCh;
	pConnectionParameters->pDot11Ssid = &Dot11Ssid;
	pConnectionParameters->pDesiredBssidList = NULL;
	pConnectionParameters->dot11BssType = dot11_BSS_type_any;
	pConnectionParameters->dwFlags = 0;

	int bFail = 1;
	for (int t = 0; t < DO_TIMES; t++)
	{
    	nRetApi = WlanConnect(g_hWLan,
    							&(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
    							 pConnectionParameters,
    							NULL);
    	if (ERROR_SUCCESS != nRetApi)
    	{
    		g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanConnect_errorcode(%d)", nRetApi);
    		
			continue; //do once more
    	}
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanConnect");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}

    //wait connected
    for (nWaitLoop=0; nWaitLoop<g_stArgConnect.dwTimeout; nWaitLoop++)
    {
        nRet = QueryInterface(wlan_intf_opcode_interface_state, p, len);
        if(TCL_OK != nRet)
        {
            break;
        }

        p[len] = NULL;
        nState = _wtoi(p);
        if (nState ==wlan_interface_state_connected)
        {
        	nRet = TCL_OK;			       		
        	break;
        }
        else
        {
            nRet = TCL_ERROR;
        	Sleep(1000); 
        }
    }    	

    //connect timeout
    if(nWaitLoop == g_stArgConnect.dwTimeout)
    {
        Disconnect();
		g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__Wlan_interface(index=%d)_connect_fail(timeout=%d)", \
			g_dwInterfaceIndex, nWaitLoop);   
	}
	else
	{			
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__Wlan_interface(index=%d)_connect_ok(timeout=%d)", \
				g_dwInterfaceIndex, nWaitLoop); 
		}
	}

	if (pConnectionParameters)
	{
		delete pConnectionParameters;
		pConnectionParameters =NULL;
	}

	return nRet;
}	



/*
	����: set profile
    �����ʽ: WlanSetProfile -i dwIndex(default=0)  content
*/
int SetProfile()
{
	int			    nRet=TCL_ERROR;
	int             nRetApi;
    DWORD           dwReasonCode;
    LPWSTR          pstrProfileXmlContent;

	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
        pstrProfileXmlContent = (LPWSTR)g_stArgSetProfile.strProfileXmlContent;
        nRetApi = WlanSetProfile(g_hWLan,
                                   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
                                   0,
                                   pstrProfileXmlContent,
                                   NULL,
                                   true,
                                   NULL,
                                   &dwReasonCode);                                   
        if(ERROR_SUCCESS !=nRetApi)
        {
            g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanSetProfile_errorcode(%d)", nRetApi);
			
			continue; //do once more
        }
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanSetProfile");
		}
        bFail = 0;
		break;
    }
	if(bFail)
	{
		return nRet;
	}

	nRet = TCL_OK;    
    return nRet;
}


#define EventName(wEvent)  case wEvent: return L#wEvent

wchar_t* GetStateName(int nState)
{
    static wchar_t*   pRet=NULL;

    switch (nState)
    {
        EventName(wlan_interface_state_not_ready);
        EventName(wlan_interface_state_connected);
        EventName(wlan_interface_state_ad_hoc_network_formed);
        EventName(wlan_interface_state_disconnecting);   
        
        EventName(wlan_interface_state_disconnected);
        EventName(wlan_interface_state_associating);
        EventName(wlan_interface_state_discovering);
        EventName(wlan_interface_state_authenticating);          
    }

    return pRet;
}

/*
    ������ʾ SSID �б�

*/
int GetAvailableNetworkList()
{
	int			                    nRet=TCL_ERROR;
	int                             nRetApi;
    WLAN_AVAILABLE_NETWORK_LIST*    pAvailableNetworkList = NULL;   
    int                             nSsidLoop;
    WLAN_AVAILABLE_NETWORK*         pstNetwork;
    DOT11_SSID*                     pstSsid;
    int                             nPos=0;

	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
		nRetApi = WlanScan(g_hWLan,
						   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
						   NULL,
						   NULL,
						   NULL);
		if (ERROR_SUCCESS != nRetApi)
		{    
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanScan_errorcodecode(%d)", nRetApi);
			
			continue; //do once more
		}
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanScan");
		}
		bFail = 0;
		break;
	} 
	if (bFail)
	{
		return nRet;
	}
	Sleep(4000);
	
	bFail = 1;
	for (int t = 0; t < DO_TIMES; t++)
	{
		nRetApi = WlanGetAvailableNetworkList(g_hWLan,
										   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
										   0, //WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES,
										   NULL,
										   &pAvailableNetworkList);
		if(ERROR_SUCCESS != nRetApi)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetAvailableNetworkList_errorcode(%d)", nRetApi);
			
			continue; // do once more
		}
		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, \
				L"__WlanGetAvailableNetworkList(count=%d)", \
				pAvailableNetworkList->dwNumberOfItems);
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}
    //
	wchar_t * pTmp = NULL;
    wmemset(g_strBuf,0, BUFFER_SIZE_4K);
    for(nSsidLoop=0; nSsidLoop<pAvailableNetworkList->dwNumberOfItems; nSsidLoop++)
    {
        pstNetwork = &(pAvailableNetworkList->Network[nSsidLoop]);
        pstSsid = &(pstNetwork->dot11Ssid);
		
        pstSsid->ucSSID[pstSsid->uSSIDLength] = NULL;  // make sure null terminate
		pTmp = ANSIToUnicode((char*)pstSsid->ucSSID);  //new
		//python ��ʽ; \n�����÷ָ�ssidʹ��; nwf 2012-08-21
        nPos += swprintf(g_strBuf+nPos, L"%s\n", pTmp);       
		if (pTmp)
		{
			delete[] pTmp;
			pTmp = NULL;
		}	
    }    
    
    if(pAvailableNetworkList)
    {
        WlanFreeMemory(pAvailableNetworkList);
        pAvailableNetworkList=NULL;
    }

    return TCL_OK;
}

/*
    ʵʱ��� RSSI useless

*/
int GetSignalQuality(wchar_t* ssid)
{
	int			                    nRet=TCL_ERROR;
	int                             nRetApi;
    WLAN_AVAILABLE_NETWORK_LIST*    pAvailableNetworkList = NULL;  
    int                             nSsidLoop;
    WLAN_AVAILABLE_NETWORK*         pstNetwork;
    DOT11_SSID*                     pstSsid;
    int                             nPos=0;
    int                             nSignalQuality = 0;
    bool                            blFind = false;

	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
		nRetApi = WlanScan(g_hWLan,
						   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
						   NULL,
						   NULL,
						   NULL);
		if (ERROR_SUCCESS != nRetApi)
		{    
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanScan_errorcode(%d)", nRetApi);
			
			continue;
		}

		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanScan");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}
	Sleep(4000);
	bFail = 1;
	for (int t = 0; t < DO_TIMES; t++)
	{

		nRetApi = WlanGetAvailableNetworkList(g_hWLan,
										   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
										   0, //WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES,
										   NULL,
										   &pAvailableNetworkList);
		if(ERROR_SUCCESS != nRetApi)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetAvailableNetworkList_errorcode(%d)", nRetApi);
			continue;
		}
		if (PRINT_SUCCESS_LOG)
		{
			//g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetAvailableNetworkList");
			
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, \
				L"__WlanGetAvailableNetworkList(count=%d)", \
				pAvailableNetworkList->dwNumberOfItems);
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}
    //
	wchar_t *pwText = NULL;
    wmemset(g_strBuf,0, BUFFER_SIZE_4K);
    for(nSsidLoop=0; nSsidLoop<pAvailableNetworkList->dwNumberOfItems; nSsidLoop++)
    {
        pstNetwork = &(pAvailableNetworkList->Network[nSsidLoop]);
        pstSsid = &(pstNetwork->dot11Ssid);

        pstSsid->ucSSID[pstSsid->uSSIDLength] = NULL;  // make sure null terminate
    	pwText = ANSIToUnicode((char*)pstSsid->ucSSID);
		//find?
        if (wcscmp(pwText, ssid) == 0)
        {
            blFind = true;
        }        
        if (pwText)
        {
            delete []pwText;
            pwText = NULL;
        }
        if (blFind)
        {
            nSignalQuality = pstNetwork->wlanSignalQuality;
            nSignalQuality = nSignalQuality/2 - 100;  // 0~100 --> dbm

            nPos+=swprintf(g_strBuf+nPos, L"%d", nSignalQuality);
        
			nRet = TCL_OK;
            break;
        }                
    }    
    
    if(pAvailableNetworkList)
    {
        WlanFreeMemory(pAvailableNetworkList);
        pAvailableNetworkList=NULL;
    }
    return nRet;
}

/*
    ʵʱ��� auth cipher �㷨�Ȱ�ȫ��Ϣ

*/
int GetSecurityStruct(wchar_t* ssid, PSecurityStruct& pSecurityStruct)
{
	int			                    nRet=TCL_ERROR;
	int                             nRetApi;
    WLAN_AVAILABLE_NETWORK_LIST*    pAvailableNetworkList = NULL;  
    int                             nSsidLoop;
    WLAN_AVAILABLE_NETWORK*         pstNetwork;
    DOT11_SSID*                     pstSsid;
    int                             nPos=0;
    int                             nSignalQuality = 0;
    bool                            blFind = false;

	int bFail = 1;
	for (int i = 0; i < DO_TIMES; i++)
	{
		nRetApi = WlanScan(g_hWLan,
						   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
						   NULL,
						   NULL,
						   NULL);
		if (ERROR_SUCCESS != nRetApi)
		{    
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanScan_errorcode(%d)", nRetApi);
			
			continue;
		}

		if (PRINT_SUCCESS_LOG)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanScan");
		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}
	Sleep(4000);
	//
	bFail = 1;
	for (int t = 0; t < DO_TIMES; t++)
	{

		nRetApi = WlanGetAvailableNetworkList(g_hWLan,
										   &(g_pInterfaceList->InterfaceInfo[g_dwInterfaceIndex].InterfaceGuid),
										   0, //WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES,
										   NULL,
										   &pAvailableNetworkList);
		if(ERROR_SUCCESS != nRetApi)
		{
			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetAvailableNetworkList_errorcode(%d)", nRetApi);
			continue;
		}
		if (PRINT_SUCCESS_LOG)
		{
			//g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, L"__WlanGetAvailableNetworkList");

			g_nPosMsg += swprintf(g_strMsg + g_nPosMsg, \
				L"__WlanGetAvailableNetworkList(count=%d)", \
				pAvailableNetworkList->dwNumberOfItems);

		}
		bFail = 0;
		break;
	}
	if (bFail)
	{
		return nRet;
	}
	//
	wchar_t *pwText = NULL;
    wmemset(g_strBuf,0, BUFFER_SIZE_4K);
    for(nSsidLoop=0; nSsidLoop<pAvailableNetworkList->dwNumberOfItems; nSsidLoop++)
    {
        pstNetwork = &(pAvailableNetworkList->Network[nSsidLoop]);
        pstSsid = &(pstNetwork->dot11Ssid);

        pstSsid->ucSSID[pstSsid->uSSIDLength] = NULL;  // make sure null terminate    	
    	
		pwText = ANSIToUnicode((char*)pstSsid->ucSSID);
        //find?
        if (wcscmp(pwText, ssid) == 0)
        {
            blFind = true;
        }
        
        if (pwText)
        {
            delete []pwText;
            pwText = NULL;
        }

        if (blFind)
        {
			//get Security code            
			pSecurityStruct->b = pstNetwork->bSecurityEnabled;
			pSecurityStruct->auth = pstNetwork->dot11DefaultAuthAlgorithm;
			pSecurityStruct->cipher = pstNetwork->dot11DefaultCipherAlgorithm;
			//
			pSecurityStruct->success = TCL_OK;
								
			nRet = TCL_OK;
            break;
        }                
    }    
    
    if(pAvailableNetworkList)
    {
        WlanFreeMemory(pAvailableNetworkList);
        pAvailableNetworkList=NULL;
    }
    return nRet;
}


/*
    �ӿڲ�������
    �����ʽ:  
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseSetProfile(wchar_t* content, wchar_t* index)
{
	int			nRet = TCL_ERROR;

	wcscpy((wchar_t*)g_stArgSetProfile.strProfileXmlContent, content);

	nRet = InitWlan(index);

    return nRet;
}	



/*
    �ӿڲ�������
	index ���� int->char*  ����� int �����int��������name 	 
*/
int ParseConnect(wchar_t* ssid, wchar_t* index, int timeout)
{
	int			nRet = TCL_ERROR;
	

    g_stArgConnect.dwTimeout =timeout;
    wcscpy(g_strSsid, ssid);

	//connect
	nRet = InitWlan(index);	


    return nRet;
}	



/*
    �ӿڲ�������
    �����ʽ: 
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseQueryInterface(wchar_t* index)
{
	int			nRet = TCL_ERROR;

	nRet = InitWlan(index);  

    return nRet;
}	

/*
    �ӿڲ�������
    �����ʽ: 
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseGetProfile(wchar_t* ssid, wchar_t* index)
{
	int			nRet = TCL_ERROR;
	

	wcscpy(g_strSsid, ssid);    

	nRet = InitWlan(index);	

    return nRet;
}	



/*
    �ӿڲ�������
    �����ʽ:  
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseDeleteProfile(wchar_t* ssid, wchar_t* index)
{
	int			nRet = TCL_ERROR;
	

	wcscpy(g_strSsid, ssid);    

	nRet = InitWlan(index);	


    return nRet;
}	

/*
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseDeleteProfiles(wchar_t* index)
{
	int			nRet = TCL_ERROR;

	nRet = InitWlan(index);

    return nRet;
}


/*
    �ӿڲ�������
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseDisconnect(wchar_t* index)
{
	int			    nRet=TCL_ERROR;

	nRet = InitWlan(index);
            
    return nRet;
}	


/*
    �ӿڲ�������
    �����ʽ:  
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseGetAvailableNetworkList(wchar_t* index)
{
	int			nRet = TCL_ERROR;
	
	nRet = InitWlan(index);
            
    return nRet;
}	


/*
    �ӿڲ�������
    �����ʽ: 
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseGetSignalQuality(wchar_t* ssid, wchar_t* index)
{
	int			nRet = TCL_ERROR;
	

	wcscpy(g_strSsid, ssid);    

	nRet = InitWlan(index);	

    return nRet;
}

/*
    �ӿڲ�������
    �����ʽ: 
	index ���� int->char*  ����� int �����int��������name 
*/
int ParseGetSecurityStruct(wchar_t* ssid, wchar_t* index)
{
	int			nRet = TCL_ERROR;

	wcscpy(g_strSsid, ssid);    

	nRet = InitWlan(index);	
		
    return nRet;
}



/*
    �ӿ�
	python �����ʽ= Connect(ssid,index=0,timeout=30)
	index ���� int->char*  ����� int �����int��������name 
    strIndex default=""
    nIndex default = -1	
    
*/
int WLanConnect(wchar_t* ssid, wchar_t* strIndex, int nIndex, int timeout)
{
	int			nRet = TCL_ERROR;
    int			pos=0;

	Wlan_Init();
	
	do 
	{	
    	g_dwInterfaceIndex =nIndex;  //default	
        nRet = ParseConnect(ssid, strIndex, timeout);
		if (TCL_OK !=nRet)
		{
			break;
		}	

		nRet = Connect();
		
	} while(0);	

	//nwf 2011-09-01;
    //memset(g_strBuf, 0, BUFFER_SIZE_4K*sizeof(wchar_t));
    //pos += swprintf(g_strBuf+pos, g_strMsg);

	return nRet;
}


/*
    �ӿ�

	python �����ʽ= Disconnect(index=0)
	index ���� int->char*  ����� int �����int��������name 
    strIndex default=""
    nIndex default = -1	
*/
int WLanDisconnect(wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int			pos=0;

	Wlan_Init();
	
	
	do 
	{	
    	g_dwInterfaceIndex =nIndex;  //default	    
        nRet = ParseDisconnect(strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}	
		
		nRet = Disconnect();
		
	} while(0);	
	

	//nwf 2011-09-01;
    //memset(g_strBuf, 0, BUFFER_SIZE_4K*sizeof(wchar_t));
    //pos += swprintf(g_strBuf+pos, g_strMsg);
    
	return nRet;
}

/*
    �ӿ�
    
    �����ʽ:  SetProfile(content, index=0)                   
    index ���� int->char*->wchar_t*  ����� int �����int��������name 
    strIndex default=""
    nIndex default = -1	
*/
int WLanSetProfile(wchar_t* content, wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int			pos =0;

	Wlan_Init();
	
	do 
	{		
    	g_dwInterfaceIndex =nIndex;  //default	    
	    nRet = ParseSetProfile(content, strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}        		

        nRet = SetProfile();  
		
	} while(0);	
	

	//nwf 2011-09-01;
    //memset(g_strBuf, 0, BUFFER_SIZE_4K*sizeof(wchar_t));
    //pos += swprintf(g_strBuf+pos, g_strMsg);
	
	return nRet;
}


/*
    �ӿ�
    
    �����ʽ: GetAvailableNetworkList(index=0)
    index ���� int->char*  ����� int �����int��������name 
    strIndex default=""
    nIndex default = -1    
*/
int WLanGetAvailableNetworkList(wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int			pos =0;

	Wlan_Init();
	
	do 
	{	
    	g_dwInterfaceIndex =nIndex;  //default	
        nRet = ParseGetAvailableNetworkList(strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}
      
        nRet = GetAvailableNetworkList();
		if (TCL_OK !=nRet)
		{
			break;
		}
		
	} while(0);	
	
	//nwf 2011-09-01;
    //memset(g_strBuf, 0, BUFFER_SIZE_4K*sizeof(wchar_t));
    //pos += swprintf(g_strBuf+pos, g_strMsg);

	return nRet;
}

/*
    �ӿ�
    
    �����ʽ: QueryInterface(index=0, opCode=xxx)
	index ���� int->char*  ����� int �����int��������name 
    strIndex default=""
    nIndex default = -1        
*/
int WLanQueryInterface(wchar_t* strIndex, int nIndex, int opCode)
{
	int			nRet = TCL_ERROR;
	int         nState=0;
	wchar_t*    strState;
	int			pos = 0;
	wchar_t     buf[1024]={0};
	wchar_t*    p=(wchar_t*)buf;
    int         len;	
	
	Wlan_Init();

	//add by jias 20130821 
	opCode = wlan_intf_opcode_interface_state;
	
	do 
	{		
    	g_dwInterfaceIndex =nIndex;  //default	
        nRet = ParseQueryInterface(strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}		

        nRet = QueryInterface(opCode, p, len);
		if (TCL_OK !=nRet)
		{
			break;
		}
        //����ļӹ�  code to sting
        if (opCode == wlan_intf_opcode_interface_state)
        {
            p[len]=NULL;
            nState = _wtoi(p);
		    strState =GetStateName(nState);	// int ->str		    
		    swprintf(p, strState);
		    p[wcslen(strState)]=NULL;
        }		
	} while(0);	

    if(TCL_OK == nRet)
    {	        
        pos += swprintf(g_strBuf, p);   
	}	
	
	return nRet;
}

/*
   
*/
PConnectionAttrStruct WLanQueryConnectionAttributes(wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int         nState=0;
	int			pos = 0;
	wchar_t     buf[1024]={0};
	wchar_t*    p=(wchar_t*)buf;

	PConnectionAttrStruct pattr = new ConnectionAttrStruct();

	Wlan_Init();
	
	do 
	{		
    	g_dwInterfaceIndex =nIndex;  //default	
        nRet = ParseQueryInterface(strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}		

        nRet = QueryConnectionAttributes( pattr );
		if (TCL_OK !=nRet)
		{
			break;
		}
        //����ļӹ�
        
		
	} while(0);	
		
	return pattr;
}


/*
    �ӿ�
    
    �����ʽ: GetProfile(ssid, index=0)
    index ���� int->char*  ����� int �����int��������name 	    
    strIndex default=""
    nIndex default = -1    
*/
int WLanGetProfile(wchar_t* ssid, wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int         nState=0;
	int			pos =0;

	Wlan_Init();

	do 
	{		
    	g_dwInterfaceIndex =nIndex;  //default	    
        nRet = ParseGetProfile(ssid, strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}	

        nRet = GetProfile(g_strSsid);
		if (TCL_OK !=nRet)
		{
			break;
		}
		
	} while(0);	
	
	return nRet;
}

/*
    �ӿ�
    
    �����ʽ: DeleteProfile(ssid, index=0)
    index ���� int->char*  ����� int �����int��������name   
    strIndex default=""
    nIndex default = -1    
*/
int WLanDeleteProfile(wchar_t* ssid, wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int         nState=0;
	int			pos =0;

	Wlan_Init();
	
	do 
	{	
    	g_dwInterfaceIndex =nIndex;  //default
        nRet = ParseDeleteProfile(ssid, strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}	

        nRet = DeleteProfile(g_strSsid);
		if (TCL_OK !=nRet)
		{
			break;
		}
		
	} while(0);	

        	
	return nRet;
}



/*
    �ӿ�
    
    �����ʽ: DeleteProfiles(index=0)
    index ���� int->char*  ����� int �����int��������name
    strIndex default=""
    nIndex default = -1
    
*/
int WLanDeleteProfiles(wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int         nState=0;
	int			pos =0;

	Wlan_Init();
	
	do 
	{	
    	g_dwInterfaceIndex =nIndex;  //default
        nRet = ParseDeleteProfiles(strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}		

        nRet = DeleteProfiles();
		if (TCL_OK !=nRet)
		{
			break;
		}
		
	} while(0);	

        	
	return nRet;
}



// ���ظ������� api �ɹ�/ʧ�� ����
int WLanGetDesc(wchar_t* &pDesc)
{
	
	pDesc=g_strMsg;

	return TCL_OK;
}
// ���ظ������� api �ɹ�/ʧ�� ����
int WLanGetRet(wchar_t* &pDesc)
{
	
	pDesc=g_strBuf;

	return TCL_OK;
}

// index ����ô
int WLanIndexExist(int nIndex)
{
	int			nRet = TCL_ERROR;
	int			pos =0;
	
	Wlan_Init();
	
	g_dwInterfaceIndex =nIndex;  //default
    nRet = InitWlan(L"");	

    //return
    //memset(g_strBuf, 0, BUFFER_SIZE_4K*sizeof(wchar_t));
    //pos += swprintf(g_strBuf+pos, g_strMsg);

	return nRet;
}


/*
    �ӿ�
    
    �����ʽ:  
         
    strIndex default=""
    nIndex default = -1    
*/
int WLanGetSignalQuality(wchar_t* ssid, wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int         nState=0;
	int			pos =0;

	Wlan_Init();

	do 
	{		
    	g_dwInterfaceIndex =nIndex;  //default	    
        nRet = ParseGetSignalQuality(ssid, strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}	

        nRet = GetSignalQuality(g_strSsid);
		if (TCL_OK !=nRet)
		{
			break;
		}
		
	} while(0);	

	//nwf 2011-09-01;
    //memset(g_strBuf, 0, BUFFER_SIZE_4K*sizeof(wchar_t));
    //pos += swprintf(g_strBuf+pos, g_strMsg);
	
	return nRet;
}



/*
    �ӿ�
    
    �����ʽ:  
         
    strIndex default=""
    nIndex default = -1    
*/
PSecurityStruct WLanGetSecurityStruct(wchar_t* ssid, wchar_t* strIndex, int nIndex)
{
	int			nRet = TCL_ERROR;
	int         nState=0;
	int			pos =0;

	Wlan_Init();

	PSecurityStruct pSecurityStruct = new SecurityStruct();

	do 
	{		
    	g_dwInterfaceIndex =nIndex;  //default	    
        nRet = ParseGetSecurityStruct(ssid, strIndex);
		if (TCL_OK !=nRet)
		{
			break;
		}	

        nRet = GetSecurityStruct(ssid, pSecurityStruct);
		if (TCL_OK !=nRet)
		{
			break;
		}
		
	} while(0);	

	//nwf 2011-09-01;
    //memset(g_strBuf, 0, BUFFER_SIZE_4K*sizeof(wchar_t));
    //pos += swprintf(g_strBuf+pos, g_strMsg);
	
	return pSecurityStruct;
}


