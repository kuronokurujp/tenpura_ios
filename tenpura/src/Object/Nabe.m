//
//  Nabe.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Nabe.h"

#import "./../Data/DataTenpuraPosList.h"
#import "./../Data/DataOjamaNetaList.h"
#import "./../Data/DataGlobal.h"
#import "./../System/Anim/AnimManager.h"

@interface Nabe (PrivateMethod)

//	追加した天ぷら削除
-(void)	_cleanTenpura:(Tenpura*)in_pTenpura;

@end

@implementation Nabe

//	定数定義
enum
{
	eTEPURA_MAX	= 32,	//	天ぷら最大確保個数
};

//	鍋内に表示するZオーダー一覧
enum
{
	eZORDER_START_NORAMAL_TENPURA	= 4,
	eZORDER_OJAMA_TENPURA	= eZORDER_START_NORAMAL_TENPURA + 20,
	eZORDER_EXP,
	eZORDER_BIG_EXP,
};

@synthesize setFlyTimeRate	= m_setFlyTimeRate;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		AnimManager*	pAnimManager	= [AnimManager shared];

		mb_fever	= NO;
		m_flyTimeRate	= 1.f;
		m_setFlyTimeRate	= 1.f;
		mp_sp	= [CCSprite spriteWithFile:@"nabe0.png"];
		[mp_sp setAnchorPoint:ccp(0,0)];
		
		[self addChild:mp_sp];

		for( UInt32 i = 0; i < eTEPURA_MAX; ++i )
		{
			Tenpura*	pTenpura	= [Tenpura node];
			pTenpura.delegate	= self;
			[pTenpura setVisible:NO];
			[self addChild:pTenpura z:eZORDER_START_NORAMAL_TENPURA];
			
			//	爆弾エフェクトバッファで保持
			{
				CCNode*	pEff	= [pAnimManager createNode:[NSString stringWithUTF8String:ga_animDataList[eANIM_BOMG].pImageFileName] :NO];
				[pEff setVisible:NO];
				[self addChild:pEff];
			}
		}

		m_tenpuraZOrder	= eZORDER_START_NORAMAL_TENPURA;
		[self scheduleUpdate];
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	mp_sp	= nil;
	[super dealloc];
}

/*
	@brief	毎フレーム更新
*/
-(void)	update:(ccTime)delta
{
	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode		= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			pTenpura	= (Tenpura*)pNode;
			if( ([pTenpura isFly]) && (pTenpura.state == eTENPURA_STATE_RESTART) )
			{
				[pTenpura start];
				[pTenpura setEnableFever:mb_fever];

				//	再配置する
				UInt32	posIdx	= [pDataTenpuraPosList getIdxNoUse];
				[pDataTenpuraPosList setUseFlg:YES :posIdx];

				[pTenpura setPosOfIndex:posIdx];
			}
		}
	}
}

/*
	@brief	鍋画像設定(アイテム設定で鍋を変更することがある)
*/
-(void)	setNabeImageFileName:(NSString*)in_pNabeFileName
{
	if( in_pNabeFileName == nil )
	{
		return;
	}

	if( mp_sp != nil )
	{
		[self removeChild:mp_sp cleanup:YES];
	}
	
	mp_sp	= [CCSprite spriteWithFile:in_pNabeFileName];
	[mp_sp setAnchorPoint:ccp(0,0)];
		
	[self addChild:mp_sp];
}

/*
	@brief	天ぷら追加
*/
-(Tenpura*)	addTenpura:(const NETA_DATA_ST*)in_pData
{
	NSAssert(in_pData, @"");

	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode		= nil;
	
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			pTenpura	= (Tenpura*)pNode;
			if( ([pTenpura isUse] == NO) && (pTenpura.visible == NO) )
			{
				UInt32	posIdx	= [pDataTenpuraPosList getIdxNoUse];
				[pDataTenpuraPosList setUseFlg:YES :posIdx];

				[pTenpura setupToPosIndex:in_pData:posIdx:m_setFlyTimeRate];
				[pTenpura start];
				[pTenpura setRaiseTimeRate:m_flyTimeRate];
				[pTenpura setZOrder:m_tenpuraZOrder];
				[pTenpura setEnableFever:mb_fever];
				m_tenpuraZOrder += 1;
				
				return pTenpura;
			}
		}
	}

	return	nil;
}

