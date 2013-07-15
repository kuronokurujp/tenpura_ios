//
//  ItemShopTableCell.h
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ItemShopTableCell : CCSprite {

@private
	CCLabelBMFont*	mp_nameLabel;
	CCLabelBMFont*	mp_dataLabel;
	CCLabelBMFont*	mp_moneyLabel;
	CCLabelBMFont*	mp_unknowLabel;
    CCLabelBMFont*  mp_numLabel;
    CCLabelBMFont*  mp_newTextLabel;
    CCLabelBMFont*  mp_numTitleLabel;
	CCSprite*	mp_soldOutSprite;
}

@property	(nonatomic, retain)CCLabelBMFont*	pNameLabel;
@property	(nonatomic, retain)CCLabelBMFont*	pDataLabel;
@property	(nonatomic, retain)CCLabelBMFont*	pMoneyLabel;
@property	(nonatomic, retain)CCLabelBMFont*	pUnknowLabel;
@property   (nonatomic, retain)CCLabelBMFont*   pNumLabel;
@property   (nonatomic, retain)CCLabelBMFont*   pNewLabel;
@property   (nonatomic, retain)CCLabelBMFont*   pNumTitleLabel;

-(void)	setEnableSoldOut:(BOOL)in_bFlg;
-(void) setColor:(ccColor3B)color3;

@end
