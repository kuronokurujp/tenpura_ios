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
	eTENPURA_STATE_NOT	= 0,	//	揚げてない
	eTENPURA_STATE_GOOD,		//　ちょうど良い
	eTENPURA_STATE_VERYGOOD,	//	最高
	eTENPURA_STATE_BAD,			//	焦げ
	eTENPURA_STATE_VERYBAD,		//	丸焦げ
	eTENPURA_STATE_EXP,			//	爆発
	eTENPURA_STATE_RESTART,		//	再設定
	
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
-(void)	setupToPos:(NETA_DATA_ST)in_data :(const CGPoint)in_pos :(Float32)in_raiseSpeedRate;

@end

@interface TenpuraIcon : CCNode
{
@private
	CCSprite*	mp_sp;
	SInt32		m_no;
}

@property	(nonatomic, readonly)SInt32 no;

//	関数
-(id)	initWithFile:(NSString*)in_pFileName :(SInt32)in_no;

@end