/*
	@brief	配置した天ぷらをすべて外す
*/
-(void)	allCleanTenpura
{
	CCArray*	pRemoveTenpura	= [CCArray array];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode		= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] )
		{
			pTenpura	= (Tenpura*)pNode;
			[self _cleanTenpura:pTenpura];
		}
	}

	CCARRAY_FOREACH(pRemoveTenpura, pNode)
	{
		[self removeChild:pNode cleanup:YES];
	}
	
	m_tenpuraZOrder	= eZORDER_START_NORAMAL_TENPURA;
}

/*
	@brief	配置した天ぷらが爆発
*/
-(void)	onExpTenpura:(CCNode *)in_pTenpura
{
	//	爆発エフェクト
	if( [in_pTenpura isKindOfClass:[Tenpura class]] )
	{
		CCNode*	pNode	= nil;
		CCARRAY_FOREACH(_children, pNode)
		{
			if( ([pNode isKindOfClass:[AnimActionSprite class]] == YES) && (pNode.visible == NO) )
			{
				AnimActionSprite*	pEff	= (AnimActionSprite*)pNode;
				if( pEff != nil )
				{
					[pEff setVisible:YES];
					[pEff start];
					[pEff setPosition:in_pTenpura.position];
					[pEff setZOrder:eZORDER_EXP];
				
					return;
				}
			}
		}
	}
}

/*
	@brief	天ぷらをつける
*/
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;
{
	NSAssert(in_pTenpura, @"天ぷらがない");
	[self _cleanTenpura:(Tenpura*)in_pTenpura];
	[in_pTenpura removeFromParentAndCleanup:NO];
	[self addChild:in_pTenpura];
}

/*
	@brief	フィーバー設定
*/
-(void)	setEnableFever:(const BOOL)in_bFlg
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		Tenpura*	pTenpura	= nil;
		if( [pNode isKindOfClass:[Tenpura class]] )
		{
			pTenpura	= (Tenpura*)pNode;
			//	フィーバー設定をする
			[pTenpura setEnableFever:in_bFlg];
		}
	}
	
	mb_fever	= in_bFlg;
}

/*
	@brief	配置した天ぷらもポーズする
*/
-(void)	pauseSchedulerAndActions
{
	CCNode*		pNode		= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			[pNode pauseSchedulerAndActions];
		}
	}

	[super pauseSchedulerAndActions];
}

/*
	@brief	配置した天ぷらも再開
*/
-(void)	resumeSchedulerAndActions
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			[pNode resumeSchedulerAndActions];
		}
	}
	
	[super resumeSchedulerAndActions];
}

/*
	@brief
*/
-(CGRect)	boundingBox
{
	return mp_sp.boundingBox;
}

/*
	@brief	天ぷら削除
*/
-(void)	_cleanTenpura:(Tenpura*)in_pTenpura
{
	if( in_pTenpura == nil )
	{
		return;
	}

	if(in_pTenpura.visible == YES)
	{
		m_tenpuraZOrder -= 1;
	}

	[in_pTenpura end];
}

#if 0
#ifdef DEBUG
-(void)	draw
{
	[super draw];

	ccDrawColor4B(255, 0, 255, 255);
	CGPoint	p1,p2,p3,p4;
	
	CGRect	rect	= [self boundingBox];

	p1	= ccp(rect.origin.x + 2,rect.origin.y + 1);
	p2	= ccp(rect.origin.x + 2,rect.origin.y + rect.size.height - 2);
	p3	= ccp(rect.origin.x + rect.size.width - 2,rect.origin.y + rect.size.height - 2);
	p4	= ccp(rect.origin.x + rect.size.width - 2,rect.origin.y + 1);

	ccDrawLine(p1,p2);
	ccDrawLine(p2,p3);
	ccDrawLine(p3,p4);
	ccDrawLine(p4,p1);
	
	ccDrawColor4B(255, 255, 255, 255);
}

#endif
#endif

@end
