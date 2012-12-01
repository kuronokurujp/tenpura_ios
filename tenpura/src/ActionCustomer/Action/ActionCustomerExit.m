//
//  ActionCustomerExit.m
//  tenpura
//
//  Created by y.uchida on 12/12/01.
//
//

#import "ActionCustomerExit.h"
#import "./../../Object/Customer.h"

@implementation ActionCustomerExit

/*
	@brief	初期化
*/
-(void)	initialize:(Customer *)in_pOnwer
{
	[super initialize:in_pOnwer];

	in_pOnwer.bPut	= NO;
	// 通知を作成する
	NSNotification *n = [NSNotification notificationWithName:in_pOnwer.regeistTenpuraDelPermitName object:in_pOnwer];
	if( n != nil )
	{
		// 通知実行！
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}

	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	CGPoint	pos	= ccp( winSize.width, in_pOnwer.position.y );

	CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.f position:pos];
	CCEaseInOut*	pEaseMove	= [CCEaseInOut actionWithAction:pMove rate:4];
	
	CCSequence*		pSeq		= [CCSequence actions:pEaseMove, nil];
	
	[in_pOnwer runAction:pSeq];
	[in_pOnwer.charSprite setOpacity:255];
}

/*
	@brief	終了
*/
-(void)	finalize
{
	[mp_onwer setVisible:NO];

	[super finalize];
}

@end
