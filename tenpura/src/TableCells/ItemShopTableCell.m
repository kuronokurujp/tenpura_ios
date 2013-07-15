//
//  ItemShopTableCell.m
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "ItemShopTableCell.h"

#import "./../Data/DataBaseText.h"

@implementation ItemShopTableCell

@synthesize pNameLabel      = mp_nameLabel;
@synthesize pDataLabel      = mp_dataLabel;
@synthesize pMoneyLabel     = mp_moneyLabel;
@synthesize pUnknowLabel	= mp_unknowLabel;
@synthesize pNumLabel       = mp_numLabel;
@synthesize pNewLabel       = mp_newTextLabel;
@synthesize pNumTitleLabel  = mp_numTitleLabel;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_soldOutSprite	= [CCSprite spriteWithFile:@"font_sold-out.png"];
		[self addChild:mp_soldOutSprite];
		[mp_soldOutSprite setVisible:NO];

		mp_nameLabel	= nil;
		mp_dataLabel	= nil;
		mp_moneyLabel	= nil;
		mp_unknowLabel	= nil;
        mp_numLabel = nil;
        mp_numTitleLabel    = nil;
        mp_nameLabel    = nil;
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
			else if( [pLabel.string isEqualToString:@"unknow"] )
			{
				mp_unknowLabel	= pLabel;
				[mp_unknowLabel setString:@""];
			}
            else if( [pLabel.string isEqualToString:@"num"] )
            {
                mp_numLabel = pLabel;
                [mp_numLabel setString:@""];
            }
            else if( [pLabel.string isEqualToString:@"New"] )
            {
                mp_newTextLabel = pLabel;
                [mp_newTextLabel setVisible:NO];
            }
            else if( [pLabel.string isEqualToString:[DataBaseText getString:158]] )
            {
                mp_numTitleLabel    = pLabel;
                [mp_numTitleLabel setVisible:NO];
            }
		}
	}
	
	CGRect	rect	= [self textureRect];
	[mp_soldOutSprite setPosition:ccp(rect.size.width * 0.5f, rect.size.height * 0.5f)];
    [mp_soldOutSprite setZOrder:10];
}

/*
	@brief	購入済みかどうかの判定を設定
*/
-(void)	setEnableSoldOut:(BOOL)in_bFlg
{
	[mp_soldOutSprite setVisible:in_bFlg];
    if( in_bFlg == YES )
    {
        [self setColor:ccGRAY];
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
        else if( [pNode isKindOfClass:[CCSprite class]] )
        {
            CCSprite*   pSprite = (CCSprite*)pNode;
            [pSprite setColor:color3];
        }
    }
}

@end
