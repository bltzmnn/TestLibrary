#ifndef _VOIP_DEBUG_H_
#define _VOIP_DEBUG_H_

#pragma comment(lib, "..\\VoipKeygoe\\debug\\VoipKeygoe.lib")

#ifndef DECLSPEC_IMPORT
#define DECLSPEC_IMPORT __declspec(dllimport)  
#endif
extern "C" DECLSPEC_IMPORT int InitKeygoeSystem(const char* configFile); 
extern "C" DECLSPEC_IMPORT int ClearTrunk(const int iTrunk);
extern "C" DECLSPEC_IMPORT int ExitKeygoeSystem(); 

extern "C" DECLSPEC_IMPORT int CheckTrunkReady(const int count, const int iTrunk); //���Trunkʱ��׼��OK

//int StartCheckDialTone(const int iTrunk);
extern "C" DECLSPEC_IMPORT int CallOutOffHook(const int iTrunk); //����ժ��
//int StartCheckAnswerTone(const int iTrunk); 
extern "C" DECLSPEC_IMPORT int Dial(const int iTrunk, const int iLen, const char* CallNumber); //����

extern "C" DECLSPEC_IMPORT int SendData(const int iTrunk, const int iDTrunk, const char* dtmf); //����DTMF
extern "C" DECLSPEC_IMPORT int GetRecvData(const int iTrunk, char * &data, const int ilen, const int seconds);	//��ȡ�յ���DTMF
extern "C" DECLSPEC_IMPORT int SetTrunkStateToSendData(const int iTrunk);
extern "C" DECLSPEC_IMPORT int ClearRecvData(const int iTrunk); //���֮ǰ���յ���DTMF
extern "C" DECLSPEC_IMPORT int GetTrunkLinkState(const int iTrunk); 

extern "C" DECLSPEC_IMPORT int SendFax(const int iTrunk, const int iDTrunk, char* filename, const int seconds); //������
extern "C" DECLSPEC_IMPORT int StartRecvFax(const int iTrunk, char* filename); //׼���մ���
extern "C" DECLSPEC_IMPORT int GetRecvFaxResult(const int iTrunk, const int seconds); //�ȴ����չ�����ɣ��������Ƿ�ɹ�
//extern "C" DECLSPEC_EXPORT int GetRecvData

//int StartCheckCallIn(const int iTrunk);
extern "C" DECLSPEC_IMPORT int CheckCallIn(const int iTrunk, const int seconds = 10);	//��鵱ǰ�Ƿ���Callin״̬
extern "C" DECLSPEC_IMPORT int CallInOffHook(const int iTrunk); //����ժ��

extern "C" DECLSPEC_IMPORT int ClearCall(const int iTrunk); //�һ�

extern "C" DECLSPEC_IMPORT int GetTrunkState(const int iTrunk); 
extern "C" DECLSPEC_IMPORT int GetCallInRingTimes(const int iTrunk, const int seconds = 30);  //������ʱ�������˶��ٴ�


extern "C" DECLSPEC_IMPORT int SetFalse(const int iTrunk); //�Ĳ�
extern "C" DECLSPEC_IMPORT int SetFalseTime(const int iTrunk, const int iTimes); //�����Ĳ�ʱ��
extern "C" DECLSPEC_IMPORT int SetFaxFile(const int iTrunk, char* filename); //���ô����ļ�
extern "C" DECLSPEC_IMPORT int SetFaxBps(const int iTrunk, const int iBps );

//int CheckEnd(const int iTrunk);
#endif //_VOIP_DEBUG_H_