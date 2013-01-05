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
	eSOUND_CLICK01	= 0,
	eSOUND_CLICK02,
	eSOUND_CLICK04,
	eSOUND_CLICK05,
	eSOUND_CLICK06,
	eSOUND_CLICK07,
	eSOUND_CLICK08,
	eSOUND_EAT01,
	eSOUND_EAT02,
	eSOUND_EAT03,
	eSOUND_EAT04,
	eSOUND_EAT05,
	eSOUND_EAT06,
	eSOUND_EAT07,
	eSOUND_END01,
	eSOUND_END02,
	eSOUND_FRIED01,
	eSOUND_FRIED02,
	eSOUND_FRIED03,
	eSOUND_FRIED04,
	eSOUND_SEKI01,
	eSOUND_SEKI02,
	eSOUND_SEKI03,
	eSOUND_SEKI04,
	eSOUND_SEKI05
};

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

//	画像ファイル名一覧
extern const char*	ga_effectBombFileNameList[];

#endif
