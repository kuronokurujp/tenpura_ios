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
#import "./../Object/Nabe.h"

#include "./../Data/DataGlobal.h"
#import "./../System/Sound/SoundManager.h"

//	非公開関数
@interface ActionCustomer (PrivateMedhot)

-(void)	_initPut:(id)sender;

//	食べる時のメッセージ
-(void)	_putEatMessage:(NSString*)in_messageFileName;

-(void)	_actPut:(BOOL)in_bSettingEat;
//	食べるアクション
-(void)	_actEat:(Tenpura*)in_pTenpura :(BOOL)in_bReset;

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
		mb_flash	= NO;

		mp_customer	= in_pCustomer;
		CGRect	rect	= [mp_customer getBoxRect];
		
		//	取得したスコアラベル
		{
			m_scoreLabelPos	= ccp(rect.size.width * 0.4f, rect.size.height * 0.5f - 16.f );
			mp_score	= [CCNodeRGBA node];
			[mp_score setPosition:m_scoreLabelPos];

			mp_scoreLabel	= [CCLabelBMFont labelWithString:@"1" fntFile:@"font_suuji_aka.fnt"];
			[mp_scoreLabel setAnchorPoint:ccp(0, 0.5f)];
			[mp_score addChild:mp_scoreLabel];
			
			CCSprite*	pIconSp	= [CCSprite spriteWithFile:@"icon_s.png"];
			[pIconSp setPosition:ccp(-20.f, 0)];
			[mp_score addChild:pIconSp];
			mp_scoreIcon	= pIconSp;

			[mp_score setVisible:NO];
			[mp_customer addChild:mp_score z:2.f];
		}
		
		//	取得した金額ラベル
		{
			m_moneyLabelPos	= ccp(rect.size.width * 0.4f, rect.size.height * 0.5f + 16.f );
			mp_money	= [CCNodeRGBA node];
			[mp_money setPosition:m_moneyLabelPos];

			mp_moneyLabel	= [CCLabelBMFont labelWithString:@"1" fntFile:@"font_suuji_kii.fnt"];
			[mp_moneyLabel setAnchorPoint:ccp(0, 0.5f)];
			[mp_money addChild:mp_moneyLabel];

			CCSprite*	pIconSp	= [CCSprite spriteWithFile:@"icon_c.png"];
			mp_moneyIcon	= pIconSp;
			[pIconSp setPosition:ccp(-20.f, 0)];
			[mp_money addChild:pIconSp];

			[mp_money setVisible:NO];
			[mp_customer addChild:mp_money z:2.f];
		}
	}

	return self;
}

/*
	@brief	出現アクション(食べる時)
*/
-(void)putEat
{
	[self _actPut:YES];
}

