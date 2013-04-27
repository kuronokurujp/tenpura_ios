//
//  MissionTableCell.m
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MissionTableCell.h"


@implementation MissionTableCell

@synthesize pNameLabel	= mp_name;
@synthesize pChkBoxOn	= mp_chkBoxOn;
@synthesize pChkBoxOff	= mp_chkBoxOff;

static NSString*	sp_MissionChkBoxOffSpriteName	= @"checkoff.png";
static NSString*	sp_MissionChkBoxOnSpriteName	= @"checkon.png";

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_name	= nil;
		mp_chkBoxOn	= nil;
		mp_chkBoxOff	= nil;
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
		if( [pNode isKindOfClass:[CCLabelTTF class]] )
		{
			CCLabelTTF*	pLabel	= (CCLabelTTF*)pNode;
			if( [pLabel.string isEqualToString:@"name"] )
			{
				mp_name	= pLabel;
				[mp_name setString:@""];
			}
		}
		else if( [pNode isKindOfClass:[CCNode class]] )
		{
			//	チェックボックス
			CGPoint	pos	= ccp(0.f, 0.f);

			CCSprite*	pChkBoxOn	= [CCSprite spriteWithFile:sp_MissionChkBoxOnSpriteName];
			[pChkBoxOn setPosition:pos];
			[pNode addChild:pChkBoxOn];

			CCSprite*	pChkBoxOff	= [CCSprite spriteWithFile:sp_MissionChkBoxOffSpriteName];
			[pChkBoxOff setPosition:pos];
			[pNode addChild:pChkBoxOff];
		}
	}
}

@end
