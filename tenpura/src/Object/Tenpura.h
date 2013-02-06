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

/*
	@brief	天ぷらデリゲータ
*/
@protocol TenpuraProtocol<NSObject>

//	天ぷら爆発
-(void)	onExpTenpura:(CCNode*)in_pTenpura;
//	天ぷらをつける
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;

@end

@interface Tenpura : TenpuraBigIcon {

@private
	//	変数定義
	NETA_DATA_ST		m_data;
	id<TenpuraProtocol>	m_delegate;
	
	BOOL				mb_lock;
	BOOL				mb_raise;	//	揚げる開始
	
	Float32				m_baseTimeRate;	//	揚げる速度の基本レート
	Float32				m_raiseTimeRate;	//	揚げる速度のレート
	Float32				m_nowRaiseTime;

	SInt32				m_posDataIdx;
	SInt32				m_oldZOrder;
	CGPoint				m_touchPrevPos;
}

//	プロパティ
@property	(nonatomic, readonly)	BOOL	bTouch;
@property	(nonatomic, readonly)	BOOL	bRaise;
@property	(nonatomic, readonly)	SInt32	posDataIdx;
@property	(nonatomic, readonly)	NETA_DATA_ST data;
@property	(nonatomic, retain)		id<TenpuraProtocol>	delegate;

//	セットアップ
-(void)	setupToPosIndex:(NETA_DATA_ST)in_data :(const SInt32)in_posDataIdx :(Float32)in_raiseSpeedRate;
-(void)	setupToPos:(NETA_DATA_ST)in_data :(const CGPoint)in_pos :(Float32)in_raiseSpeedRate;

//	開始
-(void)	start;
//	終了
-(void)	end;

//	リセット
-(void)	reset;

//	食べるアクション
-(void)	eatAction:(Float32)in_time;

-(void)	setPosOfIndex:(const UInt32)in_posDataIdx;
//	揚げる速度変更
-(void)	setRaiseTimeRate:(Float32)in_rate;

//	タッチロック
-(void)	lockTouch;
-(void)	unLockTouch;

-(CGRect)	boundingBox;
-(void)	pauseSchedulerAndActions;
-(void)	resumeSchedulerAndActions;

@end
