//
//  SWTableViewWrapper.h
//  tenpura
//
//  Created by y.uchida on 12/11/12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "SWScrollView.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"

typedef struct
{
	UInt32	viewMax;
	CGSize	viewSize;
	CGSize	cellSize;
	CGPoint	viewPos;
	char	aCellFileName[ 64 ];

} SW_INIT_DATA_ST;

@interface SWTableViewHelper : CCLayer
<
	SWTableViewDelegate,
	SWScrollViewDelegate,
	SWTableViewDataSource
>
{
@public
	enum
	{
		eSW_TABLE_TAG_CELL_LAYOUT,
		eSW_TABLE_TAG_CELL_MAX,
	};

@private
	//	変数定義
	SWTableView*	mp_table;
	SW_INIT_DATA_ST	m_data;
	NSString*		mp_textFontName;
}

@property	(nonatomic, readonly)SW_INIT_DATA_ST	data;
@property	(nonatomic, retain)NSString*	textFontName;

//	関数
//	初期化
-(id)	initWithData:(SW_INIT_DATA_ST*)in_pData;
//	ビュー再更新
-(void)	reloadUpdate;
//	セル項目をタッチアクション実行
-(void)	actionCellTouch:(SWTableViewCell*)in_pCell;

@end
