//
//  Tenpura.m
//  tenpura
//
//  Created by y.uchida on 12/09/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tenpura.h"


@interface Tenpura (PrivateMethod)

-(CGRect)	getTexRect:(SInt32)in_idx;

-(void)	doNextRaise:(ccTime)delta;
-(void)	onDoDeleteState;

@end

@implementation Tenpura

//	プロパティ定義
@synthesize state	= m_state;
@synthesize bTouch	= mb_touch;
@synthesize data	= m_data;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		memset( &m_data, 0, sizeof(m_data) );
		mp_sp	= nil;
		mb_touch	= NO;
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	mp_sp	= nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

/*
	@brief	セットアップ
*/
-(void)	setup:(NETA_DATA_ST)in_data:(CGPoint)in_pos
{
	if( mp_sp != nil )
	{
		[self removeChild:mp_sp cleanup:YES];
		mp_sp	= nil;
	}
	
	mb_deletePermit	= NO;
	m_data	= in_data;

	//	ファイル名作成
	NSMutableString*	pFileName	= [NSMutableString stringWithUTF8String:in_data.fileName];
	[pFileName appendString: @".png"];
	mp_sp	= [CCSprite node];
	[mp_sp initWithFile:pFileName];
	[self addChild:mp_sp];

	m_state		= eTENPURA_STATE_NOT;
	m_texSize	= [mp_sp contentSize];
	m_texSize.height	= m_texSize.height / (Float32)(eTENPURA_STATE_ALLBAD + 1);

	[self setPosition:in_pos];
	[mp_sp setTextureRect:[self getTexRect:(SInt32)m_state]];	
}

/*
	@brief
*/
-(void)	end
{
	[mp_sp setScale:1.f];

	[self unschedule:@selector(doNextRaise:)];
	[self setVisible:NO];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
	@brief	揚げる開始
*/
-(void)	startRaise
{
	//	揚げる段階を設定
	m_state		= eTENPURA_STATE_NOT;
	[self schedule:@selector(doNextRaise:) interval:m_data.changeTime[m_state]];
	[self setVisible:YES];
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
	[self unschedule:@selector(doNextRaise:)];
	[self schedule:@selector(doNextRaise:) interval:m_data.changeTime[m_state]];

	[mp_sp setTextureRect:[self getTexRect:(SInt32)m_state]];
}

/*
	@brief	天ぷら削除許可通知設定
*/
-(void)	registDeletePermitObserver:(NSString*)in_pName
{
	NSAssert(in_pName, @"名前設定がない");
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(onDoDeleteState) name:in_pName object:nil];
}

/*
	@brief	オブジェクト矩形取得
*/
-(CGRect)	getBoxRect
{
	CGSize	texSize	= [mp_sp textureRect].size;
	CGRect	boxRect	= CGRectMake(self.position.x - texSize.width * 0.5f, self.position.y - texSize.height * 0.5f, texSize.width, texSize.height);
	
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
	[mp_sp setScale:1.f];
	[mp_sp runAction:pScaleBy];
	
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
	
	mb_touch	= NO;
	[self setPosition:m_touchPrevPos];
}

/*
	@brief
*/
-(CGRect)	getTexRect:(SInt32)in_idx
{
	return CGRectMake(0, m_texSize.height * in_idx, m_texSize.width, m_texSize.height);
}

/*
	@brief
*/
-(void)	doNextRaise:(ccTime)delta
{
	++m_state;
	[self unschedule:@selector(doNextRaise:)];
	
	if( m_state < eTENPURA_STATE_MAX )
	{
		ccTime	time	= 0.f;
		BOOL	bFunc	= NO;
		switch ((SInt32)m_state)
		{
			case eTENPURA_STATE_NOT:	//	揚げてない
			case eTENPURA_STATE_GOOD:	//　ちょうど良い
			{
				bFunc	= YES;
				time	= m_data.changeTime[m_state];
				break;
			}
			case eTENPURA_STATE_VERYGOOD:		//	最高
			{
				bFunc	= YES;
				time	= m_data.changeTime[m_state];
				break;
			}
			case eTENPURA_STATE_BAD:			//	焦げ
			{
				bFunc	= YES;
				time	= m_data.changeTime[m_state];
				break;
			}
			case eTENPURA_STATE_ALLBAD:		//	丸焦げ
			{
				if( mb_deletePermit == YES )
				{
					bFunc	= YES;
					time	= 1.f;
				}
				else
				{
					[self reset];
				}

				break;
			}
			case eTENPURA_STATE_DEL:	//	消滅
			{
				break;
			}
		}

		if( bFunc == YES)
		{
			[self schedule:@selector(doNextRaise:) interval:time];
			[mp_sp setTextureRect:[self getTexRect:(SInt32)m_state]];
		}
	}
}

/*
	@brief
*/
-(void)	onDoDeleteState
{
	mb_deletePermit	= YES;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#ifdef DEBUG
-(void)	draw
{
	[super draw];

	ccDrawColor4B(255, 0, 255, 255);
	CGPoint	p1,p2,p3,p4;
	
	CGRect	rect	= [self getBoxRect];
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
