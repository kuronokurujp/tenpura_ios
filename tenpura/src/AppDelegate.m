//
//  AppDelegate.m
//  tenpura
//
//  Created by y.uchida on 12/10/26.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//
#import <Twitter/Twitter.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#import "AppDelegate.h"
#import "BootScene.h"
#import "UINavigationControllerExt.h"
#import "./Data/DataBaseText.h"
#import "./Data/DataNetaList.h"
#import "./Data/DataSaveGame.h"
#import "./Data/DataTenpuraPosList.h"
#import "./Data/DataGlobal.h"
#import "./Data/DataMissionList.h"
#import "./System/Sound/SoundManager.h"
#import "./System/GameCenter/GameKitHelper.h"
#import "./System/BannerView/BannerViewController.h"
#import "./System/FileLoad/FileTexLoadManager.h"

@interface AppController (PrivateMethod)

-(void)	onBannerShow;
-(void)	onBannerHide;

-(void)	onTweetViewShow:(NSNotification*)in_pCenter;

@end

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

void uncaughtExceptionHandler( NSException* in_pException )
{
	CCLOG(@"CRASH: %@", in_pException);
	CCLOG(@"Stack Trace: %@", [in_pException callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//	クラッシュ時にコールスタック一覧を出力
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;
#ifdef DEBUG
	// Display FSP and SPF
	[director_ setDisplayStats:YES];
#endif
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director_ enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
//	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
//	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
//	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	//	必要なデータを読み込む
	[DataSaveGame shared];
	[DataNetaList shared];
	[DataTenpuraPosList shared];
	[DataBaseText shared];
	/*
		ミッションリストデータ読み込み順序が下記のより上だとハングするので注意
			テキスト
			ネタ
			セーブデータ
	*/
	[DataMissionList shared];
	[GameKitHelper shared].delegate	= self;
	//	サウンド管理データファイル設定
	[[SoundManager shared] setup:[NSString stringWithUTF8String:gp_soundDataListName]];
	//	ファイルテクスチャーロード
	[FileTexLoadManager shared];

	//	広告ビュー作成
	{
		mp_bannerViewCtrl	= [[BannerViewController alloc] init];
		[mp_bannerViewCtrl setBannerID:gp_admobBannerID];
		[mp_bannerViewCtrl setBannerPos:ccp(ga_bannerPos[0], ga_bannerPos[1])];
		mp_bannerViewCtrl.requestTime	= g_bannerRequestTimeSecVal;
	}

	//	広告ビュー呼び出し
	{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

		NSString*	pBannerShowName	= [NSString stringWithUTF8String:gp_bannerShowObserverName];
		[nc addObserver:self selector:@selector(onBannerShow) name:pBannerShowName object:nil];
		
		NSString*	pBannerHideName	= [NSString stringWithUTF8String:gp_bannerHideObserverName];
		[nc addObserver:self selector:@selector(onBannerHide) name:pBannerHideName object:nil];
	}
	
	//	TweetView作成
	{
        mp_tweetViewController = [[TweetViewController alloc] init];
	}
	
	//	TweetView呼び出し
	{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

		NSString*	pTweetViewShowName	= [NSString stringWithUTF8String:gp_tweetShowObserverName];
		[nc addObserver:self selector:@selector(onTweetViewShow:) name:pTweetViewShowName object:nil];
	}
		
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [BootScene scene]];
	
	// Create a Navigation Controller with the Director
//	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_ = [[UINavigationControllerExt alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
	{
		if( mp_bannerViewCtrl.bStopAnim == NO )
		{
			[director_ startAnimation];
		}
	}
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	UIView*	pView	= [CCDirector sharedDirector].view;
	if( [mp_bannerViewCtrl.view isDescendantOfView:pView] == YES )
	{
		[mp_bannerViewCtrl.view removeFromSuperview];
	}

	[SimpleAudioEngine end];
	CC_DIRECTOR_END();

	[SoundManager end];
	[DataMissionList end];
	[DataBaseText end];
	[DataNetaList end];
	[DataSaveGame end];
	[DataTenpuraPosList end];
	[GameKitHelper end];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

/*
	@brief	接続成功
*/
-(void)	onLocalPlayerAuthenticationChanged
{
	CCLOG(@"GameCetenr Authentication");
	
	//	GameCenterに入った段階でデータ設定をする。
	const SAVE_DATA_ST*	pSaveData	= [[DataSaveGame shared] getData];
	if( pSaveData->score > 0 )
	{
		NSString*	pDataName	= [NSString stringWithUTF8String:gp_leaderboardDataName];
		[[GameKitHelper shared] submitScore:pSaveData->year category:pDataName];
	}
	
	//	ミッションを最新にする。
}

/*
	@brief
*/
-(void)	onScoresSubmitted:(BOOL)in_bSuccess
{
}

/*
	@brief
*/
-(void)	onScoresReceived:(NSArray*)in_pScores
{
}

/*
	@brief
*/
-(void)	onLeaderboardViewDismissed
{
}

/*
	@brief	アチーブメントデータ送信
*/
-(void)	onAchievementReported:(GKAchievement*)achievement
{
}

/*
	@brief	アチーブメントリスト読み込み完了
*/
-(void)	onAchievementsLoaded:(NSMutableDictionary*)achievements
{
}

/*
	@brief	アチーブメント詳細読み込み完了
*/
-(void)	onAchievementDescription:(NSMutableDictionary*)achievementDescriptions
{
}

/*
	@brief	広告バナー表示
*/
-(void)	onBannerShow
{
	UIView*	pView	= [CCDirector sharedDirector].view;
	if( [mp_bannerViewCtrl.view isDescendantOfView:pView] == NO )
	{
		[pView addSubview:mp_bannerViewCtrl.view];
	}
}

/*
	@brief	広告バナー非表示
*/
-(void)	onBannerHide
{
	UIView*	pView	= [CCDirector sharedDirector].view;
	if( [mp_bannerViewCtrl.view isDescendantOfView:pView] == YES )
	{
		[mp_bannerViewCtrl.view removeFromSuperview];
	}
}

/*
	@brief	TweetView表示
*/
-(void)	onTweetViewShow:(NSNotification*)in_pCenter
{
	if( in_pCenter == nil )
	{
		return;
	}
	
	NSString*	pTextKeyName		= [NSString stringWithUTF8String:gp_tweetTextKeyName];
	NSString*	pSearchURLKeyName	= [NSString stringWithUTF8String:gp_tweetSearchURLKeyName];
	
	NSString*	pTweetText	= [[in_pCenter userInfo] objectForKey:pTextKeyName];
	NSString*	pTweetSearchURL	= [[in_pCenter userInfo] objectForKey:pSearchURLKeyName];
	if( ( pTweetText != nil ) && ( pTweetSearchURL != nil ) )
	{
		if( [[[UIDevice currentDevice] systemVersion] floatValue] < 5.0 )
		{
			[mp_tweetViewController startTweetViewWithTweetText:pTweetText:pTweetSearchURL];
		}
		else
		{
			TWTweetComposeViewController*	pCtrl	= [[TWTweetComposeViewController alloc] init];
			[pCtrl setInitialText:pTweetText];
			AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
			[pApp.navController presentModalViewController:pCtrl animated:YES];
			[pCtrl release];
		}
	}
}

#ifdef DEBUG
/*
	@brief	アチーブメントリストリセット
*/
-(void)	onResetAchievements:(BOOL)in_bSuccess
{
}

#endif

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[mp_tweetViewController release];
	[mp_bannerViewCtrl release];
	[window_ release];
	[navController_ release];

	[super dealloc];
}
@end

