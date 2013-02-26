//
//  MissionTableCell.h
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MissionTableCell : CCSprite {

@private
	CCLabelTTF*	mp_name;
	CCNode*	mp_chkBoxOn;
	CCNode*	mp_chkBoxOff;
}

@property	(nonatomic, retain)CCLabelTTF*	pNameLabel;
@property	(nonatomic, retain)CCNode*	pChkBoxOn;
@property	(nonatomic, retain)CCNode*	pChkBoxOff;

@end
