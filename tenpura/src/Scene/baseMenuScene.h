//
//  baseMenuScene.h
//  tenpura
//
//  Created by y.uchida on 12/12/13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./../System/TableView/SWTableViewHelper.h"

@class AnimActionNumCounterLabelTTF;

@interface BaseMenuScene : CCLayer
{
@protected
	AnimActionNumCounterLabelTTF*			mp_nowMoneyText;
	AnimActionNumCounterLabelTTF*			mp_nowHiScoreText;
}

@end
