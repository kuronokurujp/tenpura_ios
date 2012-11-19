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

//	前方宣言
@class TweetViewController;
@class BannerViewController;

@interface AppController : NSObject <
	UIApplicationDelegate,
	CCDirectorDelegate,
	GameKitHelperProtocol>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref

	BannerViewController*	mp_bannerViewCtrl;
    TweetViewController*	mp_tweetViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
