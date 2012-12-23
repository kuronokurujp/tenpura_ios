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

@interface BaseMenuScene : CCLayer
{
@protected
	CCLabelTTF*			mp_nowMoneyText;
	CCLabelTTF*			mp_nowHiScoreText;
}

@end
