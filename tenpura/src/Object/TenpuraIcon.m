//
//  TenpuraIcon.m
//  tenpura
//
//  Created by y.uchida on 12/10/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TenpuraIcon.h"

@interface TenpuraBigIcon (PrivateMethod)

-(void)		_setup:(NETA_DATA_ST)in_data;
-(CGRect)	_getTexRect:(SInt32)in_idx;

@end

@implementation TenpuraBigIcon

@synthesize state		= m_state;

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
-(void)	setupToPos:(NETA_DATA_ST)in_data :(const CGPoint)in_pos :(Float32)in_raiseSpeedRate
{
	[self _setup:in_data];

	[self setPosition:in_pos];
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
-(id)	initWithFile:(NSString*)in_pFileName :(SInt32)in_no
{
	if( self = [super init] )
	{
		mp_sp	= [CCSprite node];
		[mp_sp initWithFile:in_pFileName];
		
		[mp_sp setAnchorPoint:ccp(0,0)];
		[self addChild:mp_sp];
		
		m_no	= in_no;
	}
	
	return self;
}

@end
