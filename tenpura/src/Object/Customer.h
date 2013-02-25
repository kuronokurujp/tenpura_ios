//
//  Customer.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./Tenpura.h"
#import "./../Data/DataNetaList.h"
#import "./../Data/DataCustomerList.h"

//	前方宣言
@class ActionCustomer;
@class Nabe;

@interface Customer : CCNode {
	//	変数定義
	CCSprite*		mp_sp;
	ActionCustomer*	mp_act;
	Nabe*			mp_nabe;
	CCArray*		mp_settingTenpuraList;
	const CUSTOMER_DATA_ST*	mp_customerData;
	
	BOOL	mb_put;
	SInt32	m_idx;
	SInt32	m_money;
	SInt32	m_score;
	Float32	m_eatTimeRate;
}

typedef enum
{
	eTYPE_BASIC	= 0,
} TYPE_ENUM;

//	プロパティ
@property	(nonatomic,	retain)CCSprite*	charSprite;
@property	BOOL bPut;
@property	(nonatomic, readonly)ActionCustomer*	act;
@property	(nonatomic, readonly)SInt32	idx;
@property	(nonatomic, assign, setter = _addMoney: )SInt32 addMoney;
@property	(nonatomic, assign, setter = _addScore: )SInt32 addScore;
@property	(nonatomic, readonly )SInt32 money;
@property	(nonatomic, readonly )SInt32 score;
@property	(nonatomic, readonly)Float32	eatTimeRate;

//	初期化
-(id)	initToType:(TYPE_ENUM)in_type :(SInt32)in_idx :(Nabe*)in_pNabe :(CCArray*)in_pSettingTenpuraList :(Float32)in_eatTimeRate;

//	食べた天ぷらリスト作成
-(void)	createEatList;

//	リザルトセッティング
-(void)	settingResult;

//	食べられる天ぷらかチェック
-(BOOL)isEatTenpura:(SInt32)in_no;

//	食べる天ぷら個数
-(UInt32)getEatTenpura;

//	オブジェクト矩形取得
-(CGRect)	getBoxRect;

//	天ぷらアイコンすべて削除
-(void)	removeAllEatIcon;

//	天ぷらアイコン削除
-(BOOL)	removeEatIcon:(SInt32)in_no;

//	天ぷら食べる個数
-(const SInt32)	getEatCnt;

-(void) stopAllActions;
-(void)	pauseSchedulerAndActions;
-(void)	resumeSchedulerAndActions;

@end