//*****************************************************************************
//Copyright(c)  :  DONJIN CORPORTAION All Rights Reserved                       
//FileName      :  ITPISDN.h
//Version       :  1.1                                                              
//Author        :  yezhimin                                                            
//DateTime      :  2006-05-11 16:00                                           
//Description   :  ITPϵͳQ931ģ�鹫��ͷ�ļ�����
//*****************************************************************************
#ifndef _ITPISDN_H_
#define _ITPISDN_H_


#include "ITPDataDefine.h"


//Q931ģ��������ִ��ģ��֮��ͨѶ����ͷ�ӹ��ܶ���
#define ITP_SUB_FUNC_FLOW_TO_Q931_GET_CHNL_STATE       0x01     //��ȡͨ��״̬  ��ѯָ����Ԫָ��ͨ���ĵ�ǰ״̬
#define ITP_SUB_FUNC_FLOW_TO_Q931_CALL_OUT             0x02     //����һ������  
#define ITP_SUB_FUNC_FLOW_TO_Q931_APPEND_CALLEEID      0x03     //׷�ӱ��к���  ������к�׷�ӱ��к���
#define ITP_SUB_FUNC_FLOW_TO_Q931_GET_CALL_INFO        0x04     //��ȡ������Ϣ  ��ȡ������Ϣ���������к��롢���к����
#define ITP_SUB_FUNC_FLOW_TO_Q931_GET_CALL_RESULT      0x05     //��ȡ������� 
#define ITP_SUB_FUNC_FLOW_TO_Q931_GET_DISCONN_REASON   0x06     //��ȡ�һ�ԭ�� 
#define ITP_SUB_FUNC_FLOW_TO_Q931_SET_CHNL_STATE       0x07     //����ͨ��״̬ 
#define ITP_SUB_FUNC_FLOW_TO_Q931_SET_PARAM            0x08     //���ò���
#define ITP_SUB_FUNC_FLOW_TO_Q931_GET_PARAM            0x09     //��ȡ����
#define ITP_SUB_FUNC_FLOW_TO_Q931_SET_SIGNAL           0x10     //�����ź�

#define ITP_SUB_FUNC_Q931_TO_FLOW_CHNL_STATE           0x11     //����ͨ��״̬  ��ͨ��״̬������Ǩ�ƻ���յ�����ִ��ģ����������Q931ģ��������ִ��ģ�鷢�ͱ������Ը�֮����ִ��ģ��ָ��ͨ���ĵ�ǰ״̬
#define ITP_SUB_FUNC_Q931_TO_FLOW_CALL_INFO            0x12     //����������Ϣ  �����յ�����ִ��ģ����������Q931ģ��������ִ��ģ�鷢�ͱ������������к��롢���к��롢�����ӵ�ַ�������ӵ�ַ�����ǵĳ���
#define ITP_SUB_FUNC_Q931_TO_FLOW_CALL_RESULT          0x13     //�����������  �����յ�����ִ��ģ����������Q931ģ��������ִ��ģ�鷢�ͱ������Ը�֮����ִ��ģ��ָ��ͨ���ĺ������
#define ITP_SUB_FUNC_Q931_TO_FLOW_DISCONN_REASON       0x14     //�����һ�ԭ��  �����յ�����ִ��ģ����������Q931ģ��������ִ��ģ�鷢�ͱ������Ը�֮����ִ��ģ��ָ��ͨ���Ĺһ�ԭ��
#define ITP_SUB_FUNC_Q931_TO_FLOW_SET_PARAM            0x15     //�������ò������  
#define ITP_SUB_FUNC_Q931_TO_FLOW_GET_PARAM            0x16     //������ȡ������� 
#define ITP_SUB_FUNC_Q931_TO_FLOW_SET_SIGNAL           0x17     //���������źŽ��

//Q931ģ����ͬ��ģ��֮��İ�ͷ�ӹ��ܶ���
#define ITP_SUB_FUNC_Q931_STANDBY_CHNL_STATE           0x01
#define ITP_SUB_FUNC_Q931_STANDBY_REQ_CHNL_STATE       0x02

#define ITP_SUB_FUNC_Q931_STANDBY_LINK_STATE           0x03
#define ITP_SUB_FUNC_Q931_STANDBY_REQ_LINK_STATE       0x04


