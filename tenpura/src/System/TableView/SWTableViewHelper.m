//
//  SWTableViewWrapper.m
//  tenpura
//
//  Created by y.uchida on 12/11/12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SWTableViewHelper.h"
#import "./../../TableCells/SampleCell.h"

@implementation SWTableViewHelper

/*
	@brief
*/
-(id)	initWithData:(SW_INIT_DATA_ST*)in_pData
{
	NSAssert(in_pData, @"スクロールビューデータがない");
	if( self = [super init] )
	{
		//	セルファイル名はアドレスしかもっていないので注意
		m_data	= *in_pData;

		mp_table	= [SWTableView viewWithDataSource:self size:m_data.viewSize];
		[mp_table setPosition:m_data.viewPos];
		[mp_table setContentOffset:ccp( [mp_table minContainerOffset].x, [mp_table minContainerOffset].y )];

		mp_table.direction	= SWScrollViewDirectionVertical;
		mp_table.delegate	= self;
		mp_table.verticalFillOrder	= SWTableViewFillTopDown;
		
		[self addChild:mp_table z:3.f];
		[mp_table reloadData];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	mp_table	= nil;
	[super dealloc];
}

/*
	@brief	ビューリスト再更新
*/
-(void)	reloadUpdate
{
	[mp_table reloadData];
}

//	デリゲート定義
/*
	@brief	テーブルがセルにタッチしたときに呼ばれる
*/
-(void)table:(SWTableView*)table cellTouched:(SWTableViewCell *)cell
{
	CCLOG(@"touch[%d]", [cell objectID]);
}

/*
	@brief
	@note	セルのサイズを指定（描画するサイズとあわせないと表示が壊れる可能性がある。）
*/
-(CGSize)cellSizeForTable:(SWTableView *)table
{
	return m_data.cellSize;
}

/*
	@brief
*/
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	SWTableViewCell*	pCell	= [table dequeueCell];
	
	if( pCell == nil )
	{
		pCell	= [[[SampleCell alloc] init] autorelease];
	}

    CCSprite *pSprite = (CCSprite*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
	if( pSprite != nil )
	{
	}
	else
	{
		pSprite	= [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", m_data.aCellFileName]];
	    [pCell addChild:pSprite z:0 tag:eSW_TABLE_TAG_CELL_SPRITE];
	}

	[pSprite setPosition:ccp(0, 0)];
	[pSprite setAnchorPoint:ccp(0, 0)];

	NSString*	pStr	= @"";
	CCLabelTTF*	pLabel	= (CCLabelTTF*)[pSprite getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
	if( pLabel != nil )
	{
		[pLabel setString:pStr];
	}
	else
	{
		pLabel	= [CCLabelTTF labelWithString:pStr fontName:@"Helvetica" fontSize:m_data.fontSize];
		[pSprite addChild:pLabel z:0 tag:eSW_TABLE_TAG_CELL_TEXT];
	}

	CGSize	texSize	= [pSprite textureRect].size;
	[pLabel setPosition:ccp(texSize.width * 0.5f, texSize.height * 0.5f)];
	[pLabel setColor:ccc3( 0, 0, 0 )];

	return pCell;
}

/*
	@brief	テーブルの数
*/
-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table
{
	return m_data.viewMax;
}

/*
	@brief	セル項目をタッチアクション実行
*/
-(void)	actionCellTouch:(SWTableViewCell*)in_pCell
{
	NSAssert(in_pCell, @"");
	//	セル項目を光らせる
	CCBlink*	pBlinkAct	= [CCBlink actionWithDuration:0.5f blinks:2];
	[in_pCell runAction:pBlinkAct];
}

@end
