//
//  StoreScene.h
//  tenpura
//
//  Created by y.uchida on 12/11/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./../BaseMenuScene.h"
#import "./../../System/TableView/SWTableViewHelper.h"
#import "./../../System/StoreView/StoreAppPurchaseViewController.h"

@interface StoreScene : SWTableViewHelper
<
	StoreAppPurchaseViewControllerProtocol
>
{
	StoreAppPurchaseViewController*	mp_storeViewCtrl;
}

@end
