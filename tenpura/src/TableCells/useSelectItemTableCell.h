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
	CCLabelBMFont*	mp_nameLabel;
	CCLabelBMFont*	mp_dataLabel;
    CCLabelBMFont*  mp_numLabel;
}

@property	(nonatomic, retain)CCLabelBMFont*	pNameLabel;
@property	(nonatomic, retain)CCLabelBMFont*	pDataLabel;
@property   (nonatomic, retain)CCLabelBMFont*   pNumLabel;

-(void) setColor:(ccColor3B)color3;

@end
