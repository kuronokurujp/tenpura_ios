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
	
	CCArray*	mp_settingItemList;
}

//	関数定義
//	シーン作成
+(CCScene*)	scene:(CCArray*)in_pItemList;

//	初期化
-(id)init:(CCArray*)in_pItemList;

//	客を一人出す
-(Customer*) putCustomer:(BOOL)in_bCreateEat;
//	客を一人退場
-(void)	exitCustomer:(Customer*)in_pCustomer;

//	登場している客の個数を取得
-(UInt32)	getPutCustomerNum;



@end
