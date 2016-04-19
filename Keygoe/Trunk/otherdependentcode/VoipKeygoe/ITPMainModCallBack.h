//*****************************************************************************
//Copyright(c)  :  DONJIN CORPORTAION  All Rights Reserved                       
//FileName      :  ITPMainModCallBack.h
//Version       :  1.1                                                              
//Author        :  hewei                                                             
//DateTime      :  2006-05-08 15:00                                           
//Description  :   ITP���س���ص��ӿڶ����ļ�
//*****************************************************************************

#ifndef _ITPMAINMODCALLBACK_H
#define _ITPMAINMODCALLBACK_H

#include "ITPDataDefine.h"
#include "ITPMsgPublic.h"
//#include "ITPLogManager.h"

#define ITP_MANAGE_MODULE_NUM                       1      // ���ù���ģ����Ŀ
#define ITP_MAX_MOD_TYPE_NUM                        128    // ���ģ����
#define ITP_MAX_UNIT_NUM                            128    // ���UNIT��Ŀ
#define ITP_MAX_CH_NUM                              128    // ���ͨ����Ŀ

/************************************************************************/
/*��������:    ��ȡ��ģ���UnitID                                       */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :    ģ��UnitID                                               */
typedef DJ_U8     (*PFUNC_GETSELFUNITID)();
/************************************************************************/

/************************************************************************/
/*��������:    ��ȡ��ģ�������״̬                                     */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :                                                             */
/*             0x01    //ģ���ѳ�ʼ��                                   */ 
/*             0x02    //ģ��������                                     */
/*             0x04    //ģ����ȫ�������ϼ�ģ�����                     */ 
/*             0x08    //ģ���ѱ�����                                   */
/*             0x10    //ģ��������                                     */
/*             0x20    //ģ������ֹͣ                                   */ 
/*             0x40    //��������ģ��                                   */
typedef DJ_U32    (*PFUNC_GETMODSTATE)();
/************************************************************************/

/************************************************************************/
/*��������:    ������ģ�鷢�����ݰ�                                     */
/*�������:                                                             */
/*             u8ModType: Ŀ��ģ������                                  */
/*             u8UnitId : Ŀ��ģ��UnitID                                */
/*             pData    : ���͵�ITP����,����ITP��ͷ                     */
/*�������:    ��                                                       */
/*����ֵ  :    0:�ɹ�; -1:ʧ��                                          */
typedef DJ_S32    (*PFUNC_SENDPACK)(DJ_U8 u8ModType,DJ_U8 u8UnitId,PPKG_HEAD_STRUCT pData);
/************************************************************************/
/************************************************************************/
/*��������:    ������ģ�鷢�����ݰ�                                     */
/*�������:                                                             */
/*             u8ModType: Ŀ��ģ������                                  */
/*             u8UnitId : Ŀ��ģ��UnitID                                */
/*             pData    : ���͵�ITP����,����ITP��ͷ                     */
/*             u8Flag   : ��Ϣ�����ͷ���			                    */
/*�������:    ��                                                       */
/*����ֵ  :    0:�ɹ�; -1:ʧ��                                          */
typedef DJ_S32    (*PFUNC_SENDPACKEX)(DJ_U8 u8ModType,DJ_U8 u8UnitId,PPKG_HEAD_STRUCT pData, DJ_U8 u8Flag);
/************************************************************************/
/************************************************************************/
/*��������:    ������ģ���ط������ݰ�                                   */
/*�������:                                                             */
/*             u8ModType: Ŀ��ģ������                                  */
/*             u8UnitId : Ŀ��ģ��UnitID                                */
/*             pData    : ���͵�ITP����,����ITP��ͷ                     */
/*�������:    ��                                                       */
/*����ֵ  :    0:�ɹ�; -1:ʧ��                                          */
typedef DJ_S32    (*PFUNC_RESENDPACK)(DJ_U8 u8ModType,DJ_U8 u8UnitId,PPKG_HEAD_STRUCT pData);
/************************************************************************/

/************************************************************************/
/*��������:    ��ȡָ��ģ���IP��port                                   */
/*�������:                                                             */
/*             u8ModType: ģ������                                      */
/*             u8UnitId:  ģ���UnitID                                  */
/*�������:    s8IPAddr:  ���ص�ģ��IP                                  */
/*����ֵ:      -1:ʧ��; >0: ģ��port                                    */
typedef DJ_S32    (*PFUNC_GETMODIPPORT)(DJ_U8 u8ModType,DJ_U8 u8UnitId,DJ_S8 * s8IPAddr);
/************************************************************************/

