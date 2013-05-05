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
#import "./../../System/Store/StoreAppPurchaseManager.h"

@class StoreAppPurchaseManager;

@interface StoreScene : SWTableViewHelper
<
	UIAlertViewDelegate,
	StoreAppPurchaseManagerProtocol
>
{
@private
	UIAlertView*	mp_storeBuyCheckAlerView;
	UIView*	mp_grayView;
	UIActivityIndicatorView*	mp_indicator;
}

+(void)	payment:(NSString*)in_pProducts;

@end
