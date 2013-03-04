//
//  StoreTableCell.m
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "StoreTableCell.h"


@implementation StoreTableCell

@synthesize pNameLabel	= mp_name;
@synthesize pMoneyLabel	= mp_money;

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
				mp_name	= pLabel;
				[mp_name setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"money"] )
			{
				mp_money	= pLabel;
				[mp_money setString:@""];
			}
		}
	}
}

@end
