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
#import "../Data/DataNetaList.h"

//	前方宣言
@class ActionCustomer;
@class Nabe;

@interface Customer : CCNode {
	//	変数定義
	CCSprite*		mp_sp;
	ActionCustomer*	mp_act;
	Nabe*			mp_nabe;
	CCArray*		mp_settingTenpuraList;
	
	BOOL	mb_put;
	SInt32	m_idx;
	SInt32	m_money;
	SInt32	m_score;
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
@property	(nonatomic, retain)NSString*	regeistTenpuraDelPermitName;
//@property	SInt32	money;
//@property	SInt32	score;
@property	(nonatomic, assign, setter = _setMoney: )SInt32 money;
@property	(nonatomic, assign, setter = _setScore: )SInt32 score;

//	初期化
-(id)	initToType:(TYPE_ENUM)in_type:(SInt32)in_idx:(Nabe*)in_pNabe:(CCArray*)in_pSettingTenpuraList;

//	食べた天ぷらリスト作成
-(void)	createEatList;

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

@end