/************************************************************************/
/*��������:    ��ȡ��ģ���ini�ļ���                                    */
/*�������:    ��                                                       */
/*�������:    s8IniFile: ���ص�ini�ļ���                               */
/*����ֵ:      0:�ɹ�; -1:ʧ��                                          */
typedef DJ_S32    (*PFUNC_GETMODINIFILE)(DJ_S8 * s8IniFile);
/************************************************************************/

/************************************************************************/
/*��������:    ��ȡ����ģ���UnitID                                     */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :    ģ��UnitID                                               */
typedef DJ_U8     (*PFUNC_GETMODUNITID)(DJ_SOCKET);
/************************************************************************/

/************************************************************************/
/*��������:    ��ȡָ��ģ�������UnitID                                     */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :    ģ��UnitID                                               */
typedef DJ_U8     (*PFUNC_GETMODALLUNITID)(DJ_U8 u8ModType,DJ_U8 u8UnitID[]);
/************************************************************************/

/************************************************************************/
/*��������:    �ж��Ƿ�д����־                                         */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :    0:  success,1: failure                                   */
typedef DJ_S32    (*PFUNC_IS_LOG_OUT)( DJ_U8 u8ModType, DJ_U8 u8ModUnitID, DJ_U8 u8LogLevel );
/************************************************************************/

/************************************************************************/
/*��������:    �ж��Ƿ�д��ITPCOM��־                                   */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :    0:  success,1: failure                                   */
typedef DJ_S32    (*PFUNC_IS_COM_LOG_OUT)( DJ_U8 u8ModType, DJ_U8 u8ModUnitID, PPKG_HEAD_STRUCT pHead );
/************************************************************************/

/************************************************************************/
/*��������:    д���������־                                           */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :    0:  success,1: failure                                   */
typedef DJ_S32    (*PFUNC_LOG_OUT)( DJ_U8 u8Level, DJ_U8 u8DType, DJ_U8 u8DSType, DJ_U8 u8UnitID, DJ_U16 u16ChID, DJ_U8 u8MsgType, DJ_U8 u8ErrCode, DJ_U8 * pu8DataBuf, DJ_U32 u32DataLen );

/************************************************************************/
/*��������:    д���ַ�����־                                           */
/*�������:    ��                                                       */
/*�������:    ��                                                       */
/*����ֵ  :    0:  success,1: failure                                   */
typedef DJ_S32    (*PFUNC_LOG_OUT_STR)( DJ_U8 u8Level, DJ_U8 u8DType, DJ_U8 u8DSType, DJ_U8 u8UnitID, DJ_U16 u16ChID , const DJ_S8 *format,... );


//define ITPLog Interface
typedef DJ_S32    (*PLOG_INIT)( DJ_Void* pCallBack, DJ_U8 u8LogType, DJ_U8 u8ModuleType, DJ_U8 u8ModuleUnitNo, DJ_S8 *pIniPath );
typedef DJ_S32    (*PLOG_RLS)( );

typedef DJ_S32    (*PLOG_GETCFG)( DJ_U32 u32CmdType, DJ_U8 *pu8Buf, DJ_U32 *pu32BufSize );
typedef DJ_S32    (*PLOG_SETCFG)( DJ_U32 u32CmdType, DJ_U8 *pu8Buf, DJ_U32 u32BufSize, DJ_U8 u8IsWriteIni );
typedef DJ_S32    (*PLOG_SETMSG)( DJ_Void *pMsgInfo );

typedef DJ_S32    (*PFUNC_LOGMOD_UPDATE_CFG)( const DJ_Void *pLogCfgInfo, DJ_U32 u32LogCfgInfoSize );

/************************************************************************/
/*��������:    ��ȡָ��ģ�������ģ����Ϣ                               */
/*�������:    u8Master: 0�����ģ�顡1������ģ��                       */
/*			   u8UnitID: ��ģ���ʶ					                    */
/*			   u8HBMode: �ȱ�ģʽ: 0:����ģʽ��1: �ȱ�ģʽ              */
/*�������:    ��                                                       */
/*����ֵ  :    ģ��UnitID                                               */
//typedef DJ_S32    (*PFUNC_GETMASTER)(DJ_U8 *u8Master,DJ_U8 *u8UnitID, DJ_U8* u8HBMode );
typedef DJ_S32    (*PFUNC_GETMASTER)(DJ_U8 *u8Master,DJ_U8 *u8UnitID );


