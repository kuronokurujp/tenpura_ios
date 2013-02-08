//
//  AnimActionSprite.m
//  tenpura
//
//  Created by y.uchida on 13/01/06.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "AnimActionSprite.h"

@implementation AnimData

@synthesize fileName	= mp_fileName;
@synthesize fileImageName	= mp_fileImageName;
@synthesize frameNameList	= mp_frameNameList;
@synthesize fps	= m_fps;

/*
	@brief
*/
-(id)	initWithData:(const char*)in_pFileName :(const char*)in_pFileImageName :(const UInt32)in_fps;
{
	if( self = [super init] )
	{
		mp_fileName	= nil;
		mp_frameNameList	= nil;
		mp_fileImageName	= nil;
		
		mp_fileName	= [[NSString stringWithUTF8String:in_pFileName] retain];
		mp_fileImageName	= [[NSString stringWithUTF8String:in_pFileImageName] retain];
		m_fps	= in_fps;
		
		//	フレームリスト作成
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:mp_fileName ofType:@""];
		NSDictionary*	pAnimList	= [NSDictionary dictionaryWithContentsOfFile:pPath];
		NSDictionary*	pFrameList	= [pAnimList valueForKey:@"frames"];
		if( pFrameList )
		{
			NSArray*	pFrameNameList	= [[pFrameList allKeys] sortedArrayUsingSelector:@selector(compare:)];
			mp_frameNameList	= [pFrameNameList retain];
		}
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[mp_fileImageName release];
	[mp_fileName release];
	[mp_frameNameList release];

	[super dealloc];
}

@end

@interface AnimActionSprite (PriveteMethod)

-(void)	_init:(AnimData*)in_pData :(BOOL)in_bLoop;
-(void)	_endAnim;

@end
@implementation AnimActionSprite

@synthesize bLoop	= mb_loop;

/*
	@brief	初期化
*/
-(id)	initWithData:(AnimData*)in_data
{
	if( self = [super init] )
	{
		[self _init:in_data :false];
	}

	return self;
}

/*
	@brief
*/
-(id)	initWithDataAndLoop:(AnimData*)in_data
{
	if( self = [super init] )
	{
		[self _init:in_data :true];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[mp_anim release];
	[mp_data release];
	[super dealloc];
}

/*
	@brief	初期化
*/
-(void)	_init:(AnimData*)in_data :(BOOL)in_bLoop
{
	NSAssert(in_data, @"アニメデータがない");
	{
		mb_loop	= in_bLoop;
		mp_data	= [in_data retain];

		CCSpriteFrameCache*	pFrameCache	= [CCSpriteFrameCache sharedSpriteFrameCache];
		[pFrameCache addSpriteFramesWithFile:in_data.fileName];

		UInt32	frameNum	= [in_data.frameNameList count];

		mp_sp	= [CCSprite spriteWithSpriteFrameName:[in_data.frameNameList objectAtIndex:0]];
		NSMutableArray*	pFrames	= [NSMutableArray arrayWithCapacity:frameNum];
		for( UInt32 i = 1; i < frameNum; ++i )
		{
			NSString*	pFileName	= [in_data.frameNameList objectAtIndex:i];
			CCSpriteFrame*	pFrame	= [pFrameCache spriteFrameByName:pFileName];
			
			[pFrames addObject:pFrame];
		}
		
		Float32	delay	= 1.f / (Float32)in_data.fps;
		CCAnimation*	pAnim	= [[[CCAnimation alloc] initWithSpriteFrames:pFrames delay:delay] autorelease];
		mp_anim	= [pAnim retain];

		[self addChild:mp_sp];
		mb_pause	= YES;
	}
}

/*
	@brief
*/
-(void)	start
{
	CCAnimate*	pAnimate	= [CCAnimate actionWithAnimation:mp_anim];
	if( mb_loop == false )
	{
		CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(_endAnim)];
		CCSequence*	pSeq	= [CCSequence actions:pAnimate, pEndCall, nil];
		[mp_sp runAction:pSeq];
	}
	else
	{
		//	ループの設定をしているならループ用アニメを作成する
		CCRepeatForever*	pRepeat	= [CCRepeatForever actionWithAction:pAnimate];
		[mp_sp runAction:pRepeat];
	}
	
	mb_pause	= NO;
}

/*
	@brief
*/
-(void)	end
{
	[mp_sp stopAllActions];
	mb_pause	= YES;
}

/*
	@brief
*/
-(void)	_endAnim
{
//	[self removeFromParentAndCleanup:YES];
	[self setVisible:NO];
}

/*
	@brief
*/
-(void)	pauseSchedulerAndActions
{
	if( mb_pause == YES )
	{
		return;
	}
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		[pNode pauseSchedulerAndActions];
	}
	
	[super pauseSchedulerAndActions];
}

/*
	@brief
*/
-(void)	resumeSchedulerAndActions
{
	if( mb_pause == YES )
	{
		return;
	}
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		[pNode resumeSchedulerAndActions];
	}

	[super resumeSchedulerAndActions];
}

@end
