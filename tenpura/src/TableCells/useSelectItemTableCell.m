//
//  UseSelectItemTableCell.m
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "UseSelectItemTableCell.h"


@implementation UseSelectItemTableCell

@synthesize pNameLabel	= mp_nameLabel;
@synthesize pDataLabel	= mp_dataLabel;
@synthesize pNumLabel   = mp_numLabel;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_nameLabel	= nil;
		mp_dataLabel	= nil;
	}
	
	return self;
}

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
				mp_nameLabel	= pLabel;
				[mp_nameLabel setString:@""];
			}
			else if ( [pLabel.string isEqualToString:@"data"] )
			{
				mp_dataLabel	= pLabel;
				[mp_dataLabel setString:@""];
			}
            else if( [pLabel.string isEqualToString:@"num"] )
            {
                mp_numLabel = pLabel;
                [mp_numLabel setString:@""];
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
