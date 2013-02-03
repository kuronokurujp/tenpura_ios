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

/*
	@brief	天ぷらデリゲータ
*/
@protocol TenpuraProtocol<NSObject>

//	天ぷら爆発
-(void)	onExpTenpura:(CCNode*)in_pTenpura;
//	天ぷらをつける
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;

@end

typedef enum
{
	eTENPURA_STATE_NOT	= 0,	//	揚げてない
	eTENPURA_STATE_GOOD,		//　ちょうど良い
	eTENPURA_STATE_VERYGOOD,	//	最高
	eTENPURA_STATE_BAD,			//	焦げ
	eTENPURA_STATE_VERYBAD,		//	丸焦げ
	eTENPURA_STATE_EXP,			//	爆発
	eTENPURA_STATE_RESTART,		//	再設定
	
	eTENPURA_STATE_MAX,
} TENPURA_STATE_ET;

@interface Tenpura : CCNode {

@private
	//	変数定義
	NETA_DATA_ST		m_data;
	CCSprite*			mp_sp;
	id<TenpuraProtocol>	m_delegate;
	
	TENPURA_STATE_ET	m_state;
	BOOL				mb_lock;
	BOOL				mb_raise;	//	揚げる開始
	
	Float32				m_baseSpeedRate;	//	揚げる速度の基本レート
	Float32				m_raiseSpeedRate;	//	揚げる速度のレート
	Float32				m_raiseTime;

	SInt32				m_posDataIdx;
	SInt32				m_oldZOrder;
	CGSize				m_texSize;
	CGPoint				m_touchPrevPos;
}

//	プロパティ
@property	(nonatomic, readonly)	TENPURA_STATE_ET state;
@property	(nonatomic, readonly)	BOOL	bTouch;
@property	(nonatomic, readonly)	BOOL	bRaise;
@property	(nonatomic, readonly)	SInt32	posDataIdx;
@property	(nonatomic, readonly)	NETA_DATA_ST data;
@property	(nonatomic, retain)		id<TenpuraProtocol>	delegate;

//	セットアップ
-(void)	setupToPosIndex:(NETA_DATA_ST)in_data:(const SInt32)in_posDataIdx:(Float32)in_raiseSpeedRate;
-(void)	setupToPos:(NETA_DATA_ST)in_data:(const CGPoint)in_pos:(Float32)in_raiseSpeedRate;

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
-(void)	setRaiseSpeedRate:(Float32)in_rate;

//	タッチロック
-(void)	lockTouch;
-(void)	unLockTouch;

-(CGRect)	boundingBox;
-(void)	pauseSchedulerAndActions;
-(void)	resumeSchedulerAndActions;

@end