/************************************************************************/
/************************************************************************/
/*��������:    ����״̬�л��ص�����			                            */
/*�������:    ��												        */
/*													                    */
/*�������:    ��                                                       */
/*����ֵ  :    ��			                                            */
typedef void    (*PFUNC_STANDBYNOTIFY)();
typedef struct
{
	PLOG_INIT                m_pLog_Init;       //��־���ʼ������ָ��
	PLOG_RLS                 m_pLog_Rls;        //��־���ͷź���ָ��
	PLOG_GETCFG              m_pLog_GetCfg;     //��ȡ��־ģ��������Ϣ����ָ��
	PLOG_SETCFG              m_pLog_SetCfg;     //������־ģ��������Ϣ����ָ��
	PLOG_SETMSG              m_pLog_SetMsg;     //��Logģ�����ò���
	
	PFUNC_IS_LOG_OUT         m_pLog_IsOut;      //��ͨ��־�Ƿ��������ָ��
	PFUNC_IS_COM_LOG_OUT     m_pLog_IsComOut;   //ITPCOM��־�Ƿ��������ָ��
	PFUNC_LOG_OUT_STR        m_pLog_OutStr;     //�ַ�����־�������ָ��
	PFUNC_LOG_OUT            m_pLog_Out;        //��������־�������ָ�� 

    DJ_U8*                   m_pRef[4];         //reserve
    
}ITP_LOG_CALLBACK, *PITP_LOG_CALLBACK;


/************************************************************************/

//�ص��ӿں���ָ��
typedef struct
{
	PFUNC_GETSELFUNITID        m_pGetSelfUnitId;
	PFUNC_GETMODSTATE          m_pGetModState;
	PFUNC_SENDPACK             m_pSendPack;
	PFUNC_SENDPACKEX           m_pSendPackEx;
	PFUNC_GETMASTER		       m_pGetMaster;
	PFUNC_RESENDPACK           m_pReSendPack;
	PFUNC_GETMODIPPORT         m_pGetModIpPort;
	PFUNC_GETMODINIFILE        m_pGetModIniFile;
	PFUNC_GETMODUNITID         m_pGetModUnitID;
	PFUNC_GETMODALLUNITID      m_pGetModAllUnitID;
	PFUNC_STANDBYNOTIFY	       m_pStandbyNotify;
	PFUNC_IS_LOG_OUT           m_pIsLogOut;
	PFUNC_IS_COM_LOG_OUT       m_pIsCOMLogOut;
	PFUNC_LOG_OUT              m_pLogOut;
	PFUNC_LOG_OUT_STR          m_pLogOutStr;
	PFUNC_LOGMOD_UPDATE_CFG    m_pLogUpateCfg;
	PFUNC_LOGMOD_UPDATE_CFG    m_pITPCOMLogUpateCfg;
	
	DJ_U8*                     m_pFuncRef[11];
	
}ITP_MOD_CALLBACK,*PITP_MOD_CALLBACK;

extern ITP_MOD_CALLBACK      g_ITPCallBack;
extern ITP_LOG_CALLBACK      g_ITPLogCallBack;


/////////////////////////////////////////////////////////////////
//��־ģ��ԭʼ�ӿ�
#define   ITPLGInit          g_ITPLogCallBack.m_pLog_Init
#define   ITPLGRls           g_ITPLogCallBack.m_pLog_Rls
#define   ITPLGIsOut         g_ITPLogCallBack.m_pLog_IsOut
#define   ITPLGIsComOut      g_ITPLogCallBack.m_pLog_IsComOut
#define   ITPLGOutStr        g_ITPLogCallBack.m_pLog_OutStr
#define   ITPLGOut           g_ITPLogCallBack.m_pLog_Out
#define   ITPLGGetCfg        g_ITPLogCallBack.m_pLog_GetCfg
#define   ITPLGSetCfg        g_ITPLogCallBack.m_pLog_SetCfg
#define   ITPLGSetMsg        g_ITPLogCallBack.m_pLog_SetMsg

/////////////////////////////////////////////////////////////////
//�ص��ӿ�
#define   GetSelfUnitId      g_ITPCallBack.m_pGetSelfUnitId
#define   GetModState        g_ITPCallBack.m_pGetModState
#define   SendPack           g_ITPCallBack.m_pSendPack
#define   SendPackEx       g_ITPCallBack.m_pSendPackEx
#define   GetMaster        g_ITPCallBack.m_pGetMaster
#define   ReSendPack         g_ITPCallBack.m_pReSendPack
#define   GetModIpPort       g_ITPCallBack.m_pGetModIpPort
#define   GetModIniFile      g_ITPCallBack.m_pGetModIniFile
#define   GetModUnitID       g_ITPCallBack.m_pGetModUnitID
#define   GetModAllUnitID    g_ITPCallBack.m_pGetModAllUnitID
#define	  OnStandbyNotify  g_ITPCallBack.m_pStandbyNotify
#define	  KGIsLogOut         g_ITPCallBack.m_pIsLogOut
#define	  KGIsComLogOut      g_ITPCallBack.m_pIsCOMLogOut
#define	  KGLogOut           g_ITPCallBack.m_pLogOut
#define	  KGLogOutStr        g_ITPCallBack.m_pLogOutStr

#endif
