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

//	サウンドデータ管理ファイル名
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

//	爆発エフェクト(30fps)
const char*	ga_effectBombFileNameList[]	=
{
	"bomb0001.png",
	"bomb0002.png",
	"bomb0003.png",
	"bomb0004.png",
	"bomb0005.png",
	"bomb0006.png",
	"bomb0007.png",
	"bomb0008.png",
	"bomb0009.png",
	"bomb0010.png",
	"bomb0011.png",
	"bomb0012.png",
	"bomb0013.png",
	"bomb0014.png",
	"bomb0015.png",
	"bomb0016.png",
	"bomb0017.png",
	"bomb0018.png",
	"bomb0019.png",
	"bomb0020.png",
	"bomb0021.png",
	"bomb0022.png",
	"bomb0023.png",
	"bomb0024.png",
	"bomb0025.png",
	"bomb0026.png",
	"bomb0027.png",
	"bomb0028.png",
	"bomb0029.png",
	"bomb0030.png",
};
