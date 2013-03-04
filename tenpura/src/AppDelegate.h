//
//  AppDelegate.h
//  tenpura
//
//  Created by y.uchida on 12/10/26.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "System/GameCenter/GameKitHelper.h"
#import "System/TweetView/TweetViewController.h"
#import "System/Store/StoreAppPurchaseManager.h"

//	前方宣言
@class TweetViewController;
@class BannerViewController;
@class StoreAppPurchaseManager;

@interface AppController : NSObject <
	UIApplicationDelegate,
	CCDirectorDelegate,
	GameKitHelperProtocol,
	StoreAppPurchaseManagerProtocol>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref

	BannerViewController*	mp_bannerViewCtrl;
	TweetViewController*	mp_tweetViewController;
	UIAlertView*	mp_storeBuyCheckAlerView;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
