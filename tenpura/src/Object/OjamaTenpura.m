//
//  OjamaTenpura.m
//  OjamaTenpura
//
//  Created by y.uchida on 12/09/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "OjamaTenpura.h"

#import "./../Data/DataGlobal.h"
#import	"./../System/Anim/AnimManager.h"
#import "./../System/Sound/SoundManager.h"

@interface OjamaTenpura (PrivateMethod)

-(void)		_setup:(const OJAMA_NETA_DATA*)in_pData;

//	登場演出終了
-(void)	_endPutAction;
//	消滅演出終了
-(void)	_endEatAction;

//	揚げる処理
-(void)	_doNextRaise:(ccTime)delta;
//	揚げる時間を取得
-(Float32)	_getRaiseTime:(SInt32)in_state;

@end

@implementation OjamaTenpura

//	プロパティ定義
@synthesize delegate	= m_delegate;
@synthesize data		= m_data;

enum
{
	eACT_TAG_TOUCH_DEL	= 0,
};

typedef struct
{
	NSString*	pSoundName;
	ccColor3B	col;

} _OJAMA_STATE_DATA_ST;

static const _OJAMA_STATE_DATA_ST	s_ojamaStateDataList[]	=
{
	{nil, { 255, 255, 255 } },
	{@"fride01", { 255, 255 * 0.9f, 255 * 0.9f }},
	{@"fride02", { 255, 255 * 0.8f, 255 * 0.8f }},
	{@"fride03", { 255, 255 * 0.6f, 255 * 0.6f }},
	{@"fride04", { 255, 255 * 0.4f, 255 * 0.4f }},
};

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		memset( &m_data, 0, sizeof(m_data) );
		mp_sp			= nil;
		m_delegate		= nil;
		mb_raise		= NO;
		m_raiseTimeRate	= 1.f;
		m_baseTimeRate	= 1.f;
		m_nowRaiseTime	= 0.f;

		m_state			= 0;
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	mp_sp	= nil;
	[super dealloc];
}

/*
	@brief
*/
-(void)	update:(ccTime)delta
{
	{
		m_nowRaiseTime	+= delta;
		Float32	nextRaiseTime	= [self _getRaiseTime:m_state];
		if( (0.f <= nextRaiseTime) && ( nextRaiseTime <= m_nowRaiseTime ) )
		{
			[self _doNextRaise:0.f];
			m_nowRaiseTime	= 0.f;
		}
	}
}

/*
	@brief	セットアップ
*/
-(void)	setup:(const OJAMA_NETA_DATA*)in_pData :(Float32)in_raiseSpeedRate;
{
	[self _setup:in_pData];
	
	//	座標設定
	{
		CGPoint	pos	= ccp(in_pData->x + CCRANDOM_0_1() * in_pData->randX, in_pData->y + CCRANDOM_0_1() * in_pData->randY);
		[self setPosition:ccp(pos.x, pos.y)];
	}
	m_baseTimeRate	= in_raiseSpeedRate;
}

/*
	@brief	揚げる開始
*/
-(void)	start
{
	//	揚げる段階を設定
	[self reset];
	
	//	配置演出
	{
		[mp_sp setScale:1.2f];
		[mp_sp setOpacity:0];

		Float32	time	= 0.1f;
		CCScaleTo*	pScaleBy	= [CCScaleTo actionWithDuration:time scale:1.f];
		CCFadeIn*	pFadeIn		= [CCFadeIn actionWithDuration:time];
		CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(_endPutAction)];
		CCSequence*	pSeq		= [CCSequence actionOne:pScaleBy two:pEndCall];
		
		[mp_sp runAction:pSeq];
		[mp_sp runAction:pFadeIn];
	}
	
	[self setVisible:YES];
	mb_raise	= YES;
}

/*
	@brief
*/
-(void)	end
{
	[mp_sp setScale:1.f];
	mb_raise		= NO;
	m_nowRaiseTime	= 0.f;

	[self unscheduleAllSelectors];
	[self setVisible:NO];
}

/*
	@brief	リセット
*/
-(void)	reset
{
	m_nowRaiseTime	= 0.f;
	m_state		= 0;
	[mp_sp setScale:1.f];
	
	//	揚げる段階を設定
	[self unscheduleUpdate];
	[self scheduleUpdate];
}

/*
	@brief	タッチ可能か
*/
-(BOOL)	isTouchOK
{
	BOOL	bFlg	= (mb_raise && ([self getActionByTag:eACT_TAG_TOUCH_DEL] == nil));
	return bFlg;
}

