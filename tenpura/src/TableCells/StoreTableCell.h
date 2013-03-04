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
	CCLabelTTF*	mp_name;
	CCLabelTTF*	mp_money;
}

@property	(nonatomic, retain)CCLabelTTF*	pNameLabel;
@property	(nonatomic, retain)CCLabelTTF*	pMoneyLabel;

@end
