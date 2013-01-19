//
//  GameScene.h
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "../Object/Nabe.h"
#import "../Object/Customer.h"
#import "../Object/Tenpura.h"

/*
	@brief	ゲーム開始時に設定するデータ
*/
@interface GameData : NSObject
{
@public
	//	ネタリスト
	CCArray*	mp_netaList;
	CCArray*	mp_itemList;
}
@end

@interface GameScene : CCLayer {

@public
	//	変数定義
	Nabe*	mp_nabe;
	CCArray*	mp_customerArray;
	
	CCLabelTTF*	mp_timerPut;
	CCLabelTTF*	mp_scorePut;
	int64_t	m_scoreNum;
	SInt32	m_addMoneyNum;
	Float32	m_timeVal;
	UInt32	m_scoreRate;
	UInt32	m_moneyRate;

	CCArray*	mp_settingItemList;
	GameData*	mp_gameData;
}

//	設定用定義
@property	(nonatomic, assign, setter = _setScore:)SInt32	score;
@property	(nonatomic, assign, setter = _setMoney:)SInt32	money;

//	関数定義
//	シーン作成
+(CCScene*)	scene:(GameData*)in_pData;

//	初期化
-(id)init:(GameData*)in_pData;

//	客を一人出す
-(Customer*) putCustomer:(BOOL)in_bCreateEat;
//	客を一人退場
-(void)	exitCustomer:(Customer*)in_pCustomer;

//	登場している客の個数を取得
-(UInt32)	getPutCustomerNum;

@end
