//
//  StoreTableCell.h
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface StoreTableCell : CCSprite
{
@private
	CCLabelBMFont*	mp_name;
	CCLabelBMFont*	mp_money;
}

@property	(nonatomic, retain)CCLabelBMFont*	pNameLabel;
@property	(nonatomic, retain)CCLabelBMFont*	pMoneyLabel;

-(void) setColor:(ccColor3B)color3;

@end
