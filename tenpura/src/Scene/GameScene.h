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
@class AnimActionNumCounterLabelTTF;
@class GameInBG;

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
	
	CCLabelTTF*	mp_timerPut;
	AnimActionNumCounterLabelTTF*	mp_scorePut;
	Float32	m_timeVal;
	Float32	m_feverTime;
	Float32	m_combAddTime;
	Float32	m_gameEndScoreRate;
	Float32	m_scoreRate;
	UInt32	m_moneyRate;

	CCArray*	mp_settingItemList;
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
//	客を一人退場
-(void)	exitCustomer:(Customer*)in_pCustomer;

//	オブジェクトのポーズ
-(void)	pauseObject:(BOOL)in_bFlg;

//	取得したスコア／金額
-(int64_t)	getScore;
-(int64_t)	getMoney;

@end
