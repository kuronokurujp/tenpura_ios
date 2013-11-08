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

@interface AppController : NSObject
<
	UIApplicationDelegate,
    UIAlertViewDelegate,
    NSURLConnectionDelegate,
	CCDirectorDelegate,
	StoreAppPurchaseManagerProtocol,
	GameKitHelperProtocol
>
{
    UIBackgroundTaskIdentifier bgTask_;
    
	UIWindow *window_;
	UINavigationController *navController_;

    UIView*	mp_grayView;
	UIActivityIndicatorView*	mp_indicator;
    UIAlertView*	mp_storeBuyCheckAlerView;
    UIAlertView*    mp_storeSuccessAlerView;
    UIAlertView*    mp_storeErrorAlerView;
    UIAlertView*    mp_networkTimeErrorAlerView;
    NSString*   mp_storeSuccessProduct;
    NSTimer*    mp_gameTimer;
    NSTimer*    mp_requestServerDateSendChk;
    
    BOOL    mb_visibleByGetNetTime;
    BOOL    mb_enableByGetNetTime;

	CCDirectorIOS	*director_;							// weak ref

    id<StoreAppPurchaseManagerSuccessProtocol> m_storeSuccessDelegate;
    
	BannerViewController*	mp_bannerViewCtrl;
	TweetViewController*	mp_tweetViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, assign) id<StoreAppPurchaseManagerSuccessProtocol> storeSuccessDelegate;
@property   (nonatomic, readonly)BOOL   bVisibleByGetNetTime;

@end
