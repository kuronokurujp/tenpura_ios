//
//  EffectActionSprite.m
//  tenpura
//
//  Created by y.uchida on 13/01/06.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "EffectActionSprite.h"

@implementation EffectData

@synthesize fileName	= mp_fileName;
@synthesize fileImageName	= mp_fileImageName;
@synthesize spriteFileNameList	= mp_spriteFileNamList;
@synthesize fileNum	= m_fileNum;
@synthesize fps	= m_fps;

/*
	@brief
*/
-(id)	initWithData:(const char*)in_pFileName:(const char*)in_pFileImageName:(const char**)in_pFrameNameList:(const UInt32)in_FrameNum:(const UInt32)in_fps;
{
	if( self = [super init] )
	{
		mp_fileName	= [[NSString stringWithUTF8String:in_pFileName] retain];
		mp_fileImageName	= [[NSString stringWithUTF8String:in_pFileImageName] retain];
		m_fps	= in_fps;
		m_fileNum	= in_FrameNum;
		
		mp_spriteFileNamList	= [[CCArray alloc] initWithCapacity:m_fileNum];
		for( UInt32 i = 0; i < in_FrameNum; ++i )
		{
			[mp_spriteFileNamList addObject:[NSString stringWithUTF8String:in_pFrameNameList[i]]];
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
	[mp_spriteFileNamList release];
	[super dealloc];
}

@end

@interface EffectActionSprite (PriveteMethod)

-(void)	endAnim;

@end
@implementation EffectActionSprite

/*
	@brief	初期化
*/
-(id)	initWithData:(EffectData*)in_data
{
	NSAssert(in_data, @"エフェクトデータがない");
	if( self = [super init] )
	{
		mp_data	= [in_data retain];

		CCSpriteFrameCache*	pFrameCache	= [CCSpriteFrameCache sharedSpriteFrameCache];
		[pFrameCache addSpriteFramesWithFile:in_data.fileName];

		mp_sp	= [CCSprite spriteWithSpriteFrameName:[in_data.spriteFileNameList objectAtIndex:0]];
		NSMutableArray*	pFrames	= [NSMutableArray arrayWithCapacity:in_data.fileNum];
		for( UInt32 i = 1; i < in_data.fileNum; ++i )
		{
			NSString*	pFileName	= [in_data.spriteFileNameList objectAtIndex:i];
			CCSpriteFrame*	pFrame	= [pFrameCache spriteFrameByName:pFileName];
			
			[pFrames addObject:pFrame];
		}
		
		Float32	delay	= 1.f / (Float32)in_data.fps;
		CCAnimation*	pAnim	= [[[CCAnimation alloc] initWithSpriteFrames:pFrames delay:delay] autorelease];
		
		CCAnimate*	pAnimate	= [CCAnimate actionWithAnimation:pAnim];
		CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(endAnim)];
		CCSequence*	pSeq	= [CCSequence actions:pAnimate, pEndCall, nil];
		[mp_sp runAction:pSeq];
				
		[self addChild:mp_sp];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[mp_data release];
	[super dealloc];
}

/*
	@brief
*/
-(void)	endAnim
{
	[self removeFromParentAndCleanup:YES];
}

@end
