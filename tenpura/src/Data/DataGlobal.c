//
//  DataGlobal.c
//  tenpura
//
//  Created by y.uchida on 12/10/15.
//
//

#include "DataGlobal.h"

//	バナー更新リクエスト時間（秒）
const float	g_bannerRequestTimeSecVal	= 15.f;

//	バナー位置
const float ga_bannerPos[ 2 ]	= { 480 - 320, 320 - 50 };

//	バナーパブリッシュID
const char*	gp_admobBannerID	= "a150a203dfecc8a";

//	バナーオブサーバー通知名
const char*	gp_bannerShowObserverName	= "OBBannerShow";
const char*	gp_bannerHideObserverName	= "OBBannerHide";

//	TweetViewオブサーバー通知名
const char*	gp_tweetShowObserverName	= "OBTweetShow";
const char*	gp_tweetTextKeyName			= "TweetTextKey";
const char*	gp_tweetSearchURLKeyName	= "TweetSearchURLKey";

//	お客の座標位置
const float ga_initCustomerPos[ eCUSTOMER_MAX ][ 2 ]	=
{
	{ 320, 240 },
	{ 320, 160 },
	{ 320, 80 },
	{ 320, 0}
};

//	リーダーボードID名
const char*	gp_leaderboardDataName	= "Score";

