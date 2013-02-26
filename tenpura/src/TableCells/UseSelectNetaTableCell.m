//
//  UseSelectNetaTableCell.m
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "UseSelectNetaTableCell.h"


@implementation UseSelectNetaTableCell

@synthesize pNameLabel	= mp_nameLabel;
@synthesize pPossessionLabel	= mp_possession;
@synthesize pTenpuraIcon	= mp_tenpuraIcon;

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_possession	= nil;
		mp_name	= nil;
		mp_tenpuraIcon	= nil;
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
				mp_name	= pLabel;
				[mp_name setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"possession"] )
			{
				mp_possession	= pLabel;
				[mp_possession setString:@""];
			}
		}
		else if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			mp_tenpuraIcon	= (TenpuraIcon*)pNode;
		}
	}
}

@end
