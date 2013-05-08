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

#define SCREEN_SIZE_WIDTH	(480.f)
#define SCREEN_SIZE_HEIGHT	(320.f)

//	テーブルビュー
#define TABLE_POS_X	(0)
#define TABLE_POS_Y	(50)

#define TABLE_SIZE_WIDTH	(SCREEN_SIZE_WIDTH)
#define TABLE_SIZE_HEIGHT	(270)

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
	eANIM_BIGBOMG,
	eANIM_ABURA,
	eANIM_CHAR_BAD01,
	eANIM_CHAR_BAD02,
	eANIM_CHAR_BAD03,

	eANIM_CHAR_NORMAL01,
	eANIM_CHAR_NORMAL02,
	eANIM_CHAR_NORMAL03,

	eANIM_CHAR_HAPPY01,
	eANIM_CHAR_HAPPY02,
	eANIM_CHAR_HAPPY03,
	
	eANIM_MAX
};

//	シーン変移秒数
extern const float	g_sceneChangeTime;

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

//	おじゃま処理用のオブサーバー通知名
extern	const char*	gp_startOjamaObserverName;
extern	const char*	gp_startOjamaDataName;

extern const char*	gp_soundDataListName;

//	アニメ
typedef struct
{
	const	char*	pImageFileName;
	const	char*	pListFileName;
	float	fps;
} ANIM_DATA_ST;

extern	ANIM_DATA_ST	ga_animDataList[eANIM_MAX];

//	スプライトファイル名一覧(いずれすべてローディングする対象かも)
enum
{
	eSPRITE_FILE_COMBO_MESSAGE	= 0,
	eSPRITE_FILE_CUS_MOJI00,
	eSPRITE_FILE_CUS_MOJI01,
	eSPRITE_FILE_CUS_MOJI02,
	eSPRITE_FILE_MAX,
};

//	事前読み込みスプライトファイル
extern	char*	gpa_spriteFileNameList[eSPRITE_FILE_MAX];

#endif
