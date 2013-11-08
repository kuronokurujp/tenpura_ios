//
//  Tenpura.h
//  tenpura
//
//  Created by y.uchida on 12/09/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "../Data/DataNetaList.h"
#import "./TenpuraIcon.h"
#import "./TenpuraProtocol.h"

@interface Tenpura : TenpuraBigIcon {

@private
	//	変数定義
	NETA_DATA_ST		m_data;
	id<TenpuraProtocol>	m_delegate;
	
	BOOL				mb_lock;
	BOOL				mb_fly;	//	揚げる開始
	BOOL				mb_fever;
    BOOL                mb_nonBurn;
	
	Float32				m_baseTimeRate;	//	揚げる速度の基本レート
	Float32				m_raiseTimeRate;	//	揚げる速度のレート
	Float32				m_nowRaiseTime;

	SInt32				m_posDataIdx;
	SInt32				m_oldZOrder;
	CGPoint				m_touchPrevPos;
}

//	プロパティ
@property	(nonatomic, readonly)	SInt32	posDataIdx;
@property	(nonatomic, readonly)	NETA_DATA_ST data;
@property	(nonatomic, retain)		id<TenpuraProtocol>	delegate;
@property   (nonatomic, readwrite)BOOL bNonBurn;

//	セットアップ
-(void)	setupToPosIndex:(const NETA_DATA_ST*)in_pData :(const SInt32)in_posDataIdx :(Float32)in_raiseSpeedRate;
-(void)	setupToPos:(const NETA_DATA_ST*)in_pData :(const CGPoint)in_pos :(Float32)in_raiseSpeedRate;

//	開始
-(void)	start;
//	終了
-(void)	end;

//	リセット
-(void)	reset;

//	タッチ可能か
-(BOOL)	isTouchOK;
//	揚げている途中か
-(BOOL)	isFly;
//	使用中か
-(BOOL)	isUse;

//	状態設定
-(void)	setState:(const TENPURA_STATE_ET)in_eState;

//	食べるアクション
-(void)	eatAction:(Float32)in_time;

-(void)	setPosOfIndex:(const UInt32)in_posDataIdx;
//	揚げる速度変更
-(void)	setRaiseTimeRate:(Float32)in_rate;
//	フィーバー設定
-(void)	setEnableFever:(const BOOL)in_bFlg;

//	タッチロック
-(void)	lockTouch;
-(void)	unLockTouch;
-(void) unLockTouchByPos:(const CGPoint)in_pos;
-(void)	unLockTouchByAct;

-(CGRect)	boundingBox;
-(CGRect)   boundingBoxByTouch;
-(void)	pauseSchedulerAndActions;
-(void)	resumeSchedulerAndActions;

@end