//Q931ģ��ͨ��״̬����
#define ITP_Q931_CH_FREE					    1   //����״̬
//#define ITP_Q931_CH_WAIT_APP_FREE		        2   //Q931�ȴ�Ӧ�ò�ͬ���ͷ���Դ
#define ITP_Q931_CH_RESTART                     2
#define ITP_Q931_CH_UNAVIABLE			        3   //ͨ��������
#define ITP_Q931_CH_WAIT_CONNECT_ACK		    4   //�ȴ�����֤ʵ
#define ITP_Q931_CH_CONNECT				        5   //ͨ����ͨ״̬
#define ITP_Q931_CH_WAIT_RELEASE			    6   //�ѷ��Ͳ����źţ��ȴ��Է������ͷ��ź�
#define ITP_Q931_CH_WAIT_RELEASE_COMPLETE       7   //�ѷ����ͷ��źţ��ȴ��Է������ͷ�����ź�
#define ITP_Q931_CALLEE_WAIT_ANSWER		        11  //�����������е���
#define ITP_Q931_CALLER_WAIT_ANSWER		        12  //ȥ�������Ѻ������ȴ��Է���Ӧ
#define ITP_Q931_CALLER_RECV_ALERT		        21  //ȥ�������ѽ��յ�������Ϣ
#define ITP_Q931_CALLER_RECV_SETUP_ACK	        22  //ȥ�������ѽ��յ�����ȷ����Ϣ
#define ITP_Q931_CALLER_RECV_CALLPROCESS        23  //ȥ�������ѽ��յ����н�����Ϣ
#define ITP_Q931_CALLER_WAIT_SETUP_ACK	        24  //ȥ�������ȴ�����ȷ��
#define ITP_Q931_CALLEE_WAIT_INFO               0x90 //���������ȴ��������к�����Ϣ
#define ITP_Q931_CALLEE_SEND_ALERT			    0x91 //��������������������Ϣ


//ͨ����������
#define	ITP_Q931_CH_SET_FREE			       1    //APP ����ͨ��״̬Ϊ OxO2 ʱ��ͬ���ͷ�ͨ����Դ
#define ITP_Q931_CH_SET_CONNECT		           2    //����ͨ������
#define ITP_Q931_CH_SET_DISCONNECT	           3    //���ͨ������
#define ITP_Q931_CALLEE_SET_ALERTING	       4    //���з�����������Ϣ
#define	ITP_Q931_CH_SET_RESTART		           5    //����ͨ����������


//Q931�����������
#define ITP_Q931_C_NO_RESULT		   0    //��δ���غ������
#define ITP_Q931_C_USER_IDLE		   1    //���п���
#define ITP_Q931_C_USER_OFFHOOK	       2    //����ժ������ͨ
#define ITP_Q931_C_WAIT_CALL_PROC      3    //�ص����ͱ��к��룬�ȴ��Զ�ȷ�ϱ��к�������
#define ITP_Q931_C_OTHERS              10   //������������п��ܽ��������ѯͨ��״̬
#define ITP_Q931_C_STATE_UNAVIABLE     11   //״̬���ԣ�δ���к���


//����һ�ԭ��
#define ITP_Q931_RSN_UNKNOW_REASON           0x00   //ԭ��δ֪
#define ITP_Q931_RSN_UNALLOC_NUMBER          0x01   //�պ�
#define ITP_Q931_RSN_NORMAL_DISCONNECT       0x10   //�����ĺ������
#define ITP_Q931_RSN_USER_BUSY               0x11   //�û�æ
#define ITP_Q931_RSN_NO_RESPOND              0x12   //����Ӧ
#define ITP_Q931_RSN_NO_ANSWER               0x13   //���û�Ӧ��
#define ITP_Q931_RSN_REFUSR_CALL             0x15   //���оܾ�
#define ITP_Q931_RSN_NUMBER_ERROR            0x1C   //���벻ȫ
#define ITP_Q931_RSN_TIMEOUT	             0x66   //��ʱ
#define ITP_Q931_RSN_DCHANNEL_DOWN           0xfd   //��·�ж�
#define ITP_Q931_RSN_BCHANNEL_UNAVIABLE      0x22   //ͨ��������
#define ITP_Q931_RSN_UNAVIABLE_CIRCULT       0x2c   //�޿���ͨ·

#define ITP_Q931_RSN_UNAVIABLE_CRN           0x51   //��Ч�Ĳο�ֵ
#define ITP_Q931_RSN_UNCOMPATIBLE            0x58   //�����ݵ��յ�
#define ITP_Q931_RSN_UNAVIABLE_MSG           0x5F   //��Ч����Ϣ


