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

//	おじゃま処理用のオブサーバー通知名
const char*	gp_startOjamaObserverName	= "InGameStartOjama";
const char*	gp_startOjamaDataName	= "InGameStartOjamaData";


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

/*
//	ローディング対象のテクスチャーファイル名一覧
static const char*	gp_MissionListCellSpriteName	= "neta_cell.png";
static const char*	gp_MissionChkBoxOffSpriteName	= "checkoff.png";
static const char*	gp_MissionChkBoxOnSpriteName	= "checkon.png";
static const char*	gp_NabeSpriteName	= "nabe0.png";
static const char*	gp_SireCellFileName		= "sire_cell.png";
static const char*	gp_NotBuyCellFileName	= "not_buy_cell.png";
static const char*	gp_CutomerCharFileName	= "customer0.png";
static const char*	gp_GamePlayEndSpritFileName	= "play_end.png";
static const char*	gp_GamePlayStartSpritFileName	= "play_start.png";
*/

ANIM_DATA_ST	ga_animDataList[eANIM_MAX]	=
{
	{ "bomb.png", "bomb.plist", 60.f },
	{ "cursor.png", "cursor.plist", 60.f },
	{ "star.png", "star.plist", 60.f },
	{ "bigBomb.png", "bigBomb.plist", 60.f },
	{ "abura.png", "abura.plist", 60.f },
};

char*	gpa_spriteFileNameList[eSPRITE_FILE_MAX]	=
{
	"combo_message.png",
	"moji00.png",
	"moji01.png",
	"moji02.png",
};
