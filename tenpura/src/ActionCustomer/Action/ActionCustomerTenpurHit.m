//
//  ActionCustomerTenpurHit.m
//  tenpura
//
//  Created by y.uchida on 12/12/01.
//
//

#import "ActionCustomerTenpurHit.h"
#import "./../../Object/Customer.h"

@implementation ActionCustomerTenpurHit

/*
	@brief	初期化
*/
-(void)	initialize:(Customer *)in_pOnwer
{
	[super initialize:in_pOnwer];
	
	Customer*	pCustomer	= in_pOnwer;

	CCFadeOut*	pFadeOut	= [CCFadeOut actionWithDuration:0.1f];
	CCFadeIn*	pFadeIn		= [CCFadeIn actionWithDuration:0.1f];
	CCSequence*	pSequence	= [CCSequence actions:pFadeOut, pFadeIn, nil];
	CCRepeatForever*	pRepeat	= [CCRepeatForever actionWithAction:pSequence];
	
	[pCustomer.charSprite runAction:pRepeat];
	mp_action	= pRepeat;
}

/*
	@brief	終了
*/
-(void)	finalize
{
	Customer*	pCustomer	= mp_onwer;
	[pCustomer.charSprite stopAction:mp_action];
	[pCustomer.charSprite setOpacity:255];
	
	[super finalize];
}

@end