/*
	@brief	出現アクション(リザルト時)
*/
-(void)	putResult
{
	[self _actPut:NO];
	
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
	[mp_customer setAnim:eCUSTOMER_ANIM_NORMAL :false];

	[mp_customer stopAllActions];
	[mp_customer setScale:1.f];

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
	
	CCCallBlockN*	pEndFunc	= [CCCallBlockN actionWithBlock:^(CCNode* node){
		Customer*	pCustomer	= mp_customer;
		[pCustomer setVisible:NO];
	}];
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
	@breif	リザルト時の結果表示
*/
-(void)	putResultScore
{
	[self _createPutResultScoreAction:mp_customer.money];
	[self _createPutResultMoneyAction:mp_customer.score];
}

/*
	@breif	食べる大成功
*/
-(void)	eatVeryGood:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money
{
	[mp_customer stopAllActions];
	[mp_customer setAnim:eCUSTOMER_ANIM_HAPPY :true];
	[self _eat:in_pTenpura:in_score:in_money];

	[self _putEatMessage:[NSString stringWithUTF8String:gpa_spriteFileNameList[eSPRITE_FILE_CUS_MOJI01]]];

	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる失敗
*/
-(void)	eatBat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money
{
	[mp_customer stopAllActions];
	[mp_customer setAnim:eCUSTOMER_ANIM_BAD :true];
	[self _eat:in_pTenpura:in_score:in_money];

	[self _putEatMessage:[NSString stringWithUTF8String:gpa_spriteFileNameList[eSPRITE_FILE_CUS_MOJI02]]];

	[[SoundManager shared] playSe:@"eat"];
}

/*
	@breif	食べる大失敗
*/
-(void)	eatVeryBat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money;
{
	[mp_customer stopAllActions];
	[mp_customer setAnim:eCUSTOMER_ANIM_BAD :true];
	[self _eat:in_pTenpura:in_score:in_money];
	
	[[SoundManager shared] playSe:@"seki"];
}

/*
	@brief	怒りアクション
*/
-(void)	anger:(Tenpura*)in_pTenpura
{
	//	天ぷらを再配置する
	NETA_DATA_ST	data	= in_pTenpura.data;
	[mp_customer.nabe addTenpura:&data];

	[mp_customer stopAllActions];
	[mp_customer setAnim:eCUSTOMER_ANIM_BAD :true];
	
	m_getScore	= 0;
	m_getMoeny	= 0;

	[self _actEat:in_pTenpura :YES];

	[[SoundManager shared] playSe:@"seki"];
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
-(void)	_actPut:(BOOL)in_bSettingEat
{
	[mp_customer stopAllActions];
	[mp_customer setScale:1.f];

	[mp_customer setAnim:eCUSTOMER_ANIM_NORMAL :NO];

	SInt32	idx	= mp_customer.idx;

	CGPoint	endPos	= ccp( ga_initCustomerPos[idx][0], ga_initCustomerPos[idx][1] );

	CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:1.f position:endPos];
	CCEaseInOut*	pEaseMove	= [CCEaseInOut actionWithAction:pMove rate:4];
	CCCallBlockN*	pEndFunc	= [CCCallBlockN actionWithBlock:^(CCNode* node){
		Customer*	pCustomer	= mp_customer;
		pCustomer.bPut	= YES;

		if( in_bSettingEat == YES )
		{
			//	客が食べたいものを作成
			[pCustomer createEatList];
			[mp_customer setAnim:eCUSTOMER_ANIM_NORMAL :YES];
		}
	}];
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
	@brief
*/
-(CCAction*)	_createPutScoreAction:(SInt32)in_num
{
	[mp_scoreIcon stopAllActions];
	[mp_score stopAllActions];

	CCFadeIn*		pFaedIn		= [CCFadeIn actionWithDuration:0.05f];
	CCMoveBy*		pMove		= [CCMoveBy actionWithDuration:0.1f position:ccp(0, 10)];
	CCSpawn*		pSpawn		= [CCSpawn actionOne:pFaedIn two:pMove];
	
	CCFadeOut*		pFadeOut	= [CCFadeOut actionWithDuration:0.1f];
	CCCallBlock*	pEndFunc	= [CCCallBlock actionWithBlock:^(void){
		[mp_score stopAllActions];
		[mp_scoreIcon stopAllActions];
		[mp_score setVisible:NO];
	}];
	CCSequence*		pSeq		= [CCSequence actions:pSpawn,pFadeOut,pEndFunc,nil];

	//	アイコンのアクション設定
	{
		CCScaleTo*	pScale	= [CCScaleTo actionWithDuration:0.1f scaleX:-1 scaleY:1];
		CCScaleTo*	pScaleReturn	= [CCScaleTo actionWithDuration:0.1f scaleX:1 scaleY:1];
		
		CCSequence*	pIconSeq	= [CCSequence actionOne:pScale two:pScaleReturn];
		CCRepeatForever*	pRepeatFor	= [CCRepeatForever actionWithAction:pIconSeq];
		[mp_scoreIcon runAction:pRepeatFor];
	}

	[mp_scoreLabel setString:[NSString stringWithFormat:@"%ld", in_num]];
	[mp_score runAction:pSeq];
	[mp_score setVisible:YES];
	[mp_score setPosition:m_scoreLabelPos];

	return pSeq;
}

/*
	@brief
*/
-(CCAction*)	_createPutMoneyAction:(SInt32)in_num
{
	[mp_money stopAllActions];
	[mp_moneyIcon stopAllActions];

	CCSequence*		pSeq	= nil;
	//	全体のアクション設定
	{
		CCFadeIn*		pFaedIn		= [CCFadeIn actionWithDuration:0.05f];
		CCMoveBy*		pMove		= [CCMoveBy actionWithDuration:0.1f position:ccp(0, 10)];
		CCSpawn*		pSpawn		= [CCSpawn actionOne:pFaedIn two:pMove];

		CCFadeOut*		pFadeOut	= [CCFadeOut actionWithDuration:0.1f];
		CCCallBlock*	pEndFunc	= [CCCallBlock actionWithBlock:^(void){		
			[mp_money stopAllActions];
			[mp_moneyIcon stopAllActions];
			[mp_money setVisible:NO];
		}];
		
		pSeq		= [CCSequence actions:pSpawn,pFadeOut,pEndFunc,nil];
		
		[mp_money runAction:pSeq];
	}
	
	//	アイコンのアクション設定
	{
		CCScaleTo*	pScale	= [CCScaleTo actionWithDuration:0.1f scaleX:-1 scaleY:1];
		CCScaleTo*	pScaleReturn	= [CCScaleTo actionWithDuration:0.1f scaleX:1 scaleY:1];
		
		CCSequence*	pIconSeq	= [CCSequence actionOne:pScale two:pScaleReturn];
		CCRepeatForever*	pRepeatFor	= [CCRepeatForever actionWithAction:pIconSeq];
		[mp_moneyIcon runAction:pRepeatFor];
	}

	[mp_moneyLabel setString:[NSString stringWithFormat:@"%ld", in_num]];

	[mp_money setVisible:YES];
	[mp_money setPosition:m_moneyLabelPos];

	return pSeq;
}

/*
	@brief
*/
-(CCAction*)	_createPutResultScoreAction:(SInt32)in_num
{
	CCFadeIn*		pFadeIn		= [CCFadeIn actionWithDuration:0.1f];

	[mp_scoreIcon stopAllActions];
	[mp_scoreIcon setScale:1];

	[mp_score setPosition:m_scoreLabelPos];
	[mp_scoreLabel setString:[NSString stringWithFormat:@"%ld", in_num]];
	[mp_score runAction:pFadeIn];
	[mp_score setVisible:YES];

	return pFadeIn;
}

/*
	@brief
*/
-(CCAction*)	_createPutResultMoneyAction:(SInt32)in_num
{
	CCFadeIn*		pFaedIn		= [CCFadeIn actionWithDuration:0.1f];

	[mp_moneyIcon stopAllActions];
	[mp_moneyIcon setScale:1];
	[mp_money setPosition:m_moneyLabelPos];
	
	[mp_moneyLabel setString:[NSString stringWithFormat:@"%ld", in_num]];
	[mp_money runAction:pFaedIn];
	[mp_money setVisible:YES];

	return pFaedIn;
}

/*
	@brief	食べる処理
*/
-(void)	_eat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money
{
	NSAssert(in_pTenpura, @"客が食べる天ぷらがない");	
	
	//	天ぷらの食べるアクション
	[self _actEat:in_pTenpura :NO];

	m_getScore	= in_score;
	m_getMoeny	= in_money;

	//	食べた天ぷらアイコン消滅
	BOOL	bIconDel	= [mp_customer removeEatIcon:in_pTenpura.data.no];
	if( bIconDel == NO )
	{
		assert(0);
	}
}

/*
	@brief	食べるアクション
*/
-(void)	_actEat:(Tenpura*)in_pTenpura :(BOOL)in_bReset
{
	if(in_pTenpura == nil)
	{
		return;
	}

	{
		//	食べた時の表示削除
		CCNode*	pEatMessageSp	= [self getChildByTag:eACT_SP_TAG_EAT_MESSAGE];
		if( pEatMessageSp != nil )
		{
			[self removeChild:pEatMessageSp cleanup:YES];
		}
	}

	//	食べる演出を入れる
	[mp_customer setScale:1.f];
	[mp_customer setVisibleTenpuraIcon:NO];
	
	Float32	time	= 0.f;
	{
		Float32	scaleTime	= 0.1f * mp_customer.eatTimeRate;
		
		CCScaleTo*	pScaleUP	= [CCScaleTo actionWithDuration:scaleTime scale:1.2f];
		CCScaleTo*	pScaleDown	= [CCScaleTo actionWithDuration:scaleTime scale:1.0f];
		CCSequence*	pScaleSeq	= [CCSequence actions:pScaleUP, pScaleDown, nil];

		Float32	repeatCnt	= 3.f;
		CCRepeat*	pRepeat	= [CCRepeat actionWithAction:pScaleSeq times:repeatCnt];

		CCCallBlock*	pEndCall	= [CCCallBlock actionWithBlock:^(void){
			[self _createPutScoreAction:m_getScore];
			[self _createPutMoneyAction:m_getMoeny];

			[mp_customer setAnim:eCUSTOMER_ANIM_NORMAL :YES];
			[mp_customer setVisibleTenpuraIcon:YES];

			if( in_bReset == NO )
			{
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
			}

			m_getScore	= 0;
			m_getMoeny	= 0;
		}];
		CCSequence*	pSeq	= [CCSequence actions:pRepeat, pEndCall, nil];

		pSeq.tag	= eACT_TAG_EAT;
		[mp_customer.charSprite runAction:pSeq];
		
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
		[in_pTenpura removeFromParentAndCleanup:NO];
		[mp_customer addChild:in_pTenpura z:2.f tag:eACT_SP_TAG_TENPURA];
		[in_pTenpura setPosition:pos];
		[in_pTenpura eatAction:time];
	}
}

/*
	@brief
*/
-(void)	pauseSchedulerAndActions
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		[pNode pauseSchedulerAndActions];
	}
	
	[mp_moneyIcon pauseSchedulerAndActions];
	[mp_scoreIcon pauseSchedulerAndActions];

	[super pauseSchedulerAndActions];
}

/*
	@brief
*/
-(void)	resumeSchedulerAndActions
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		[pNode resumeSchedulerAndActions];
	}

	[mp_moneyIcon resumeSchedulerAndActions];
	[mp_scoreIcon resumeSchedulerAndActions];

	[super resumeSchedulerAndActions];
}

@end
