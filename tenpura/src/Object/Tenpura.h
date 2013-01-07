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

-(void)	onDeleteTenpura:(CCNode*)in_pTenpura;

@end

typedef enum
{
	eTENPURA_STATE_NOT	= 0,	//	揚げてない
	eTENPURA_STATE_GOOD,		//　ちょうど良い
	eTENPURA_STATE_VERYGOOD,	//	最高
	eTENPURA_STATE_BAD,			//	焦げ
	eTENPURA_STATE_VERYBAD,		//	丸焦げ
	eTENPURA_STATE_DEL,			//	消滅
	eTENPUrA_STATE_RESTART,		//	再設定
	
	eTENPURA_STATE_MAX,
} TENPURA_STATE_ET;

@interface Tenpura : CCNode {

@private
	//	変数定義
	NETA_DATA_ST		m_data;
	CCSprite*			mp_sp;
	id<TenpuraProtocol>	m_delegate;
	
	TENPURA_STATE_ET	m_state;
	BOOL				mb_touch;
	BOOL				mb_delete;
	BOOL				mb_raise;	//	揚げる開始
	
	UInt32				m_posDataIdx;
	SInt32				m_oldZOrder;
	CGSize				m_texSize;
	CGPoint				m_touchPrevPos;
}

//	プロパティ
@property	(nonatomic, readonly)	TENPURA_STATE_ET state;
@property	(nonatomic, readonly)	BOOL	bTouch;
@property	(nonatomic, readonly)	BOOL	bRaise;
@property	(nonatomic, readonly)	BOOL	bDelete;
@property	(nonatomic, readonly)	UInt32	posDataIdx;
@property	(nonatomic, readonly)	NETA_DATA_ST data;
@property	(nonatomic, retain)		id<TenpuraProtocol>	delegate;

//	セットアップ
-(void)	setupToPosIndex:(NETA_DATA_ST)in_data:(const UInt32)in_posDataIdx;
-(void)	setupToPos:(NETA_DATA_ST)in_data:(const CGPoint)in_pos;

-(void)	end;

-(void)	setPosOfIndex:(const UInt32)in_posDataIdx;

//	揚げる開始
-(void)	startRaise;
//	リセット
-(void)	reset;

//	タッチロック
-(void)	lockTouch;
-(void)	unLockTouch;

-(CGRect)	boundingBox;
@end
