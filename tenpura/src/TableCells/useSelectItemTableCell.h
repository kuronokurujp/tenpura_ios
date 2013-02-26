//
//  UseSelectItemTableCell.h
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface UseSelectItemTableCell : CCSprite {
@private
	CCLabelTTF*	mp_nameLabel;
	CCLabelTTF*	mp_dataLabel;
}

@property	(nonatomic, retain)CCLabelTTF*	pNameLabel;
@property	(nonatomic, retain)CCLabelTTF*	pDataLabel;

@end
