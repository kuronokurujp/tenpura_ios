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

//	非公開関数
@interface ActionCustomer (PrivateMedhot)

//	食べる時のメッセージ
-(void)	_putEatMessage:(NSString*)in_messageFileName;

-(void)	_actPut;
-(void)	_initPut:(id)sender;
-(void)	_endPut:(id)sender;

-(void)	_endExit:(id)sender;

-(void)	_endEat;

-(void)	_endPutNumber:(id)sender;

//	スコアアクション作成
-(CCAction*)	_createPutScoreAction:(SInt32)in_num;
-(CCAction*)	_createPutMoneyAction:(SInt32)in_num;

-(CCAction*)	_createPutResultScoreAction:(SInt32)in_num;
-(CCAction*)	_createPutResultMoneyAction:(SInt32)in_num;

//	食べる処理
-(void)	_eat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money;

@end

@implementation ActionCustomer

//	アクション一覧
enum ACTION_LIST_ENUM
{
	eACT_TAG_FLAH	= 0,
	eACT_TAG_EAT,
	eACT_TAG_PUT,
};

enum ACTION_SP_ENUM
{
	eACT_SP_TAG_EAT_MESSAGE	= 0,
	eACT_SP_TAG_TENPURA,
};

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
	@brief	出現アクション(食べる時)
*/
-(void)putEat
{
	mb_SettingEat	= YES;
	[self _actPut];
}

/*
	@brief	出現アクション(リザルト時)
*/
-(void)	putResult
{
	mb_SettingEat	= NO;
	[self _actPut];
	
	//	食べた天ぷらがあれば後始末
	CCNode*	pTenpuraNode	= [mp_customer getChildByTag:eACT_SP_TAG_TENPURA];
	if( pTenpuraNode && [pTenpuraNode isKindOfClass:[Tenpura class]] )
	{
		Tenpura*	pTenpura	= (Tenpura*)pTenpuraNode;
		[pTenpura end];
	}
	
	//	食べた時の表示削除
	CCNode*	pEatMessageSp	= [self getChildByTag:eACT_SP_TAG_EAT_MESSAGE];
	if( pEatMessageSp != nil )
	{
		[self removeChild:pEatMessageSp cleanup:YES];
	}
}

/*
	@brief	出現アクション中
*/
-(BOOL)	isRunPutAct
{
	return ([mp_customer getActionByTag:eACT_TAG_PUT] != nil);
}