#define ITP_Q931_RSN_NEEDMSG_LOST            0x60   //�������Ϣ��Ԫ��ʧ

#define ITP_Q931_RSN_UNKNOW_MSG              0x61    //��Ϣ���Ͳ�����
#define ITP_Q931_RSN_UNAVIABLE_STATUE        0x65   //���к�״̬������

//��������
//������Ϣ��������

#define ITP_Q931_CAP_SPEECH          0x00  /* Speech Bearer Capability */
#define ITP_Q931_CAP_UNREST_DIG      0x08  /* Unrestricted Digital Capability */
#define ITP_Q931_CAP_REST_DIG        0x09  /* Restricted Digital Capability */
#define ITP_Q931_CAP_3DOT1K_AUDIO    0x10  /* 3.1KHz Audio Capability */
#define ITP_Q931_CAP_7K_AUDIO        0x11  /* 7KHz Audio Capability */
#define ITP_Q931_CAP_VIDEO           0x18  /* Video Capability */


//������Ϣ��������

#define ITP_Q931_RATE_64KBPS         0x10  /* B_CHANNEL_UNITS 1X64 */
#define ITP_Q931_RATE_128KBPS        0x11  /* Non-standard 2X64       */
#define ITP_Q931_RATE_384KBPS        0x13  /* H0_CHANNEL_UNITS 6X64   */
#define ITP_Q931_RATE_1536KBPS       0x15  /* H11_CHANNEL_UNITS 24X64 */
#define ITP_Q931_RATE_1920KBPS       0x17  /* H12_CHANNEL_UNITS 30X64 */
#define ITP_Q931_RATE__MULTI_RATE    0x18  /* Multirate (64 kbit/s base rate) */

//���崫�ݷ�ʽ
#define ITP_Q931_ITM_CIRCUIT         0x00  /* ��·��ʽ */  //Ĭ��(only support)
#define ITP_Q931_ITM_PACKET          0x02  /* ���鷽ʽ */

//�����û�һ��Э��
#define ITP_Q931_UIL1_CCITTV110      0x01  /* user info layer 1 - CCITT V.110/X.3*/
#define ITP_Q931_UIL1_G711ALAW       0x03  /* user info layer 1 - G.711 A-law */
#define ITP_Q931_UIL1_G721ADCPM      0x04  /* user info layer 1 - G.721 ADCPM */
#define ITP_Q931_UIL1_G722G725       0x05  /* user info layer 1 - G.722 and G.725 */
#define ITP_Q931_UIL1_H223_H245      0x06  /*Recommendations H.223 [92] and H.245 [93] */
#define ITP_Q931_UIL1_DEFINE_USER    0x07  /*Non-ITU-T standardized rate adaption. This implies the presence of octet 5a and, */
                                           /*optionally, octets 5b, 5c and 5d. The use of this codepoint indicates that the user rate */
                                           /*specified in octet 5a is defined by the user. Additionally, octets 5b, 5c and 5d, if present, */
                                           /*are defined in accordance with the user specified rate adaption. */
#define ITP_Q931_UIL1_CCITTV120      0x08  /* user info layer 1 - CCITT V.120 */
#define ITP_Q931_UIL1_CCITTX31       0x09  /* user info layer 1 - CCITT X.31 */


//�����������
#define ITP_Q931_CALLNUM_UNKNOWN		        0x00   //δ֪
#define ITP_Q931_CALLNUM_INTERNATIONAL	        0x01   //���ʺ���
#define ITP_Q931_CALLNUM_DOMESTIC		        0x02   //���ں���
#define ITP_Q931_CALLNUM_NETWORK_SPECIFIC       0x03   //�����ض�����
#define ITP_Q931_CALLNUM_USER		 	        0x04   //�û�����
#define ITP_Q931_CALLNUM_RESERVE		        0x07   //��չ����


//��������������
#define ITP_Q931_NUMPLAN_UNKNOWN                0x00   //δ֪
#define ITP_Q931_NUMPLAN_ISDN                   0x01   /* ISDN numb. plan E.164 */
#define ITP_Q931_NUMPLAN_TELEPHONY              0x02   /* Telephony numb. plan E.163 */
#define ITP_Q931_NUMPLAN_PRIVATE                0x09   /* Private numbering plan */


