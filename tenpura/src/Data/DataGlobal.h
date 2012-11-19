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

#endif
