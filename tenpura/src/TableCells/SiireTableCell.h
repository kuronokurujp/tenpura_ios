//
//  SiireTableCell.h
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "./../Object/TenpuraIcon.h"

@interface SiireTableCell : CCSprite {

@private
	CCLabelTTF*	mp_nameLabel;
	CCLabelTTF*	mp_moneyLabel;
	CCLabelTTF*	mp_possession;
	TenpuraBigIcon*	mp_tenpuraIcon;
}

@property	(nonatomic, retain)CCLabelTTF*	pNameLabel;
@property	(nonatomic, retain)CCLabelTTF*	pMoneyLabel;
@property	(nonatomic, retain)CCLabelTTF*	pPossessionLabel;
@property	(nonatomic, retain)TenpuraBigIcon*	pTenpuraIcon;

@end
