//
//  Nabe.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Nabe.h"
#import "Tenpura.h"

#import "./../Data/DataTenpuraPosList.h"

@implementation Nabe

//	定数定義
enum
{
	eTEPURA_MAX	= 32,	//	天ぷら最大確保個数
};

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_sp	= [CCSprite node];
		[mp_sp initWithFile:@"nabe0.png"];
		[mp_sp setAnchorPoint:ccp(0,0)];
		
		[self addChild:mp_sp];
		
		for( UInt32 i = 0; i < eTEPURA_MAX; ++i )
		{
			Tenpura*	pTenpura	= [Tenpura node];
			[pTenpura setVisible:NO];
			[self addChild:pTenpura z:10.f];
		}
		
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
	Tenpura*	pTenpura	= nil;
	CCNode*		pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			pTenpura	= (Tenpura*)pNode;
			if( pTenpura.state == eTENPURA_STATE_DEL )
			{
				[self subTenpura:pTenpura];
			}
		}
	}
}

/*
	@brief	天ぷら追加
*/
-(Tenpura*)	addTenpura:(NETA_DATA_ST)in_data
{
	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode	= nil;
	SInt32	idx	= 0;
	
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			if( pNode.visible == NO )
			{
				//	表示天ぷらのセットアップ
				pTenpura	= (Tenpura*)pNode;
				
				UInt32	posIdx	= [pDataTenpuraPosList getIdxNoUse];
				[pDataTenpuraPosList setUseFlg:YES :posIdx];
				TENPURA_POS_ST	tenpuraPosData	= [pDataTenpuraPosList getData:posIdx];

				[pTenpura setup:in_data:ccp(tenpuraPosData.x, tenpuraPosData.y)];
				[pTenpura startRaise];
				
				return pTenpura;
			}
			
			++idx;
		}
	}

	return	nil;
}

/*
	@brief	天ぷら削除
*/
-(void)	subTenpura:(Tenpura*)in_pTenpura
{
	if( ( in_pTenpura == nil ) || ( in_pTenpura.visible == NO ) )
	{
		return;
	}

	[in_pTenpura end];
}

/*
	@breif
*/
-(void)	setVisibleTenpura:(BOOL)in_bFlg
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			[pNode setVisible:NO];
		}
	}
}

/*
	@brief
*/
-(CGRect)	boundingBox
{
	return mp_sp.boundingBox;
}

@end
