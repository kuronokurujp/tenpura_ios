//
//  SiireTableCell.m
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "SiireTableCell.h"


@implementation SiireTableCell

@synthesize pNameLabel	= mp_nameLabel;
@synthesize pMoneyLabel	= mp_moneyLabel;
@synthesize pPossessionLabel	= mp_possession;
@synthesize pTenpuraIcon	= mp_tenpuraIcon;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_tenpuraIcon	= nil;
		mp_moneyLabel	= nil;
		mp_possession	= nil;
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
				mp_nameLabel	= pLabel;
				[mp_nameLabel setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"possession"] )
			{
				mp_possession	= pLabel;
				[mp_possession setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"money"] )
			{
				mp_moneyLabel	= pLabel;
				[mp_moneyLabel setString:@""];
			}
		}
		else if( [pNode isKindOfClass:[TenpuraBigIcon class]] )
		{
			mp_tenpuraIcon	= (TenpuraBigIcon*)pNode;
		}
	}
}

@end
