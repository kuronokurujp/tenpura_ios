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
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[CCLabelBMFont class]] )
		{
			CCLabelBMFont*	pLabel	= (CCLabelBMFont*)pNode;
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

-(void) setColor:(ccColor3B)color3
{
    [super setColor:color3];

    CCNode* pNode   = nil;
    CCARRAY_FOREACH(_children, pNode)
    {
        if( [pNode isKindOfClass:[CCLabelBMFont class]] )
        {
            CCLabelBMFont*  pLabelBM    = (CCLabelBMFont*)pNode;
            [pLabelBM setColor:color3];
        }
    }
}

@end
