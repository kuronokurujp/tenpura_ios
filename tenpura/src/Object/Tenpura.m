//
//  Tenpura.m
//  tenpura
//
//  Created by y.uchida on 12/09/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tenpura.h"

#import "./../Data/DataTenpuraPosList.h"
#import "./../Data/DataGlobal.h"
#import "./../System/Sound/SoundManager.h"

@interface Tenpura (PrivateMethod)

-(void)		_setup:(NETA_DATA_ST)in_data;
-(CGRect)	_getTexRect:(SInt32)in_idx;

-(void)	_doNextRaise:(ccTime)delta;

@end

@implementation Tenpura

enum
{
	eACTTAG_LOCK_SCALE	= 1
};

//	プロパティ定義
@synthesize state		= m_state;
@synthesize bTouch		= mb_touch;
@synthesize bRaise		= mb_raise;
@synthesize bDelete		= mb_delete;
@synthesize posDataIdx	= m_posDataIdx;
@synthesize data		= m_data;
@synthesize delegate	= m_delegate;

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
		mb_touch		= NO;
		mb_raise		= NO;
		mb_delete		= NO;
		m_posDataIdx	= 0;
		m_raiseSpeedRate	= 1.f;
		m_state			= eTENPURA_STATE_VERYBAD;
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
	@brief	セットアップ
*/
-(void)	setupToPosIndex:(NETA_DATA_ST)in_data:(const UInt32)in_posDataIdx:(Float32)in_raiseSpeedRate
{
	[self _setup:in_data];
	
	//	座標設定
	{
		DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
		TENPURA_POS_ST	tenpuraPosData	= [pDataTenpuraPosList getData:in_posDataIdx];
		[self setPosition:ccp(tenpuraPosData.x, tenpuraPosData.y)];
		
		m_posDataIdx	= in_posDataIdx;
	}
	m_raiseSpeedRate	= in_raiseSpeedRate;
}

/*
	@brief
*/
-(void)	setupToPos:(NETA_DATA_ST)in_data:(const CGPoint)in_pos:(Float32)in_raiseSpeedRate
{
	[self _setup:in_data];

	[self setPosition:in_pos];
	
	m_raiseSpeedRate	= in_raiseSpeedRate;
}

/*
	@brief
*/
-(void)	end
{
	[mp_sp setScale:1.f];
	mb_delete		= NO;
	mb_raise		= NO;
	mb_touch		= NO;
	m_posDataIdx	= 0;

	[self unschedule:@selector(_doNextRaise:)];
	[self setVisible:NO];
}

/*
	@brief
*/
-(void)	setPosOfIndex:(const UInt32)in_posDataIdx
{
	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
	TENPURA_POS_ST	tenpuraPosData	= [pDataTenpuraPosList getData:in_posDataIdx];
	[self setPosition:ccp(tenpuraPosData.x, tenpuraPosData.y)];
		
	m_posDataIdx	= in_posDataIdx;
}

/*
	@brief	揚げる開始
*/
-(void)	startRaise
{
	//	揚げる段階を設定
	m_state		= eTENPURA_STATE_NOT;
	[self schedule:@selector(_doNextRaise:) interval:m_data.aStatusList[m_state].changeTime];
	[self setVisible:YES];
	mb_raise	= YES;
}

/*
	@brief	リセット
*/
-(void)	reset
{
	mb_touch	= NO;
	m_state		= eTENPURA_STATE_NOT;
	[mp_sp setScale:1.f];
	
	//	揚げる段階を設定
	[self unschedule:@selector(_doNextRaise:)];
	[self schedule:@selector(_doNextRaise:) interval:m_data.aStatusList[m_state].changeTime];

	[mp_sp setTextureRect:[self _getTexRect:(SInt32)m_state]];
}

/*
	@brief	オブジェクト矩形取得
*/
-(CGRect)	boundingBox
{
	CGSize	texSize	= [mp_sp textureRect].size;
	//	左下の点を開始点に
	CGPoint	pos	= ccp(	self.position.x - mp_sp.anchorPoint.x * texSize.width,
						self.position.y - mp_sp.anchorPoint.y * texSize.height);
	CGRect	boxRect	= CGRectMake(pos.x, pos.y, texSize.width, texSize.height);
	
	return boxRect;
}