/*
	@brief	タッチ消滅アクション
*/
-(void)	runTouchDelAction
{
	ccBezierConfig	bezier;
	
	bezier.controlPoint_1	= ccp(0, SCREEN_SIZE_HEIGHT * 0.5f);
	bezier.controlPoint_2	= ccp(-SCREEN_SIZE_WIDTH * 0.5f, SCREEN_SIZE_HEIGHT);
	bezier.endPosition	= ccp(-SCREEN_SIZE_WIDTH * 0.8f, SCREEN_SIZE_HEIGHT);
	CCBezierBy*	pBezierAct	= [CCBezierBy actionWithDuration:1.f bezier:bezier];
	CCCallBlock*	pEndAct	= [CCCallBlock actionWithBlock:^{
		[self removeFromParentAndCleanup:YES];
	}];

	CCSequence*	pSeq	= [CCSequence actionOne:pBezierAct two:pEndAct];
	pSeq.tag	= eACT_TAG_TOUCH_DEL;
	[self runAction:pSeq];
}

/*
	@brief
*/
- (CGRect) boundingBox
{
	CGSize	texSize	= [mp_sp textureRect].size;
	//	左下の点を開始点に
	CGPoint	pos	= ccp(	self.position.x - mp_sp.anchorPoint.x * texSize.width,
						self.position.y - mp_sp.anchorPoint.y * texSize.height);
	CGRect	boxRect	= CGRectMake(pos.x, pos.y, texSize.width, texSize.height);
	
	return boxRect;
}

/*
	@brief	揚げる速度変更;
*/
-(void)	setRaiseTimeRate:(Float32)in_rate
{
	m_raiseTimeRate	= in_rate;
}

/*
	@brief	ポーズ
*/
-(void)	pauseSchedulerAndActions
{
	[super pauseSchedulerAndActions];
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		[pNode pauseSchedulerAndActions];
	}
}

/*
	@brief	再開
*/
-(void)	resumeSchedulerAndActions
{
	[super resumeSchedulerAndActions];
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		[pNode resumeSchedulerAndActions];
	}
}

/*
	@brief	登場演出終了
*/
-(void)	_endPutAction
{
}

/*
	@brief	消滅演出終了
*/
-(void)	_endEatAction
{
}

/*
	@brief
*/
-(void)	_doNextRaise:(ccTime)delta
{
	++m_state;
	
	SInt32	timeCnt	= sizeof(m_data.aChangeTime) / sizeof(m_data.aChangeTime[0]);
	if( m_state < timeCnt )
	{
		if( s_ojamaStateDataList[m_state].pSoundName )
		{
			[[SoundManager shared] playSe:s_ojamaStateDataList[m_state].pSoundName];
		}
		
		[mp_sp setColor:s_ojamaStateDataList[m_state].col];
	}
	else if( m_state == timeCnt )
	{
		//	爆発
		if( m_delegate != nil )
		{
			[m_delegate onExpTenpura:self];
		}

		[self removeFromParentAndCleanup:YES];
	}
}

/*
	@brief
*/
-(void)		_setup:(const OJAMA_NETA_DATA*)in_pData
{
	NSAssert(in_pData, @"");
	if( mp_sp != nil )
	{
		[self removeChild:mp_sp cleanup:YES];
		mp_sp	= nil;
	}
	
	mb_raise	= NO;

	m_data	= *in_pData;

	//	ファイル名作成
	NSMutableString*	pFileName	= [NSMutableString stringWithUTF8String:in_pData->fileName];
	[pFileName appendString: @".png"];
	mp_sp	= [CCSprite node];
	[mp_sp initWithFile:pFileName];
	NSAssert(mp_sp, @"");
	[self addChild:mp_sp];

	m_state		= 0;
}

/*
	@brief	揚げる時間を取得
*/
-(Float32)	_getRaiseTime:(SInt32)in_state
{
	Float32	raiseSpeedRate	= (m_baseTimeRate * m_raiseTimeRate);
	Float32	time	= -1.f;
	
	SInt32	timeCnt	= sizeof(m_data.aChangeTime) / sizeof(m_data.aChangeTime[0]);
	if( in_state < timeCnt )
	{
		time	= (m_data.aChangeTime[m_state] * raiseSpeedRate);
	}

	return time;
}

#if 1

#ifdef DEBUG
-(void)	draw
{
	[super draw];

	ccDrawColor4B(255, 0, 255, 255);
	CGPoint	p1,p2,p3,p4;
	
	CGRect	rect	= [self boundingBox];
	//	オブジェクト描画位置が原点になるので原点値を引く
	rect.origin.x	= rect.origin.x - self.position.x;
	rect.origin.y	= rect.origin.y - self.position.y;

	p1	= ccp(rect.origin.x,rect.origin.y);
	p2	= ccp(rect.origin.x,rect.origin.y + rect.size.height);
	p3	= ccp(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height);
	p4	= ccp(rect.origin.x + rect.size.width,rect.origin.y);

	ccDrawLine(p1,p2);
	ccDrawLine(p2,p3);
	ccDrawLine(p3,p4);
	ccDrawLine(p4,p1);
	
	ccDrawColor4B(255, 255, 255, 255);
}
#endif
#endif

@end
