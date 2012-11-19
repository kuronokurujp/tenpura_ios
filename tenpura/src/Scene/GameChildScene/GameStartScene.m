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

-(void)	_begin:(ccTime)in_time;
-(void)	_end:(ccTime)in_time;

@end

@implementation GameStartScene

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init])
	{
		[self schedule:@selector(_begin:)];
		[self setVisible:YES];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	_begin:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)self.parent;
	[pGameScene putCustomer:NO];
	
	[self unschedule:_cmd];
	[self scheduleUpdate];
}

/*
	@brief
*/
-(void)	update:(ccTime)delta
{
	GameScene*	pGameScene	= (GameScene*)self.parent;

	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
	{
		if( ( pCustomer.visible == YES ) && ( pCustomer.bPut == YES ) )
		{
			[self unscheduleUpdate];
			[self schedule:@selector(_end:)];
			break;
		}
	}
}

/*
	@brief
*/
-(void)	_end:(ccTime)in_time
{
	[self setVisible:NO];
	[self unschedule:_cmd];
}

@end
