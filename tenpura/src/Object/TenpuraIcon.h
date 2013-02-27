//
//  TenpuraIcon.h
//  tenpura
//
//  Created by y.uchida on 12/10/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "../Data/DataNetaList.h"

typedef enum
{
	eTENPURA_STATE_VERYGOOD	= 0,	//	最高
	eTENPURA_STATE_BAD,				//	焦げ
	eTENPURA_STATE_VERYBAD,			//	丸焦げ
	eTENPURA_STATE_EXP,				//	爆発
	eTENPURA_STATE_RESTART,			//	再設定
	
	eTENPURA_STATE_MAX,
} TENPURA_STATE_ET;

@interface TenpuraBigIcon : CCNode {

@protected
	//	変数定義
	CCSprite*			mp_sp;
	TENPURA_STATE_ET	m_state;
	CGSize				m_texSize;
}

@property	(nonatomic, readonly)TENPURA_STATE_ET	state;

//	セットアップ
-(void)	setupToPos:(const NETA_DATA_ST*)in_pData :(const CGPoint)in_pos :(Float32)in_raiseSpeedRate;
-(void)	setup:(const NETA_DATA_ST*)in_pData;

@end

@interface TenpuraIcon : CCNode
{
@private
	CCSprite*	mp_sp;
	SInt32		m_no;
}

@property	(nonatomic, readonly)SInt32 no;

//	関数
-(id)	initWithSetup:(const NETA_DATA_ST*)in_pData;

-(void)	setup:(const NETA_DATA_ST*)in_pData;

@end
