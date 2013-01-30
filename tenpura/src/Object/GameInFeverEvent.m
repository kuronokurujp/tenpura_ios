//
//  GameInFeverEvent.m
//  tenpura
//
//  Created by y.uchida on 13/01/28.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameInFeverEvent.h"

@interface GameInFeverEvent (PrivateMethod)

//	開始イベントアクション終了
-(void)	_endStartAct;

@end

@implementation GameInFeverEvent

-(id)	init
{
	if( self = [super init] )
	{
	}
	
	return self;
}

/*
	@brief	開始
*/
-(void)	start
{
	[self setScale:1.f];
	[self setOpacity:255];
	[self setVisible:YES];
	
	CCScaleTo*	pScaleAct	= [CCScaleTo actionWithDuration:1 scaleX:1.2 scaleY:1];
	CCFadeOut*	pFaceOutAct	= [CCFadeOut actionWithDuration:1.f];
	CCCallFunc*	pEndFunc	= [CCCallFunc actionWithTarget:self selector:@selector(_endStartAct)];

	CCSequence*	pSeq	= [CCSequence actions:pScaleAct, pEndFunc, nil];
	[self runAction:pSeq];
	[self runAction:pFaceOutAct];
}

/*
	@brief	開始イベントアクション終了
*/
-(void)	_endStartAct
{
	[self setVisible:NO];
}

@end
