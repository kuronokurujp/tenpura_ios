//
//  DataGlobal.c
//  tenpura
//
//  Created by y.uchida on 12/10/15.
//
//

#include "DataGlobal.h"
#include <stdio.h>

//	シーン変移秒数
const float	g_sceneChangeTime	= 0.2f;

//	バナー更新リクエスト時間（秒）
const float	g_bannerRequestTimeSecVal	= 15.f;

//	バナー位置
const float ga_bannerPos[ 2 ]	= { 0 , 320 - 50 };

//	バナーパブリッシュID
const char*	gp_admobBannerID	= "a150a203dfecc8a";

//	バナーオブサーバー通知名
const char*	gp_bannerShowObserverName	= "OBBannerShow";
const char*	gp_bannerHideObserverName	= "OBBannerHide";

//	TweetViewオブサーバー通知名
const char*	gp_tweetShowObserverName	= "OBTweetShow";
const char*	gp_tweetTextKeyName			= "TweetTextKey";
const char*	gp_tweetSearchURLKeyName	= "TweetSearchURLKey";

//	購入処理のオブサーバー通知名
const char*	gp_paymentObserverName	= "InPaymenttOjama";

//  ネットタイマー取得オブサーバー通知名
const char* gp_getNetTimeObserverName   = "GetNetworkTime";


//	お客の座標位置
const float ga_initCustomerPos[ eCUSTOMER_MAX ][ 2 ]	=
{
	{ 320, 240 },
	{ 320, 160 },
	{ 320, 80 },
	{ 320, 0}
};

//	リーダーボードID名
const char*	gp_leaderboardDataName	= "GameScore";

//	サウンドデータ管理ファイル名GameScore
const char*	gp_soundDataListName	= "soundListData";

//	アニメデータ一覧
ANIM_DATA_ST	ga_animDataList[eANIM_MAX]	=
{
	{ "bomb.png", "bomb.plist", 60.f },
	{ "cursor.png", "cursor.plist", 60.f },
	{ "star.png", "star.plist", 60.f },
	{ "bigBomb.png", "bigBomb.plist", 60.f },
	{ "abura.png", "abura.plist", 60.f },
	
	{ "charBad01.png", "charBad01.plist", 4.f },
	{ "charBad02.png", "charBad02.plist", 4.f },
	{ "charBad03.png", "charBad03.plist", 4.f },

	{ "charNormal01.png", "charNormal01.plist", 4.f },
	{ "charNormal02.png", "charNormal02.plist", 4.f },
	{ "charNormal03.png", "charNormal03.plist", 4.f },

	{ "charHappy01.png", "charHappy01.plist", 4.f },
	{ "charHappy02.png", "charHappy02.plist", 4.f },
	{ "charHappy03.png", "charHappy03.plist", 4.f },
};

char*	gpa_spriteFileNameList[eSPRITE_FILE_MAX]	=
{
	"combo_message.png",
	"moji00.png",
	"moji01.png",
	"moji02.png",
    "font.png",
    "heart.png",
    "saikou.png",
    "touch.png",
    "lasttime.png",
    "sire_cell.png",
    "sire_cell60.png",
    "sire_cell80.png",
};
