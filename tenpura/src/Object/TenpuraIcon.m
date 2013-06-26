//
//  TenpuraIcon.m
//  tenpura
//
//  Created by y.uchida on 12/10/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TenpuraIcon.h"

@interface TenpuraBigIcon (PrivateMethod)

-(CGRect)	_getTexRect:(SInt32)in_idx;

@end

@implementation TenpuraBigIcon

@synthesize state		= m_state;

//	仮
static const Float32	s_tenpuraFlyStateMax	= 3;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_sp			= nil;
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
	@brief
*/
-(void)	setupToPos:(const NETA_DATA_ST*)in_pData :(const CGPoint)in_pos :(Float32)in_raiseSpeedRate
{
	[self setup:in_pData];

	[self setPosition:in_pos];
}

/*
	@brief
*/
-(void)		setup:(const NETA_DATA_ST*)in_pData
{
	NSAssert(in_pData, @"");

	if( mp_sp != nil )
	{
		[self removeChild:mp_sp cleanup:YES];
		mp_sp	= nil;
	}
	
	//	ファイル名作成
	NSMutableString*	pFileName	= [NSMutableString stringWithUTF8String:in_pData->fileName];
	[pFileName appendString: @".png"];
	mp_sp	= [CCSprite node];
	[mp_sp initWithFile:pFileName];
	NSAssert(mp_sp, @"");
	[self addChild:mp_sp];

	m_state		= eTENPURA_STATE_VERYGOOD;
	m_texSize	= [mp_sp contentSize];
	m_texSize.height	= m_texSize.height / (s_tenpuraFlyStateMax);

	[mp_sp setTextureRect:[self _getTexRect:(SInt32)m_state]];	
}

/*
	@brief
*/
-(CGRect)	_getTexRect:(SInt32)in_idx
{
	return CGRectMake(0, m_texSize.height * in_idx, m_texSize.width, m_texSize.height);
}

@end

@implementation TenpuraIcon

@synthesize no	= m_no;

/*
	@brief	初期化
*/
-(id)	initWithSetup:(const NETA_DATA_ST*)in_pData;
{
	if( self = [super init] )
	{
		[self setup:in_pData];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	setup:(const NETA_DATA_ST*)in_pData
{
	NSAssert(in_pData, @"");

	NSString*	pFileName	= [NSString stringWithFormat:@"cust_%s.png", in_pData->fileName];
	if( mp_sp != nil )
	{
		[self removeChild:mp_sp cleanup:YES];
	}

	mp_sp	= [CCSprite node];
	[mp_sp initWithFile:pFileName];
		
	[mp_sp setAnchorPoint:ccp(0,0)];
	[self addChild:mp_sp];
	
	m_no	= in_pData->no;
}

-(void) setColor:(ccColor3B)color3
{
    CCNode* pNode   = nil;
    CCARRAY_FOREACH(_children, pNode)
    {
        if( [pNode isKindOfClass:[CCSprite class]] )
        {
            CCSprite*   pSprite = (CCSprite*)pNode;
            [pSprite setColor:color3];
        }
    }
}

@end
