//
//  OjamaTenpura.h
//  OjamaTenpura
//
//  Created by y.uchida on 12/09/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "./../Data/DataOjamaNetaList.h"
#import "./TenpuraProtocol.h"

@interface OjamaTenpura : CCNode {

@private
	//	変数定義
	OJAMA_NETA_DATA		m_data;
	id<TenpuraProtocol>	m_delegate;

	CCSprite*			mp_sp;
	BOOL				mb_fly;	//	揚げる開始
	
	Float32				m_baseTimeRate;	//	揚げる速度の基本レート
	Float32				m_raiseTimeRate;	//	揚げる速度のレート
	Float32				m_nowRaiseTime;
	
	SInt32				m_state;
}

//	プロパティ
@property	(nonatomic, retain)		id<TenpuraProtocol>	delegate;
@property	(nonatomic, readonly)	OJAMA_NETA_DATA	data;

//	セットアップ
-(void)	setup:(const OJAMA_NETA_DATA*)in_pData :(Float32)in_raiseSpeedRate;

//	開始
-(void)	start;
//	終了
-(void)	end;

//	リセット
-(void)	reset;

//	タッチ可能か
-(BOOL)	isTouchOK;

//	タッチ消滅アクション
-(void)	runTouchDelAction;

- (CGRect) boundingBox;

//	揚げる速度変更
-(void)	setRaiseTimeRate:(Float32)in_rate;

-(void)	pauseSchedulerAndActions;
-(void)	resumeSchedulerAndActions;

@end