//���ݽṹ����

typedef struct
{
    DJ_U8 m_u8Cap;                //��Ϣ��������
    DJ_U8 m_u8ITM;                //���ݷ�ʽ
    DJ_U8 m_u8Rate;               //��Ϣ��������
    DJ_U8 m_u8UIL1;               //�û�һ��Э��
    DJ_U8 m_u8CallerType;         //���к�������
    DJ_U8 m_u8CallerPlan;         //���к����������
    DJ_U8 m_u8CallerSubType;      //�����ӵ�ַ��������
    DJ_U8 m_u8CallerSubPlan;      //�����ӵ�ַ�����������
    DJ_U8 m_u8CalleeType;         //���к�������
    DJ_U8 m_u8CalleePlan;         //���к����������
    DJ_U8 m_u8CalleeSubType;      //�����ӵ�ַ��������
    DJ_U8 m_u8CalleeSubPlan;      //�����ӵ�ַ�����������
    
    DJ_U8 m_u8LowLevelFlag;       //�Ͳ�����Ա�־: 0:��ʾû�д˵�Ԫ;1:��ʾ�д˵�Ԫ
	DJ_U8 m_u8LowLevelLen;        //�Ͳ��������Ϣ��Ԫ���ȣ�Ŀǰֻ֧��Ĭ��Ϊ5bytes�ĳ���
	DJ_U8 m_u8LowLevelData[5];    //�Ͳ��������Ϣ��Ԫ����
	
    DJ_U8 reserved[29];           //�����ֶ�

}ITP_Q931_CALL_PARAM,  *PITP_Q931_CALL_PARAM;

typedef struct
{
    DJ_U8 m_u8NumberType;         //��������
    DJ_U8 m_u8NumberPlan;         //�����������
    DJ_U8 reserved[2];            //�����ֶ�
	DJ_S8 m_szChangeNumber[32];   //ԭʼ����

}ITP_Q931_ORINUM_PARAM,  *PITP_Q931_ORINUM_PARAM;


/*��Ϣ����*/
enum ITP_Q931_MSG_TYPE
{
	ITP_Q931_Resume       = 0x26,	 //�ָ�
	ITP_Q931_Suspend      = 0x25,	 //��ͣ

	ITP_Q931_Information     = 0x7b,    //��Ϣ 
	ITP_Q931_Notify          = 0x6e,	 //֪ͨ
	ITP_Q931_StatusEnquiry   = 0x75,    //״̬ѯ��
};

//������Ϣ�ṹ
typedef struct
{
	DJ_U8 m_u8CallerLen;                      //���к��볤��
    DJ_U8 m_u8CalleeLen;                      //���к��볤��
    DJ_U8 m_u8CallerSubAddrLen;               //���к����ӵ�ַ����
    DJ_U8 m_u8CalleeSubAddrLen;               //���к����ӵ�ַ����
    DJ_S8 m_s8CallerId[32];                   //���к��뻺����
    DJ_S8 m_s8CalleeId[32];                   //���к��뻺����
    DJ_S8 m_s8CallerSubAddr[32];              //���к����ӵ�ַ������ 
    DJ_S8 m_s8CalleeSubAddr[32];              //���к����ӵ�ַ������
}ITP_Q931_CALL_INFO_STRUCT;

//ͨ����Ϣ�ṹ     
typedef struct
{
	DJ_U8  m_u8UnitId;                        //DSP ��ԪID
    DJ_U8  m_u8Reserved;                      //����
    DJ_U16 m_u16Chnl;                         //DSP��Ԫ�ڵ�ͨ����
}ITP_Q931_CHNL_INFO_STRUCT;

//����һ������
typedef struct
{
	ITP_Q931_CHNL_INFO_STRUCT m_ITP_q931ChnlInfo;     //ͨ����Ϣ
    ITP_Q931_CALL_INFO_STRUCT m_ITP_q931CallInfo;     //������Ϣ
	
	DJ_U8                 m_u8CallerNumType;  //���к������� 
    DJ_U8                 m_u8CalleeNumType;  //���к�������
    DJ_U16                m_u16OverlapFlag;   //�ص����ͱ��к����־
}ITP_Q931_CMD_TO_Q931_CALLOUT;

