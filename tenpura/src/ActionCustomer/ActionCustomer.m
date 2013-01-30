//
//  ActionCustomer.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import "ActionCustomer.h"

#import "./../Object/Customer.h"
#import "./../Object/TenpuraIcon.h"

#include "./../Data/DataGlobal.h"
#import "./../System/Sound/SoundManager.h"

//	アクション一覧
enum ACTION_LIST_ENUM
{
	eACT_TAG_FLAH	= 0,
};

//	非公開関数
@interface ActionCustomer (PrivateMedhot)

-(void)_initPut:(id)sender;
-(void)_endPut:(id)sender;

-(void)_endExit:(id)sender;

-(void)_endPutNumber:(id)sender;

//	スコアアクション作成
-(CCAction*)	_createPutScoreAction:(SInt32)in_num;
-(CCAction*)	_createPutMoneyAction:(SInt32)in_num;

-(CCAction*)	_createPutResultScoreAction:(SInt32)in_num;
-(CCAction*)	_createPutResultMoneyAction:(SInt32)in_num;

//	食べる処理
-(void)	_eat:(const SInt32)in_no:(SInt32)in_score:(SInt32)in_money;

@end

@implementation ActionCustomer

/*
	@brief	初期化
*/
-(id)initWithCusomer:(Customer*)in_pCustomer
{
	if( self = [super init] )
	{
		mb_SettingEat	= NO;
		mb_flash	= NO;

		mp_customer	= in_pCustomer;
		CGRect	rect	= [mp_customer getBoxRect];
		
		//	取得したスコアラベル
		{
			mp_scoreLabel	= [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:32];
			[mp_scoreLabel setVisible:NO];
			[mp_scoreLabel setPosition:ccp(rect.size.width * 0.5f, rect.size.height * 0.5f - 16.f )];
			[mp_customer addChild:mp_scoreLabel z:2.f];
		}
		
		//	取得した金額ラベル
		{
			mp_moneyLabel	= [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:32];
			[mp_moneyLabel setVisible:NO];
			[mp_moneyLabel setPosition:ccp(rect.size.width * 0.5f, rect.size.height * 0.5f + 16.f )];
			[mp_customer addChild:mp_moneyLabel z:2.f];
		}
	}

	return self;
}

/*
	@brief	出現アクション
*/
-(void)put:(BOOL)in_bSettingEat
{
	[mp_customer stopAllActions];

	mb_SettingEat	= in_bSettingEat;

	SInt32	idx	= mp_customer.idx;

	CGPoint	endPos	= ccp( ga_initCustomerPos[idx][0], ga_initCustomerPos[idx][1] );

	CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.f position:endPos];
	CCEaseInOut*	pEaseMove	= [CCEaseInOut actionWithAction:pMove rate:4];
	
	CCCallFuncN*	pEndFunc	= [CCCallFuncN actionWithTarget:self selector:@selector(_endPut:)];
	CCSequence*		pSeq		= [CCSequence actions:pEaseMove, pEndFunc, nil];
	
	[self _initPut:nil];
	[mp_customer runAction:pSeq];
	
	[mp_customer setVisible:YES];
	[mp_customer.charSprite setOpacity:255];
}

/*
	@brief	退場
*/
-(void)	exit
{
	[mp_customer stopAllActions];

	mp_customer.bPut	= NO;

	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	CGPoint	pos	= ccp( winSize.width, mp_customer.position.y );

	CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.f position:pos];
	CCEaseInOut*	pEaseMove	= [CCEaseInOut actionWithAction:pMove rate:4];
	
	CCCallFuncN*	pEndFunc	= [CCCallFuncN actionWithTarget:self selector:@selector(_endExit:)];
	CCSequence*		pSeq		= [CCSequence actions:pEaseMove, pEndFunc, nil];
	
	[mp_customer runAction:pSeq];
	[mp_customer.charSprite setOpacity:255];
}

/*
	@brief	点滅アクション
*/
-(void)	loopFlash
{
	if( mb_flash == NO )
	{
		mb_flash	= YES;
		Customer*	pCustomer	= mp_customer;

		CCFadeOut*	pFadeOut	= [CCFadeOut actionWithDuration:0.1f];
		CCFadeIn*	pFadeIn		= [CCFadeIn actionWithDuration:0.1f];
		CCSequence*	pSequence	= [CCSequence actions:pFadeOut, pFadeIn, nil];
		CCRepeatForever*	pRepeat	= [CCRepeatForever actionWithAction:pSequence];

		pRepeat.tag	= eACT_TAG_FLAH;
		[pCustomer.charSprite runAction:pRepeat];
		
		[[SoundManager shared] playSe:@"tenpuraHitCustomer"];
	}
}

/*
	@breif
*/
-(void)endFlash
{
	if( mb_flash == YES )
	{
		mb_flash	= NO;
		Customer*	pCustomer	= mp_customer;
		[pCustomer.charSprite stopActionByTag:eACT_TAG_FLAH];
		[pCustomer.charSprite setOpacity:255];
	}
}

