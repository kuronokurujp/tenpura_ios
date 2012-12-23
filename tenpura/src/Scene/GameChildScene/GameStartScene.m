//
//  GameStartScene.m
//  tenpura
//
//  Created by y.uchida on 12/10/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameStartScene.h"

#import "./../GameScene.h"
#import "./../../Object/Customer.h"

//	非公開関数
@interface GameStartScene (PrivateMethod)

//	客登場演出
-(void)	_beginByCustomerPut:(ccTime)in_time;
-(void)	_updataByCustomerPut:(ccTime)in_time;
-(void)	_endByCustomerPut:(ccTime)in_time;

//	開始演出
-(void)	_beginByStartLogoEvent:(ccTime)in_time;
-(void)	_endInMoveByStartLogoEvent;
-(void)	_beginOutMoveByStartLogEvent:(ccTime)in_time;
-(void)	_endByStartLogoEvent;

@end

@implementation GameStartScene

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init])
	{
		[self schedule:@selector(_beginByCustomerPut:)];
		[self setVisible:YES];
		
		mp_startLogoSp	= [CCSprite	spriteWithFile:@"play_start.png"];
		[mp_startLogoSp setVisible:NO];
		[self addChild:mp_startLogoSp];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	_beginByCustomerPut:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)self.parent;
	[pGameScene putCustomer:NO];
	
	[self unschedule:_cmd];
	[self schedule:@selector(_updataByCustomerPut:)];
}

/*
	@brief
*/
-(void)	_updataByCustomerPut:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)self.parent;

	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
	{
		if( ( pCustomer.visible == YES ) && ( pCustomer.bPut == YES ) )
		{
			[self unschedule:_cmd];
			[self schedule:@selector(_endByCustomerPut:)];
			break;
		}
	}
}

/*
	@brief
*/
-(void)	_endByCustomerPut:(ccTime)in_time
{
	[self unschedule:_cmd];
	[self schedule:@selector(_beginByStartLogoEvent:)];
}

/*
	@brief
*/
-(void)	_beginByStartLogoEvent:(ccTime)in_time
{
	[self unschedule:_cmd];
	
	//	ロゴスタート演出
	{
		CGSize	size		= [CCDirector sharedDirector].winSize;
		CGPoint	startPos	= ccp(size.width * 2.f, size.height * 0.5f);
		CGPoint	endPos		= ccp(size.width * 0.5f, startPos.y);
		
		[mp_startLogoSp setPosition:startPos];
	
		CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.5f position:endPos];
		CCEaseInOut*	pEaseMove	= [CCEaseInOut actionWithAction:pMove rate:4];

		CCCallFunc*		pEndFunc	= [CCCallFunc actionWithTarget:self selector:@selector(_endInMoveByStartLogoEvent)];
		CCSequence*		pSeq		= [CCSequence actions:pEaseMove, pEndFunc, nil];

		[mp_startLogoSp runAction:pSeq];
		[mp_startLogoSp setVisible:YES];
	}
}

/*
	@brief
*/
-(void)	_endInMoveByStartLogoEvent
{
	[self scheduleOnce:@selector(_beginOutMoveByStartLogEvent:) delay:2.f];
}

/*
	@brief
*/
-(void)	_beginOutMoveByStartLogEvent:(ccTime)in_time
{
	CGRect	texRect	= [mp_startLogoSp textureRect];
	CGPoint	pos	= ccp( 0 - (texRect.size.width * 2.f), mp_startLogoSp.position.y );

	CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.f position:pos];
	CCEaseIn*		pEaseMove	= [CCEaseIn actionWithAction:pMove rate:3];
	
	CCCallFuncN*	pEndFunc	= [CCCallFuncN actionWithTarget:self selector:@selector(_endByStartLogoEvent)];
	CCSequence*		pSeq		= [CCSequence actions:pEaseMove, pEndFunc, nil];
	
	[mp_startLogoSp runAction:pSeq];
}

/*
	@brief
*/
-(void)	_endByStartLogoEvent
{
	[mp_startLogoSp setVisible:NO];
	[self setVisible:NO];
}

@end
