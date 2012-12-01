//
//  ActionCustomerPut.m
//  tenpura
//
//  Created by y.uchida on 12/12/01.
//
//

#import "ActionCustomerPut.h"
#import "./../../Object/Customer.h"
#include "./../../Data/DataGlobal.h"

@implementation ActionCustomerPut

/*
	@brief	初期化
*/
-(void)	initialize:(Customer*)in_pOnwer
{
	[super initialize:in_pOnwer];
	
	SInt32	idx	= in_pOnwer.idx;

	CGPoint	endPos	= ccp( ga_initCustomerPos[idx][0], ga_initCustomerPos[idx][1] );

	CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.f position:endPos];
	CCEaseInOut*	pEaseMove	= [CCEaseInOut actionWithAction:pMove rate:4];
	
	CCSequence*		pSeq		= [CCSequence actions:pEaseMove, nil];
	
	[in_pOnwer runAction:pSeq];
	
	[in_pOnwer setVisible:YES];
	[in_pOnwer.charSprite setOpacity:255];
	
	in_pOnwer.bPut	= NO;
	[in_pOnwer setFlgTenpuraHit:NO];
}

/*
	@brief	終了処理
*/
-(void)	finalize
{
	mp_onwer.bPut	= YES;

	[super finalize];
}

@end