/*
	@brief	退場
*/
-(void)	exit
{
	[mp_customer stopAllActions];

	CCNode*	pEatMessageSp	= [self getChildByTag:eACT_SP_TAG_EAT_MESSAGE];
	if( pEatMessageSp != nil )
	{
		[self removeChild:pEatMessageSp cleanup:YES];
	}

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
-(void)	endFlash
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
-(void)	putResultScore
{
	[self _createPutResultScoreAction:mp_customer.money];
	[self _createPutResultMoneyAction:mp_customer.score];
}

/*
	@breif	食べる成功
*/
-(void)	eatGood:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money
{
	[self _eat:in_pTenpura:in_score:in_money];
	
	[self _putEatMessage:[NSString stringWithUTF8String:gpa_spriteFileNameList[eSPRITE_FILE_CUS_MOJI00]]];

	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる大成功
*/
-(void)	eatVeryGood:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money
{
	[self _eat:in_pTenpura:in_score:in_money];

	[self _putEatMessage:[NSString stringWithUTF8String:gpa_spriteFileNameList[eSPRITE_FILE_CUS_MOJI01]]];

	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる失敗
*/
-(void)	eatBat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money
{
	[self _eat:in_pTenpura:in_score:in_money];

	[self _putEatMessage:[NSString stringWithUTF8String:gpa_spriteFileNameList[eSPRITE_FILE_CUS_MOJI02]]];

	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる大失敗
*/
-(void)	eatVeryBat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money;
{
	[self _eat:in_pTenpura:in_score:in_money];
	
	[[SoundManager shared] playSe:@"seki"];
}

/*
	@brief	怒りアクション
*/
-(void)	anger
{
	[mp_customer stopAllActions];
	[[SoundManager shared] playSe:@"seki"];
}

/*
	@brief	食べている途中か
*/
-(BOOL)	isEatting
{
	if( [mp_customer getActionByTag:eACT_TAG_EAT] != nil  )
	{
		return YES;
	}
	
	return NO;
}

/*
	@brief	食べる時のメッセージ
*/
-(void)	_putEatMessage:(NSString*)in_messageFileName
{
	CCSprite*	pEatMesssageSp	= [CCSprite spriteWithFile:in_messageFileName];
	CGRect	rect	= [mp_customer.charSprite textureRect];
	[pEatMesssageSp setPosition:ccp(rect.size.width * 0.3f, rect.size.height * 0.6f)];
	
	[self addChild:pEatMesssageSp z:0 tag:eACT_SP_TAG_EAT_MESSAGE];
}

/*
	@brief	出現アクション設定
*/
-(void)	_actPut
{
	[mp_customer stopAllActions];
	
	SInt32	idx	= mp_customer.idx;

	CGPoint	endPos	= ccp( ga_initCustomerPos[idx][0], ga_initCustomerPos[idx][1] );

	CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.f position:endPos];
	CCEaseInOut*	pEaseMove	= [CCEaseInOut actionWithAction:pMove rate:4];
	
	CCCallFuncN*	pEndFunc	= [CCCallFuncN actionWithTarget:self selector:@selector(_endPut:)];
	CCSequence*		pSeq		= [CCSequence actions:pEaseMove, pEndFunc, nil];
	
	[self _initPut:nil];
	pSeq.tag	= eACT_TAG_PUT;
	[mp_customer runAction:pSeq];

	[mp_customer setVisible:YES];
	[mp_customer.charSprite setOpacity:255];
}

/*
	@breif	出現アクション初期
*/
-(void)	_initPut:(id)sender
{
	mp_customer.bPut	= NO;
}

/*
	@brief	出現アクション終了
*/
-(void)	_endPut:(id)sender
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
-(void)	_endExit:(id)sender
{
	Customer*	pCustomer	= mp_customer;
	[pCustomer setVisible:NO];
}

/*
	@brief
*/
-(void)	_endPutNumber:(id)sender
{
	[sender setVisible:NO];
}

/*
	@brief	食べるの終了
*/
-(void)	_endEat
{
	[self _createPutScoreAction:m_getScore];
	[self _createPutMoneyAction:m_getMoeny];

	//	食べる天ぷらがないと退場
	if([mp_customer getEatTenpura] <= 0)
	{
		[self exit];
	}
	
	//	食べた時の表示削除
	CCNode*	pEatMessageSp	= [self getChildByTag:eACT_SP_TAG_EAT_MESSAGE];
	if( pEatMessageSp != nil )
	{
		[self removeChild:pEatMessageSp cleanup:YES];
	}

	m_getScore	= 0;
	m_getMoeny	= 0;
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
-(void)	_eat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money
{
	NSAssert(in_pTenpura, @"客が食べる天ぷらがない");	
	[mp_customer stopAllActions];

	//	食べる演出を入れる
	[mp_customer setScale:1.f];
	
	Float32	time	= 0.f;
	{
		Float32	scaleTime	= 0.1f * mp_customer.eatTimeRate;
		
		CCScaleTo*	pScaleUP	= [CCScaleTo actionWithDuration:scaleTime scale:1.2f];
		CCScaleTo*	pScaleDown	= [CCScaleTo actionWithDuration:scaleTime scale:1.0f];
		CCSequence*	pScaleSeq	= [CCSequence actions:pScaleUP, pScaleDown, nil];

		Float32	repeatCnt	= 3.f;
		CCRepeat*	pRepeat	= [CCRepeat actionWithAction:pScaleSeq times:repeatCnt];

		CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(_endEat)];
		CCSequence*	pSeq	= [CCSequence actions:pRepeat, pEndCall, nil];
	
		pSeq.tag	= eACT_TAG_EAT;
		[mp_customer runAction:pSeq];
		
		time	= scaleTime * 2.f;
		time	*= repeatCnt;
	}

	//	天ぷらの消滅アクション
	{
		CGPoint	anthorPos	= mp_customer.anchorPoint;
		if( anthorPos.x != 0.5f )
		{
			anthorPos.x	= 0.5f;
		}
		if( anthorPos.y != 0.5f )
		{
			anthorPos.y	= 0.5f;
		}
		CGRect	rect	= mp_customer.charSprite.textureRect;
		
		CGPoint	pos	= ccp(rect.size.width * anthorPos.x, rect.size.height * anthorPos.y);
		[in_pTenpura setPosition:pos];
		[in_pTenpura eatAction:time];
		[in_pTenpura removeFromParentAndCleanup:NO];
		[mp_customer addChild:in_pTenpura z:2.f tag:eACT_SP_TAG_TENPURA];
	}

	m_getScore	= in_score;
	m_getMoeny	= in_money;

	//	食べた天ぷらアイコン消滅
	BOOL	bIconDel	= [mp_customer removeEatIcon:in_pTenpura.data.no];
	if( bIconDel == NO )
	{
		assert(0);
	}
}

@end
