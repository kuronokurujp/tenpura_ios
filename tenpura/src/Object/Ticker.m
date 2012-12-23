//
//  Ticker.m
//  tenpura
//
//  Created by y.uchida on 12/12/23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Ticker.h"

@interface LeftMoveTicker (PriveteMethod)

-(void)	start;
-(void)	resetPos;

@end

@implementation LeftMoveTicker

/*
	@brief	初期化
*/
-(id)	initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	if( self = [super initWithTexture:texture rect:rect rotated:rotated] )
	{
		[self schedule:@selector(start)];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	start
{
	CGPoint	anchorPos	= [self anchorPoint];
	CGPoint	pos			= [self position];
	CGRect	texRect		= [self textureRect];
		
	CGPoint	limitPos	= ccp( -(texRect.size.width - anchorPos.x), pos.y );
	m_limitPos	= limitPos;
	m_startPos	= pos;

	//	初回アクション
	{
		CCMoveTo*	pMove	= [CCMoveTo actionWithDuration:10.f position:limitPos];
		CCCallFunc*	pEndFunc	= [CCCallFunc actionWithTarget:self selector:@selector(resetPos)];
		CCSequence*	pSeq	= [CCSequence actions:pMove, pEndFunc, nil];
		CCRepeatForever*	pRepeatFor	= [CCRepeatForever actionWithAction:pSeq];
		[self runAction:pRepeatFor];
	}
	
	[self unschedule:_cmd];
}

/*
	@brief
*/
-(void)	resetPos
{
	[self setPosition:m_startPos];
}

@end
