//
//  GameScene.h
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./../Object/Nabe.h"
#import "./../Object/Customer.h"
#import "./../Object/Tenpura.h"
#import "./../Object/GameInFliterColorBG.h"
#import "./../Object/GameInFeverEvent.h"
#import "./../Object/GameInFeverMessage.h"

@class GameInFeverMessage;
@class AnimActionNumCounterLabelBMT;
@class GameInBG;

typedef struct
{
    UInt32  no;
    UInt8   hiscore;
} _GAME_SCENT_HISCORE_TENPURA_DATA_ST;
/*
	@brief	ゲーム開始時に設定するデータ
*/
@interface GameData : NSObject
{
@public
	//	ネタリスト
	CCArray*	mp_netaList;
	//	設定したアイテムno
	CCArray*	mp_itemNoList;
}
@end

/*
	@brief
*/
@interface GameSceneData : CCLayer
{
@private
}

@property	(nonatomic, readonly)Float32	combDelTime;
@property	(nonatomic, readonly)Float32	customerMoneyPutTime;
@property	(nonatomic, readonly)Float32	combMessageTime;
@property	(nonatomic, readonly)Float32	gameTime;
@property	(nonatomic, readonly)Float32	feverTime;

@end

@interface GameScene : CCLayer {

@public
	//	変数定義
	Nabe*	mp_nabe;
	CCArray*	mp_customerArray;
	
	AnimActionNumCounterLabelBMT*	mp_timerPut;
	AnimActionNumCounterLabelBMT*	mp_scorePut;
	Float32	m_timeVal;
	Float32	m_feverTime;
	Float32	m_combAddTime;
	Float32	m_gameEndScoreRate;
	Float32	m_scoreRate;
	UInt32	m_moneyRate;
    UInt8   m_putCustomerMaxNum;
    UInt8   m_eatTenpuraMaxNum;

	CCArray*	mp_settingItemList;
    CCArray*    mp_tenpuraHiscoreList;

	GameData*	mp_gameData;
	GameSceneData*	mp_gameSceneData;
	
	GameInFeverMessage*	mp_feverMessage;
	GameInFliterColorBG*	mp_fliterColorBG;
	GameInFeverEvent*		mp_feverEvent;
}

//	関数定義
//	シーン作成
+(CCScene*)	scene:(GameData*)in_pData;

//	初期化
-(id)init:(GameData*)in_pData;

//	客を一人出す
-(Customer*) putCustomer:(BOOL)in_bCreateEat;

//  天ぷらのスコア加算(天ぷらの種類NO、スコア加算値 天ぷらの種類NOが見つからない場合は何もしない)
-(void) addHiScoreByTenpura:(UInt32)in_no :(UInt8)in_num;

//	オブジェクトのポーズ
-(void)	pauseObject:(BOOL)in_bFlg;

//	取得したスコア／金額
-(int64_t)	getScore;
//	ゲーム終了時のスコア値
-(int64_t)	getScoreByGameEnd;
-(int64_t)	getMoney;

@end
