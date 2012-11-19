//
//  Customer.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Customer.h"
#import "Nabe.h"
#import "TenpuraIcon.h"

#import "../Action/ActionCustomer.h"
#import "../Data/DataNetaList.h"
#import "../Data/DataGlobal.h"
#import "../Data/DataSettingTenpura.h"

@implementation Customer

//	プロパティ定義
@synthesize charSprite	= mp_sp;
@synthesize bPut	= mb_put;
@synthesize act		= mp_act;
@synthesize idx		= m_idx;
@synthesize money	= m_money;
@synthesize score	= m_score;
@synthesize regeistTenpuraDelPermitName	= mp_registTenpuraDelPermitName;

//	食べれる最大数
enum
{
	eEAT_MAX	= 4,
};

enum
{
	eTAG_EAT_ICON	= 1,
};

//	天ぷらアイコン位置
static const CGPoint	s_eatIconPosArray[ eCUSTOMER_MAX ][ eEAT_MAX ]	=
{
	//	1番目
	{	{ 320, 240 }, { 360, 240 }, { 400, 240 }, { 440, 240 } },
	
	//	2番目
	{	{ 320, 160 }, { 360, 160 }, { 400, 160 }, { 440, 160 } },

	//	3番目
	{	{ 320, 80 }, { 360, 80 }, { 400, 80 }, { 440, 80 } },

	//	4番目
	{	{ 320, 0 }, { 360, 0 },	{ 400, 0 }, { 440, 0 } },
};

/*
	@brief	初期化
*/
-(id)	initToType:(TYPE_ENUM)in_type:(SInt32)in_idx:(Nabe*)in_pNabe:(CCArray*)in_pSettingTenpuraList
{
	if( self = [super init] )
	{
		mp_act	= nil;
		mp_sp	= nil;
		m_money	= 0;
		m_score	= 0;

		mp_nabe	= in_pNabe;
		mp_settingTenpuraList	= in_pSettingTenpuraList;
	
		mb_put	= NO;
		mb_tenpuraHit	= NO;
		m_idx	= in_idx;
		mp_registTenpuraDelPermitName	= [[NSString stringWithFormat:@"customer%ld_TenpuraDel", in_idx] retain];

		NSString*	pFileName	= @"";
		if( in_type == eTYPE_BASIC )
		{
			pFileName	= @"customer0.png";
		}

		mp_sp	= [CCSprite	node];
		[mp_sp initWithFile:pFileName];
		[mp_sp setAnchorPoint:ccp(0,0)];
		[self addChild:mp_sp z:0];

		mp_act	= [[[ActionCustomer alloc] initWithCusomer:self] autorelease];
		[mp_act setVisible:YES];
		[self addChild:mp_act z:2];
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	[mp_registTenpuraDelPermitName release];

	mp_sp	= nil;
	mp_act	= nil;
	mp_nabe	= nil;
	mp_registTenpuraDelPermitName	= nil;
	mp_settingTenpuraList	= nil;

	[super dealloc];
}

/*
	@brief	食べる天ぷら追加
*/
-(void)	createEatList
{
	DataNetaList*	pDataNetaList	= [DataNetaList shared];
	
	SInt32	putNum	= rand() % eEAT_MAX + 1;
	for( SInt32 i = 0; i < putNum; ++i )
	{
		SInt32	idx	= rand() % [mp_settingTenpuraList count];
		DataSettingTenpura*	pSettingTenpura	= [mp_settingTenpuraList objectAtIndex:idx];
		NSAssert(pSettingTenpura, @"");
		
		const NETA_DATA_ST*	pData	= [pDataNetaList getDataSearchId:pSettingTenpura.no];
		NSAssert( pData, @"ゲーム中に使用する天ぷらデータがない" );

		//	鍋に揚げる天ぷらを通知
		Tenpura*	pTenpura	= [mp_nabe addTenpura:*pData];
		if( pTenpura != nil )
		{
			//	退場時の通知依頼
			[pTenpura registDeletePermitObserver:mp_registTenpuraDelPermitName];

			NSString*	pFileName	= [NSString stringWithFormat:@"cust_%s.png", pData->fileName];

			//	アイコン作成
			TenpuraIcon*	pIcon	= [[[TenpuraIcon alloc] initWithFile:pFileName :(SInt32)pData->no] autorelease];

			//	相対位置を取得
			assert( m_idx < eCUSTOMER_MAX );

			[pIcon setPosition:ccpSub( s_eatIconPosArray[ m_idx ][ i ], self.position ) ];
			[pIcon setAnchorPoint:ccp(0,0)];
			[pIcon setVisible:YES];
		
			[self addChild:pIcon z:1 tag:eTAG_EAT_ICON];
		}
	}
}

/*
	@brief	食べられる天ぷらかチェック
	@return	食べられる YES
*/
-(BOOL)isEatTenpura:(SInt32)in_no
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			TenpuraIcon*	pIcon	= (TenpuraIcon*)pNode;
			if( pIcon.no == in_no )
			{
				return YES;
			}
		}
	}
	
	return NO;
}

/*
	@brief	食べる天ぷら個数
	@return	食べれる天ぷらの個数
*/
-(UInt32)getEatTenpura
{
	UInt32	cnt	= 0;
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			++cnt;
		}
	}
	
	return cnt;
}

/*
	@brief	オブジェクト矩形取得
*/
-(CGRect)	getBoxRect
{
	CGSize	texSize	= [mp_sp textureRect].size;
	CGRect	boxRect	= CGRectMake(self.position.x, self.position.y, texSize.width, texSize.height);
	
	return boxRect;
}

/*
	@brief	天ぷらアイコンすべて削除
*/
-(void)	removeAllEatIcon
{
	for( SInt32 i = 0; i < eEAT_MAX; ++i)
	{
		[self removeChildByTag:eTAG_EAT_ICON cleanup:YES];
	}
}

/*
	@brief	天ぷらアイコン削除
	@return	削除成功 : YES / 削除失敗 : NO
	@param	削除する天ぷらNO
*/
-(BOOL)	removeEatIcon:(SInt32)in_no
{
	TenpuraIcon*	pRemoveIcon	= nil;
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			TenpuraIcon*	pIcon	= (TenpuraIcon*)pNode;
			if( pIcon.no == in_no )
			{
				pRemoveIcon	= pIcon;
				break;
			}
		}
	}
	
	if( pRemoveIcon != nil )
	{
		[self removeChild:pRemoveIcon cleanup:YES];
	}

	return (pRemoveIcon != nil);
}

/*
	@brief	天ぷら食べる個数
*/
-(const SInt32)	getEatCnt
{
	SInt32	cnt	= 0;
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			++cnt;
		}
	}
	
	return cnt;
}

/*
	@brief	天ぷらヒットフラグ設定
*/
-(void)	setFlgTenpuraHit:(const BOOL)in_flg
{
	if( ( mb_tenpuraHit == NO ) && ( in_flg == YES ) )
	{
		[mp_act startFlash];
	}
	else if( ( mb_tenpuraHit == YES ) && ( in_flg == NO ) )
	{
		//	フラッシュ終了
		[mp_act endFlash];
	}
	
	mb_tenpuraHit	= in_flg;
}

@end
