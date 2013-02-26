//
//  ItemShopTableCell.m
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "ItemShopTableCell.h"


@implementation ItemShopTableCell

@synthesize pNameLabel	= mp_nameLabel;
@synthesize pDataLabel	= mp_dataLabel;
@synthesize pMoneyLabel	= mp_moneyLabel;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_nameLabel	= nil;
		mp_dataLabel	= nil;
		mp_moneyLabel	= nil;
	}
	
	return self;
}

/*
	@brief
*/
-(void)	didLoadFromCCB
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[CCLabelTTF class]] )
		{
			CCLabelTTF*	pLabel	= (CCLabelTTF*)pNode;
			if( [pLabel.string isEqualToString:@"name"] )
			{
				mp_nameLabel	= pLabel;
				[mp_nameLabel setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"data"] )
			{
				mp_dataLabel	= pLabel;
				[mp_dataLabel setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"money"] )
			{
				mp_moneyLabel	= pLabel;
				[mp_moneyLabel setString:@""];
			}
		}
	}
}

@end
