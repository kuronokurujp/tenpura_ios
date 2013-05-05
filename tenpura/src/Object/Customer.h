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

typedef	enum
{
	eCUSTOMER_ANIM_NORMAL	= 0,
	eCUSTOMER_ANIM_HAPPY,
	eCUSTOMER_ANIM_BAD,
	eCUSTOMER_ANIM_MAX,
} CUSTOMER_ANIM_ENUM;

typedef enum
{
	eTYPE_MONEY	= 0,
	eTYPE_MAN,
	eTYPE_WOMAN,
	eTYPE_MAX,
} TYPE_ENUM;

@interface Customer : CCNode
{
@private
	//	変数定義
	TYPE_ENUM		m_type;
	CCSprite*		mp_sp;
	ActionCustomer*	mp_act;
	Nabe*			mp_nabe;
	CCArray*		mp_settingTenpuraList;
	const CUSTOMER_DATA_ST*	mp_customerData;
	
	CCNode*			mp_charAnim[eTYPE_MAX][eCUSTOMER_ANIM_MAX];
	
	BOOL	mb_put;
	SInt32	m_idx;
	SInt32	m_money;
	SInt32	m_score;
	Float32	m_eatTimeRate;
	Float32	m_orgEatTimeRate;
}

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
@property	(nonatomic, retain)Nabe*	nabe;

//	初期化
-(id)	initToType:(SInt32)in_idx :(Nabe*)in_pNabe :(CCArray*)in_pSettingTenpuraList :(Float32)in_eatTimeRate;

//	タイプ設定
-(void)	setType:(TYPE_ENUM)in_type;

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

//	天ぷらアイコンを表示／非表示設定
-(void)	setVisibleTenpuraIcon:(BOOL)in_flg;

//	天ぷらアイコンすべて削除
-(void)	removeAllEatIcon;

//	天ぷらアイコン削除
-(BOOL)	removeEatIcon:(SInt32)in_no;

//	天ぷら食べる個数
-(const SInt32)	getEatCnt;

-(void)	setAnim:(const CUSTOMER_ANIM_ENUM)in_anim :(const bool)in_bAnim;

-(void) stopAllActions;
-(void)	pauseSchedulerAndActions;
-(void)	resumeSchedulerAndActions;

@end