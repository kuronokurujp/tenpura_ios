//
//  FeverStatusMenu.h
//  tenpura
//
//  Created by y.uchida on 13/07/09.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FeverStatusMenu : CCNode
{
@private
    CCLabelBMFont*  mp_bonusRateStr;
    CCLabelBMFont*  mp_timerStr;
}

@property   (nonatomic, retain)CCLabelBMFont*    bonusRateBMFont;
@property   (nonatomic, retain)CCLabelBMFont*    timerBMFont;

//  子のノードから指定したノードを変数に設定
-(void) setup;

@end
