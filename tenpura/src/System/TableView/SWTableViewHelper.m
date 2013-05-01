//
//  SWTableViewWrapper.m
//  tenpura
//
//  Created by y.uchida on 12/11/12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SWTableViewHelper.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../CCBReader/CCBReader.h"

@implementation SWTableViewHelper

@synthesize data	= m_data;
@synthesize textFontName	= mp_textFontName;

/*
	@brief	初期化(初期化の段階でリストデータが分からない場合に呼ぶ)
*/
-(id)	initWithFree
{
	if( [super init] )
	{
	}
	
	return self;
}

/*
	@brief	初期化（初期化の段階でリストデータが分かる場合に呼ぶ）
*/
-(id)	initWithData:(SW_INIT_DATA_ST*)in_pData
{
	NSAssert(in_pData, @"スクロールビューデータがない");
	if( self = [super init] )
	{
		[self setup:in_pData];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[mp_textFontName release];
	mp_textFontName	= nil;

	mp_table	= nil;
	[super dealloc];
}

/*
	@brief	セットアップ（初期化処理以外で画面セットアップを呼ぶ場合に必要）
*/
-(void)	setup:(SW_INIT_DATA_ST*)in_pData
{
	if( in_pData == nil )
	{
		return;
	}
	
	mp_textFontName	= [[NSString alloc] initWithString:@"Helvetica"];

	//	セルファイル名はアドレスしかもっていないので注意
	m_data	= *in_pData;
	if( m_data.aCellFileName[ 0 ] != 0 )
	{
		CCNode*	pCellScene	= [CCBReader nodeGraphFromFile:[NSString stringWithUTF8String:m_data.aCellFileName]];
		NSAssert([pCellScene isKindOfClass:[CCSprite class]], @"");
			
		CCSprite*	pTmpSp	= (CCSprite*)pCellScene;
		m_data.cellSize	= [pTmpSp contentSize];
	}

	mp_table	= [SWTableView viewWithDataSource:self size:m_data.viewSize contentOffset:ccp(0,0)];
	[mp_table setPosition:m_data.viewPos];
	[mp_table setContentOffset:ccp( [mp_table minContainerOffset].x, [mp_table minContainerOffset].y )];

	mp_table.direction	= SWScrollViewDirectionVertical;
	mp_table.delegate	= self;
	mp_table.verticalFillOrder	= SWTableViewFillTopDown;
		
	[self addChild:mp_table z:3.f];
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

	CCNode*	pNode	= [pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	if( pNode == nil )
	{
		CCNode*	pCellScene	= [CCBReader nodeGraphFromFile:[NSString stringWithUTF8String:m_data.aCellFileName]];
		NSAssert([pCellScene isKindOfClass:[CCSprite class]], @"");
		
		[pCell addChild:pCellScene z:1 tag:eSW_TABLE_TAG_CELL_LAYOUT];
		
		CCSprite*	pSp	= (CCSprite*)pCellScene;
		[pSp setAnchorPoint:ccp(0, 0)];
		[pSp setPosition:ccp(0, 0)];
	}

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