/*
	@breif
*/
-(void)putResultScore
{
	[self _createPutResultScoreAction:mp_customer.money];
	[self _createPutResultMoneyAction:mp_customer.score];
}

/*
	@breif	食べる成功
*/
-(void)eatGood:(const SInt32)in_no:(SInt32)in_score:(SInt32)in_money
{
	[mp_customer stopAllActions];

	[self _eat:in_no:in_score:in_money];
	
	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる大成功
*/
-(void)eatVeryGood:(const SInt32)in_no:(SInt32)in_score:(SInt32)in_money
{
	[mp_customer stopAllActions];

	[self _eat:in_no:in_score:in_money];

	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる失敗
*/
-(void)eatBat:(const SInt32)in_no:(SInt32)in_score:(SInt32)in_money
{
	[mp_customer stopAllActions];

	[self _eat:in_no:in_score:in_money];
	
	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる大失敗
*/
-(void)eatVeryBat:(const SInt32)in_no:(SInt32)in_score:(SInt32)in_money;
{
	[mp_customer stopAllActions];

	[self _eat:in_no:in_score:in_money];
	
	[[SoundManager shared] playSe:@"seki"];
}

/*
	@brief	怒りアクション
*/
-(void)anger
{
	[mp_customer stopAllActions];
	[[SoundManager shared] playSe:@"seki"];
}

/*
	@breif	出現アクション初期
*/
-(void)_initPut:(id)sender
{
	mp_customer.bPut	= NO;
}

/*
	@brief	出現アクション終了
*/
-(void)_endPut:(id)sender
{
	Customer*	pCustomer	= mp_customer;
	pCustomer.bPut	= YES;

	if( mb_SettingEat == YES )
	{
		//	客が食べたいものを作成
		[pCustomer createEatList];
	}
	
	mb_SettingEat	= NO;
}

/*
	@brief
*/
-(void)_endExit:(id)sender
{
	Customer*	pCustomer	= mp_customer;
	[pCustomer setVisible:NO];
}

/*
	@brief
*/
-(void)_endPutNumber:(id)sender
{
	[sender setVisible:NO];
}

/*
	@brief
*/
-(CCAction*)	_createPutScoreAction:(SInt32)in_num
{
	CCFadeIn*		pFaedIn		= [CCFadeIn actionWithDuration:0.1f];
	CCFadeOut*		pFadeOut	= [CCFadeOut actionWithDuration:0.1f];
	CCCallFuncN*	pEndFunc	= [CCCallFuncN actionWithTarget:self selector:@selector(_endPutNumber:)];
	CCSequence*		pSeq		= [CCSequence actions:pFaedIn,pFadeOut,pEndFunc,nil];

	[mp_scoreLabel setString:[NSString stringWithFormat:@"%ld", in_num]];
	[mp_scoreLabel runAction:pSeq];
	[mp_scoreLabel setVisible:YES];

	return pSeq;
}

/*
	@brief
*/
-(CCAction*)	_createPutMoneyAction:(SInt32)in_num
{
	CCFadeIn*		pFaedIn		= [CCFadeIn actionWithDuration:0.1f];
	CCFadeOut*		pFadeOut	= [CCFadeOut actionWithDuration:0.1f];
	CCCallFuncN*	pEndFunc	= [CCCallFuncN actionWithTarget:self selector:@selector(_endPutNumber:)];
	CCSequence*		pSeq		= [CCSequence actions:pFaedIn,pFadeOut,pEndFunc,nil];

	[mp_moneyLabel setString:[NSString stringWithFormat:@"%ld", in_num]];
	[mp_moneyLabel runAction:pSeq];
	[mp_moneyLabel setVisible:YES];

	return pSeq;
}

/*
	@brief
*/
-(CCAction*)	_createPutResultScoreAction:(SInt32)in_num
{
	CCFadeIn*		pFadeIn		= [CCFadeIn actionWithDuration:0.1f];

	[mp_scoreLabel setString:[NSString stringWithFormat:@"%ld", in_num]];
	[mp_scoreLabel runAction:pFadeIn];
	[mp_scoreLabel setVisible:YES];

	return pFadeIn;
}

/*
	@brief
*/
-(CCAction*)	_createPutResultMoneyAction:(SInt32)in_num
{
	CCFadeIn*		pFaedIn		= [CCFadeIn actionWithDuration:0.1f];

	[mp_moneyLabel setString:[NSString stringWithFormat:@"%ld", in_num]];
	[mp_moneyLabel runAction:pFaedIn];
	[mp_moneyLabel setVisible:YES];

	return pFaedIn;
}

/*
	@brief	食べる処理
*/
-(void)	_eat:(const SInt32)in_no:(SInt32)in_score:(SInt32)in_money
{
	//	食べた天ぷらアイコン消滅
	assert( [mp_customer removeEatIcon:in_no] == YES);
	
	[self _createPutScoreAction:in_score];
	[self _createPutMoneyAction:in_money];
	
	//	食べる天ぷらがないと退場
	if([mp_customer getEatTenpura] <= 0)
	{
		[self exit];
	}
}

@end
