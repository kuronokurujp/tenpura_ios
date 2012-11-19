//
//  SiireScene.h
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./../../System/TableView/SWTableViewHelper.h"

@interface SiireScene : SWTableViewHelper
<
	UIAlertViewDelegate
>
{
	UIAlertView*	mp_buyCheckAlertView;
	UIAlertView*	mp_buyAlertView;
	
	SWTableViewCell*	mp_buyItemCell;
	CCLabelTTF*	mp_moneyTextLable;
}

@end
