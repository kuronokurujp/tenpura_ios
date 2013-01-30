//
//  DataGlobal.h
//  tenpura
//
//  Created by y.uchida on 12/10/15.
//
//

#ifndef tenpura_DataGlobal_h
#define tenpura_DataGlobal_h

//	色々な所で参照するデータをここに記述
//	でも使いすぎに注意

enum
{
	eCUSTOMER_MAX	= 4,
};

//	サウンドIDリスト
enum
{
	eSOUND_BTN_CLICK	= 0,
	eSOUND_PRESS_BTN_CLICK,
	eSOUND_TENPURA_HIT_CUSTOMER,
	eSOUND_EAT,
	eSOUND_GAME_END,
	eSOUND_GAME_START,
	eSOUND_FRIED01,
	eSOUND_FRIED02,
	eSOUND_FRIED03,
	eSOUND_FRIED04,
	eSOUND_SEKI,
};

enum
{
	eANIM_BOMG	= 0,
	eANIM_CURSOR,
	eANIM_STAR,
//	eANIM_COMBO_NUM,
	eANIM_MAX
};

//	エフェクト再生名一覧
extern const char*	ga_AnimPlayName[eANIM_MAX];

extern const float	g_bannerRequestTimeSecVal;
extern const float	ga_bannerPos[ 2 ];

extern const float	ga_initCustomerPos[ eCUSTOMER_MAX ][ 2 ];
extern const char*	gp_leaderboardDataName;
extern const char*	gp_admobBannerID;
extern const char*	gp_bannerShowObserverName;
extern const char*	gp_bannerHideObserverName;
extern const char*	gp_tweetShowObserverName;
extern const char*	gp_tweetTextKeyName;
extern const char*	gp_tweetSearchURLKeyName;
extern const char*	gp_soundDataListName;

//	アニメ
typedef struct
{
	const	char**	ppFrameNameList;
	int				frameNum;
	const	char*	pImageFileName;
	const	char*	pListFileName;
} ANIM_DATA_ST;

extern	ANIM_DATA_ST	ga_animDataList[eANIM_MAX];

//	スプライトファイル名一覧(いずれすべてローディングする対象かも)
enum
{
	eSPRITE_FILE_COMBO_MESSAGE	= 0,
	eSPRITE_FILE_MAX,
};

extern	char*	gpa_spriteFileNameList[eSPRITE_FILE_MAX];

#endif
