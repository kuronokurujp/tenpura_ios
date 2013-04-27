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

#import	"./../System/Anim/AnimManager.h"
#import "./../ActionCustomer/ActionCustomer.h"
#import "./../Data/DataNetaList.h"
#import "./../Data/DataGlobal.h"
#import "./../Data/DataSettingNetaPack.h"

@implementation Customer

//	プロパティ定義
@synthesize charSprite	= mp_sp;
@synthesize bPut	= mb_put;
@synthesize act		= mp_act;
@synthesize idx		= m_idx;
@synthesize money	= m_money;
@synthesize score	= m_score;
@synthesize eatTimeRate	= m_eatTimeRate;

//	食べれる最大数
enum
{
	eEAT_MAX	= 4,
};

enum
{
	eTAG_EAT_ICON	= 1,
	eTAG_ANIM	= eTAG_EAT_ICON + 5,
};

static const SInt32	s_animDataIdx[3][eCUSTOMER_ANIM_MAX]	=
{
	{
		eANIM_CHAR_NORMAL01,
		eANIM_CHAR_HAPPY01,
		eANIM_CHAR_BAD01,
	},
	
	{
		eANIM_CHAR_NORMAL02,
		eANIM_CHAR_HAPPY02,
		eANIM_CHAR_BAD02,
	},

	{
		eANIM_CHAR_NORMAL03,
		eANIM_CHAR_HAPPY03,
		eANIM_CHAR_BAD03,
	},
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
-(id)	initToType:(SInt32)in_idx :(Nabe*)in_pNabe :(CCArray*)in_pSettingTenpuraList :(Float32)in_eatTimeRate
{
	if( self = [super init] )
	{
		DataCustomerList*	pDataCustomerList	= [DataCustomerList shared];
		NSAssert(pDataCustomerList, @"客のデータがないです");
		mp_customerData	= [pDataCustomerList getDataSearchId:0];
		
		mp_act	= nil;
		mp_sp	= nil;
		m_money	= 0;
		m_score	= 0;
		m_orgEatTimeRate	= in_eatTimeRate;
		m_eatTimeRate	= m_orgEatTimeRate * mp_customerData->eatTime;

		mp_nabe	= in_pNabe;
		mp_settingTenpuraList	= in_pSettingTenpuraList;
	
		mb_put	= NO;
		m_idx	= in_idx;

		m_type	= eTYPE_MAN;
		{
			AnimManager*	pAnimManager	= [AnimManager shared];
			for( SInt32 i = 0; i < eTYPE_MAX; ++i )
			{
				for( SInt32 j = 0; j < eCUSTOMER_ANIM_MAX; ++j )
				{
					mp_charAnim[i][j]	= [pAnimManager createNode:[NSString stringWithUTF8String:ga_animDataList[s_animDataIdx[i][j]].pImageFileName] :YES];
					[mp_charAnim[i][j] retain];
					
					AnimActionSprite*	pAnimAction	= (AnimActionSprite*)mp_charAnim[i][j];
					[pAnimAction setAnchorPoint:ccp(0,0)];
					[pAnimAction.sp setAnchorPoint:ccp(0,0)];
				}
			}
		}
		
		[self setAnim:eCUSTOMER_ANIM_NORMAL :false];

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
	for( SInt32 i = 0; i < eTYPE_MAX; ++i )
	{
		for( SInt32 j = 0; j < eCUSTOMER_ANIM_MAX; ++j )
		{
			[mp_charAnim[i][j] release];
		}
	}

	mp_sp	= nil;
	mp_act	= nil;
	mp_nabe	= nil;
	mp_settingTenpuraList	= nil;

	[super dealloc];
}

/*
	@brief	タイプ設定
*/
//	タイプ設定
-(void)	setType:(TYPE_ENUM)in_type
{
	m_type	= in_type;
	DataCustomerList*	pDataCustomerList	= [DataCustomerList shared];
	NSAssert(pDataCustomerList, @"客のデータがないです");

	mp_customerData	= [pDataCustomerList getDataSearchId:m_type];
	m_eatTimeRate	= m_orgEatTimeRate * mp_customerData->eatTime;
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

		NSNumber*	pNumber	= [mp_settingTenpuraList objectAtIndex:idx];
		NSAssert(pNumber, @"");
		
		const NETA_DATA_ST*	pData	= [pDataNetaList getDataSearchId:[pNumber integerValue]];
		NSAssert( pData, @"ゲーム中に使用する天ぷらデータがない" );

		//	鍋に揚げる天ぷらを通知
		Tenpura*	pTenpura	= [mp_nabe addTenpura:pData];
		if( pTenpura != nil )
		{
			//	アイコン作成
			TenpuraIcon*	pIcon	= [[[TenpuraIcon alloc] initWithSetup:pData] autorelease];

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
	@brief	リザルトセッティング
*/
-(void)	settingResult
{
	//	強制登場
	[mp_act putResult];
	
	//	天ぷらアイコンを消す
	[self removeAllEatIcon];
}

/*
	@brief	食べられる天ぷらかチェック
	@return	食べられる YES
*/
-(BOOL)isEatTenpura:(SInt32)in_no
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
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
	CCARRAY_FOREACH(_children, pNode)
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
	@brief	天ぷらアイコンの表示／非表示
*/
-(void)	setVisibleTenpuraIcon:(BOOL)in_flg
{
	CCNode*	pNode	= nil;

	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			pNode.visible	= in_flg;
		}
	}
}

/*
	@brief	天ぷらアイコンすべて削除
*/
-(void)	removeAllEatIcon
{
	CCArray*	pRemoveNodeArray	= [CCArray array];
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			[pRemoveNodeArray addObject:pNode];
		}
	}
	
	//	ここで一気に消す
	CCARRAY_FOREACH(pRemoveNodeArray, pNode)
	{
		[self removeChild:pNode cleanup:YES];
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
	CCARRAY_FOREACH(_children, pNode)
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
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			++cnt;
		}
	}
	
	return cnt;
}

/*
*/
-(void)	setAnim:(const CUSTOMER_ANIM_ENUM)in_anim :(const bool)in_bAnim
{
	CCNode*	pAnim	= mp_charAnim[m_type][in_anim];
	if( [pAnim isKindOfClass:[AnimActionSprite class]] )
	{
		AnimActionSprite*	pAnimAction	= (AnimActionSprite*)pAnim;
		if( in_bAnim == false )
		{
			[pAnimAction frame:1];
		}
		else
		{
			[pAnimAction startLoop:YES];
		}
		
		[self removeChildByTag:eTAG_ANIM cleanup:NO];
		[self addChild:pAnimAction z:0 tag:eTAG_ANIM];
		mp_sp	= pAnimAction.sp;
	}
}

/*
	@brief
*/
-(void) stopAllActions
{
	[mp_sp stopAllActions];
	[mp_act endFlash];
	[super stopAllActions];
	
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
	
	[super resumeSchedulerAndActions];
}

/*
	@brief	金額設定
*/
-(void)	_addMoney:(SInt32)money
{
	m_money	+= (money * mp_customerData->moneyRate);
	if( m_money < 0 )
	{
		m_money	= 0;
	}
}

/*
	@brief	スコア設定
*/
-(void)	_addScore:(SInt32)score
{
	m_score	+= (score * mp_customerData->scoreRate);
	if( m_score < 0 )
	{
		m_score	= 0;
	}
}

@end
