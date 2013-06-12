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
@synthesize pUnknowLabel	= mp_unknowLabel;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_nameLabel	= nil;
		mp_moneyLabel	= nil;
		mp_unknowLabel	= nil;
		mp_soldOutSprite	= [CCSprite spriteWithFile:@"font_sold-out.png"];
		[self addChild:mp_soldOutSprite];
		[mp_soldOutSprite setVisible:NO];
		
		for( SInt32 i = 0; i < sizeof(mpa_netaNameList) / sizeof(mpa_netaNameList[0]); ++i )
		{
			mpa_netaNameList[i]	= nil;
		}
		
		for( SInt32 i = 0; i < sizeof(mpa_tenpuraIcon) / sizeof(mpa_tenpuraIcon[0]); ++i )
		{
			mpa_tenpuraIcon[i]	= nil;
		}
	}
	
	return self;
}

/*
	@brief
*/
-(void)	didLoadFromCCB
{
	SInt32	cnt	= 0;
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
			else if( [pLabel.string rangeOfString:@"netaName"].location != NSNotFound )
			{
				NSMutableString*	text	= [NSMutableString stringWithString:pLabel.string];
				NSRange	range	= NSMakeRange(0, text.length);
				[text replaceOccurrencesOfString:@"netaName" withString:@"" options:0 range:range];
				SInt32	idx	= text.intValue;
				mpa_netaNameList[idx]	= pLabel;
				[mpa_netaNameList[idx] setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"money"] )
			{
				mp_moneyLabel	= pLabel;
				[mp_moneyLabel setString:@""];
			}
			else if( [pLabel.string isEqualToString:@"unknow"] )
			{
				mp_unknowLabel	= pLabel;
				[mp_unknowLabel setString:@""];
			}
		}
		else if( [pNode isKindOfClass:[TenpuraIcon class]] )
		{
			mpa_tenpuraIcon[cnt]	= (TenpuraIcon*)pNode;
			++cnt;
		}
	}
	
	CGRect	rect	= [self textureRect];
	[mp_soldOutSprite setPosition:ccp(rect.size.width * 0.5f, rect.size.height * 0.5f)];
    [mp_soldOutSprite setZOrder:10];
}

/*
	@brief
*/
-(CCLabelBMFont*)	getNetaNameLabel:(SInt32)in_idx
{
	if( in_idx < sizeof(mpa_netaNameList) / sizeof(mpa_netaNameList[0]) )
	{
		return mpa_netaNameList[in_idx];
	}
	
	return	nil;
}

/*
	@brief
*/
-(TenpuraIcon*)	getNetaIconObj:(SInt32)in_idx
{
	if( in_idx < sizeof(mpa_tenpuraIcon) / sizeof(mpa_tenpuraIcon[0]))
	{
		return mpa_tenpuraIcon[in_idx];
	}
	
	return nil;
}

/*
	@brief	購入済みかどうかの設定
*/
-(void)	setEnableSoldOut:(BOOL)in_bFlg
{
	[mp_soldOutSprite setVisible:in_bFlg];
	[self setColor:ccGRAY];
}


@end
