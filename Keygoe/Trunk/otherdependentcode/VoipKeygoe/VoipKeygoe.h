#ifndef _VOIP_KEYGOE_H_
#define _VOIP_KEYGOE_H_

#include "VoipDeviceRes.h"

#ifndef DECLSPEC_EXPORT
#define DECLSPEC_EXPORT __declspec(dllexport)
#endif // DECLSPEC_EXPORT BOOL APIENTRY

//
extern "C" DECLSPEC_EXPORT int InitKeygoeSystem(const char* configFile); 
extern "C" DECLSPEC_EXPORT int ClearTrunk(const int iTrunk);
extern "C" DECLSPEC_EXPORT int ExitKeygoeSystem(); 

extern "C" DECLSPEC_EXPORT int WaitTrunkReady(); //���Trunk�Ƿ�׼��OK
int CheckTrunkReady(const int iTrunk);

extern "C" DECLSPEC_EXPORT int CallOutOffHook(const int iTrunk); //����ժ��
extern "C" DECLSPEC_EXPORT int Dial(const int iTrunk, const int iLen, const char* CallNumber); //����

extern "C" DECLSPEC_EXPORT int SendData(const int iTrunk, const char* dtmf); //����DTMF
extern "C" DECLSPEC_EXPORT char* GetRecvData(const int iTrunk, const int ilen, const int seconds);	//��ȡ�յ���DTMF

//�Ȳ���
extern "C" DECLSPEC_EXPORT int SetTrunkStateToSendData(const int iTrunk);
//
extern "C" DECLSPEC_EXPORT int ClearRecvData(const int iTrunk); //���֮ǰ���յ���DTMF
extern "C" DECLSPEC_EXPORT int GetTrunkLinkState(const int iTrunk); 

extern "C" DECLSPEC_EXPORT int GetRecvFaxResult(const int iTrunk, const int seconds, char *& info); //�ȴ����չ�����ɣ��������Ƿ�ɹ�

extern "C" DECLSPEC_EXPORT int CheckCallIn(const int iTrunk, const int seconds = 10);	//��鵱ǰ�Ƿ���Callin״̬
extern "C" DECLSPEC_EXPORT int CallInOffHook(const int iTrunk); //����ժ��

extern "C" DECLSPEC_EXPORT int ClearCall(const int iTrunk); //�һ�

extern "C" DECLSPEC_EXPORT int GetTrunkState(const int iTrunk); 
// �Ȳ���
extern "C" DECLSPEC_EXPORT int GetCallInRingTimes(const int iTrunk, const int seconds = 30);  //������ʱ�������˶��ٴ�

//verion V1.1
extern "C" DECLSPEC_EXPORT int SendFax_prepare(const int iTrunk);
extern "C" DECLSPEC_EXPORT int SendFax(const int iTrunk, 
									   const int iBps, 
									   char* filename, 
									   const int seconds, 
									   char *& info, 
									   const int recordflg,
									   char* recordfilename_send = NULL,
									   char* recordfilename_recv = NULL);
extern "C" DECLSPEC_EXPORT int RecvFax_prepare(const int iTrunk);
extern "C" DECLSPEC_EXPORT int StartRecvFax(const int iTrunk, 
											const int iBps,
											char* filename,
											const int recordflg,
											char* recordfilename_send = NULL,
											char* recordfilename_recv = NULL);

extern "C" DECLSPEC_EXPORT int SetFlash(const int iTrunk); //�Ĳ�
extern "C" DECLSPEC_EXPORT int SetFlashTime( const int iTimes); //�����Ĳ�ʱ��
extern "C" DECLSPEC_EXPORT int SetFaxFile(const int iTrunk, char* filename); //���ô����ļ�
int SetFaxBps(DeviceID_t* pFaxDevID, const int iBps );
int SetFaxEcm(DeviceID_t* pFaxDevID, const int mode );//���ô���ģʽ

extern "C" DECLSPEC_EXPORT int WaitSomeTone(const int iTrunk, char* Tones, const int milliseconds = 10000);  //�����������h��
extern "C" DECLSPEC_EXPORT int UpdateTones();

extern "C" DECLSPEC_EXPORT int StartRecord(const int iTrunk, char* filename);
extern "C" DECLSPEC_EXPORT int StopRecord(const int iTrunk);
#endif //_VOIP_KEYGOE_H_ end