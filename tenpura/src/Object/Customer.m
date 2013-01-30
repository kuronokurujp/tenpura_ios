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

#import "./../ActionCustomer/ActionCustomer.h"
#import "./../Data/DataNetaList.h"
#import "./../Data/DataGlobal.h"
#import "./../Data/DataSettingTenpura.h"

@implementation Customer

//	プロパティ定義
@synthesize charSprite	= mp_sp;
@synthesize bPut	= mb_put;
@synthesize act		= mp_act;
@synthesize idx		= m_idx;
@synthesize money	= m_money;
@synthesize score	= m_score;

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
		m_idx	= in_idx;

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
	mp_sp	= nil;
	mp_act	= nil;
	mp_nabe	= nil;
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
		Tenpura*	pTenpura	= [mp_nabe addTenpura:*pData:pSettingTenpura.raiseSpeedRate];
		if( pTenpura != nil )
		{
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
	CCArray*	pRemoveNodeArray	= [CCArray array];
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
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
	@brief
*/
-(void) stopAllActions
{
	[mp_act endFlash];
	[super stopAllActions];
	
}

/*
	@brief
*/
-(void)	pauseSchedulerAndActions
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
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
	CCARRAY_FOREACH(children_, pNode)
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
	m_money	+= money;
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
	m_score	+= score;
	if( m_score < 0 )
	{
		m_score	= 0;
	}
}

@end