/*
	@brief	タッチロック
*/
-(void)	lockTouch
{
	//	揚げる中止
	[scheduler_ pauseTarget:self];

	CCScaleBy*	pScaleBy	= [CCScaleBy actionWithDuration:0.1f scale:1.5f];
	[pScaleBy setTag:eACTTAG_LOCK_SCALE];

	[mp_sp setScale:1.f];
	[mp_sp runAction:pScaleBy];
	
	m_oldZOrder	= self.zOrder;
	[self setZOrder:30];
	
	mb_touch	= YES;
	m_touchPrevPos	= self.position;
}

/*
	@brief
*/
-(void)	unLockTouch
{
	[scheduler_ resumeTarget:self];
	[mp_sp setScale:1.f];
	
	//	ロック用のスケールが残っていたら削除する
	if( [mp_sp getActionByTag:eACTTAG_LOCK_SCALE] )
	{
		[mp_sp stopActionByTag:eACTTAG_LOCK_SCALE];
	}
	
	[self setZOrder:m_oldZOrder];
	
	mb_touch	= NO;
	[self setPosition:m_touchPrevPos];
}

/*
	@brief
*/
-(CGRect)	_getTexRect:(SInt32)in_idx
{
	return CGRectMake(0, m_texSize.height * in_idx, m_texSize.width, m_texSize.height);
}

/*
	@brief
*/
-(void)	_doNextRaise:(ccTime)delta
{
	++m_state;
	[self unschedule:@selector(_doNextRaise:)];
	
	if( m_state < eTENPURA_STATE_MAX )
	{
		ccTime	time	= 0.f;
		BOOL	bFunc	= NO;

		//	揚げた音
		{
			switch ((SInt32)m_state)
			{
				case eTENPURA_STATE_GOOD:		//　ちょうど良い
				{
					[[SoundManager shared] play:eSOUND_FRIED01];
					break;
				}
				case eTENPURA_STATE_VERYGOOD:	//	最高
				{
					[[SoundManager shared] play:eSOUND_FRIED02];
					break;
				}
				case eTENPURA_STATE_BAD:		//	焦げ
				{
					[[SoundManager shared] play:eSOUND_FRIED03];
					break;
				}
				case eTENPURA_STATE_VERYBAD:	//	丸焦げ
				{
					[[SoundManager shared] play:eSOUND_FRIED04];
					break;
				}
			}
		}

		switch ((SInt32)m_state)
		{
			case eTENPURA_STATE_NOT:		//	揚げてない
			case eTENPURA_STATE_GOOD:		//　ちょうど良い
			case eTENPURA_STATE_VERYGOOD:	//	最高
			case eTENPURA_STATE_BAD:		//	焦げ
			{
				bFunc	= YES;
				time	= (m_data.aStatusList[m_state].changeTime * m_raiseSpeedRate);
				
				[mp_sp setTextureRect:[self _getTexRect:(SInt32)m_state]];
				break;
			}
			case eTENPURA_STATE_VERYBAD:		//	丸焦げ
			{
				bFunc	= YES;
				time	= 1.f;
				
				[mp_sp setTextureRect:[self _getTexRect:(SInt32)m_state]];

				break;
			}
			case eTENPURA_STATE_DEL:	//	消滅
			{
				if( m_delegate != nil )
				{
					if( [m_delegate respondsToSelector:@selector(onDeleteTenpura:)] )
					{
						[m_delegate onDeleteTenpura:self];
					}
				}
				
				if( mb_delete == NO )
				{
					bFunc	= YES;
					time	= 1.f;
				}

				[self setVisible:NO];
				
				break;
			}
			case eTENPUrA_STATE_RESTART:
			{
				//	再配置可能
				break;
			}
		}

		if( bFunc == YES)
		{
			[self schedule:@selector(_doNextRaise:) interval:time];
		}
	}
}

/*
	@brief
*/
-(void)		_setup:(NETA_DATA_ST)in_data
{
	if( mp_sp != nil )
	{
		[self removeChild:mp_sp cleanup:YES];
		mp_sp	= nil;
	}
	
	mb_delete		= NO;
	mb_touch		= NO;
	mb_raise		= NO;

	m_data	= in_data;

	//	ファイル名作成
	NSMutableString*	pFileName	= [NSMutableString stringWithUTF8String:in_data.fileName];
	[pFileName appendString: @".png"];
	mp_sp	= [CCSprite node];
	[mp_sp initWithFile:pFileName];
	NSAssert(mp_sp, @"");
	[self addChild:mp_sp];

	m_state		= eTENPURA_STATE_NOT;
	m_texSize	= [mp_sp contentSize];
	m_texSize.height	= m_texSize.height / (Float32)(eTENPURA_STATE_VERYBAD + 1);

	[mp_sp setTextureRect:[self _getTexRect:(SInt32)m_state]];	
}

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

@end