//׷�ӱ��к���   
typedef struct
{
	ITP_Q931_CHNL_INFO_STRUCT m_ITP_q931ChnlInfo;     //ͨ����Ϣ

	DJ_U8                 m_u8Length;         //׷�ӱ��к��볤��
    DJ_U8                 m_u8SendEnd;        //������ȫ��־
    DJ_S8                 m_s8Reserved[2];    //����
    DJ_S8                 m_s8CalleeBuf[32];  //���к��뻺����
}ITP_Q931_CMD_TO_Q931_APPEND_CALLEEID;

//����ͨ��״̬
typedef struct
{   
	ITP_Q931_CHNL_INFO_STRUCT m_ITP_q931ChnlInfo;     //ͨ����Ϣ
	
    DJ_U8                 m_u8State;                  //ͨ��״̬
    DJ_S8                 m_s8Reserved[3];            //����
}ITP_Q931_CMD_TO_Q931_CHNL_STATE;

//Q931ģ��������ִ��ģ�鷴��ͨ��״̬
typedef struct
{
	DJ_U8                 m_u8State;          //ͨ��״̬
    DJ_S8                 m_s8Reserved[3];    //����
}ITP_Q931_EVENT_TO_FLOW_CHNL_STATE;

//Q931ģ��������ִ��ģ�鷴���������
typedef struct
{
	DJ_U8                 m_u8CallResult;     //�������
    DJ_S8                 m_s8Reserved[3];    //����
}ITP_Q931_EVENT_TO_FLOW_CALL_RESULT;

//Q931ģ��������ִ��ģ�鷴���һ�ԭ��
typedef struct
{
	DJ_U8                 m_u8DisconnReason;  //�һ�ԭ��
    DJ_S8                 m_s8Reserved[3];    //����
}ITP_Q931_EVENT_TO_FLOW_DISCONN_REASON;

typedef struct
{
    ITP_Q931_CHNL_INFO_STRUCT m_ITP_q931ChnlInfo; //ͨ����Ϣ
	
	DJ_U8                 m_u8ErrorCode;       //�������

	DJ_U8                 m_u8ParamType;       //��������
    DJ_U8                 m_u8ParamLen;        //��������
    DJ_S8                 m_s8ParamData[100];  //��������
}ITP_Q931_PARAM;

typedef struct
{
    ITP_Q931_CHNL_INFO_STRUCT m_ITP_q931ChnlInfo; //ͨ����Ϣ

    DJ_U8                 m_u8ErrorCode;       //�������
    DJ_U8                 m_u8SignalType;      //��������
}ITP_Q931_SIGNAL;

#if 0
//low level unit 
typedef struct 
{
	DJ_U8          m_bID;			      //��Ԫ��ʶ��
	DJ_U8          m_bLen;			      //����

	DJ_U8          m_bPass  :5;              //��Ϣ��������
	DJ_U8          m_bCode  :2;              //�����׼
	DJ_U8          m_bFlag1 :1;              // Ĭ��Ϊ1

	DJ_U8          m_bPassRate :5;           // ��Ϣ��������
	DJ_U8          m_bPassType :2;           //���ݷ�ʽ 0. ��·��ʽ��1. ���鷽ʽ
	DJ_U8          m_bFlag2    :1;           // Ĭ��Ϊ1

	DJ_U8          m_bProtocol   :5;           //�û���Ϣһ��Э��  
    DJ_U8          m_bProtocolID :2;
	DJ_U8          m_bFlag3      :1;

	DJ_U8          m_PackLen;
}ITP_Q931_ISDN_LOW_LEVEL;
#endif

typedef struct
{
	DJ_U8                 m_u8LinkID;         //��·ID
	DJ_U8                 m_u8State;          //��·״̬
    DJ_S8                 m_s8Reserved[2];    //����
}ITP_Q931_STANDBY_LINK_STATE;


typedef struct
{
	DJ_U8                 m_u8State;          //ͨ��״̬
	DJ_S16                m_sCRN;		 //call reference  ���вο�
	DJ_U8                 m_bIncall;
    DJ_S8                 m_s8Reserved[4];    //����
}ITP_Q931_STANDBY_CHNL_STATE;

//UUI
typedef struct
{
	DJ_U8   m_u8UUIFlag;                       //UUI Set Flag
	DJ_U8   m_u8MsgType;                       //MSG Type
	DJ_U8   m_u8Len;                           //UUI's Length
    DJ_U8   m_u8UUIData[131];                  //UUI data buffer

}ITP_Q931_UUI_PARAM,  *PITP_Q931_UUI_PARAM;

#endif
