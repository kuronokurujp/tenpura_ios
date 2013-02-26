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
	CCLabelTTF*	mp_nameLabel;
	CCLabelTTF*	mp_dataLabel;
	CCLabelTTF*	mp_moneyLabel;
}

@property	(nonatomic, retain)CCLabelTTF*	pNameLabel;
@property	(nonatomic, retain)CCLabelTTF*	pDataLabel;
@property	(nonatomic, retain)CCLabelTTF*	pMoneyLabel;

@end
