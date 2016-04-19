#ifndef _PUTTEXTINPICTURE_H
#define _PUTTEXTINPICTURE_H

#ifdef __cplusplus
extern "C"
{
#endif

#define PUTTEXTINPICTURE_EXPORTS

#ifdef _WIN32
	#ifdef PUTTEXTINPICTURE_EXPORTS
	#define PUTTEXTINPICTURE_API __declspec(dllexport)
	#else
	#define PUTTEXTINPICTURE_API __declspec(dllimport)
	#endif
#else
	#define PUTTEXTINPICTURE_API
void so_init(void) __attribute__((constructor)); // init section
void so_fini(void) __attribute__((destructor));  // fini section
#endif

enum tagFontType	/* .\\PutTextInPicture.ini */
{
	FONTTYPE_simsun = 0,				// ����&������
		FONTTYPE_micross				// Microsoft Sans Serif
};

typedef unsigned char byte;
enum tagType
{
	Type_Text = 1,
		Type_Picture = 2
};
typedef struct tagPutTextInPictureParamItem
{
	byte byType;		// 1-���� 2-ͼƬ
	byte byLevel;		// ͼ��
	char chText[260];	// ���ִ�
	WORD wFontType;		// ��������
	struct tagDllFONTPARAM
	{
		double dbSize;		// �����С Ĭ�Ͽ�����20.0
		double dbBlank;		// �հױ��� Ĭ�Ͽ�����0.5
		double dbGap;		// ������� Ĭ�Ͽ�����0.1
		double dbAngle;		// ��ת�Ƕ�(��֧��)
		bool bUnderLine;	// �Ƿ��»���(��֧��)
		struct tagDllCOLOR
		{
			byte byR;
			byte byG;
			byte byB;
		} strcutColor;		// ������ɫ
	} structFontParam;
	float fDiaphaneity;	// ͸���� Ĭ�Ͽ�����1.0��͸��
	struct tagDllPOINT
	{
		int x;
		int y;
	} structPoint;		// ����ͼƬ��λ�û򱳾�ͼƬ�Ŀ��
}PUTTEXTINPICTUREPARAMITEM, *LPPUTTEXTINPICTUREPARAMITEM;

/*
* Ŀǰ��֧�֣�paramItem����
* ��һ����Ա����ΪͼƬ(ͼƬ��ַ��Ϊ""��Ϊ�޵�ͼ�Ҵ�С������structPointָ��) �Զ���Ϊ��һ��
* byLevel������д �����Զ��ڵڶ���
* ����ֻ֧����Ӣ�� ֧���������ֿ��Զ���ini�ļ����������ļ�����Fonts�ļ���
* ͼƬ��ʽ��ͼƬ��׺������
*/

/*
* chDstFile ����ļ�
* paramItem PUTTEXTINPICTUREPARAMITEM[iParamSum]
* return tagPutTextInPictureResult
*/
enum tagPutTextInPictureResult
{
	PutTextInPictureResult_Success = 0,					// �ɹ�
		PutTextInPictureResult_ParamError = 1,			// ��������
		PutTextInPictureResult_OpenPicError = 2,		// ���ļ�ʧ��
		PutTextInPictureResult_SavePicError = 3			// �����ļ�ʧ��
};
PUTTEXTINPICTURE_API int PutTextInPicture(char *chDstFile, PUTTEXTINPICTUREPARAMITEM *paramItem, int iParamSum);


#ifdef __cplusplus
}
#endif

#endif
