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
#import "./Data/DataItemList.h"
#import "./Data/DataCustomerList.h"
#import "./Data/DataStoreList.h"
#import "./Data/DataNetaPackList.h"
#import "./System/Sound/SoundManager.h"
#import "./System/GameCenter/GameKitHelper.h"
#import "./System/BannerView/BannerViewController.h"
#import "./System/FileLoad/FileTexLoadManager.h"
#import "./System/Store/StoreAppPurchaseManager.h"
#import "./System/Common.h"

@interface AppController (PrivateMethod)

/*!
    @brief  オブサーバーからのサーバー日付依頼関数
 */
-(void) _onRequestGetServerDate;

/*!
    @brief  サーバー日付依頼関数
    @note
        この関数はタイマー設定して、呼び出しが成功するまで呼び出し続ける。
        非通信時には通信になるまで毎フレーム呼ばれる。
 */
-(void) _onRequestServerDateByTimer:(id)in_sender;

/*!
    @brief  ゲームタイム更新依頼
    @note
        サーバー日付などゲーム内タイムを外部から取得した場合に呼び出す
 */
-(void) _requestGameTimerUpdate;

/*!
    @brief  ゲーム内タイムを常に更新する
    @note
        １秒ごとのタイマー設定で呼び出すようにしている。
 */
-(void) _onUpdateCntSecTimer:(id)in_sender;

/*!
    @brief  バナーを開くオブサーバー関数
 */
-(void)	onBannerShow;

/*!
    @brief  バナーを閉じるオブサーバー関数
 */
-(void)	onBannerHide;

/*!
    @brief  ツイッター画面を開くオブサーバー関数
 */
-(void)	onTweetViewShow:(NSNotification*)in_pCenter;

/*!
    @brief  ストアのエラー時の処理依頼
    @param  in_pErrorMessage : アラートに表示するテキスト
    @note
        内部でアラート表示処理をしている
 */
-(void)	_requestStoreError:(NSString*)in_pErrorMessage;

/*!
    @brief  アドオンストア処理が終わった時に必ず呼び出す
 */
-(void)	_storeEnd;

/*!
    @brief  アドオン購入後の処理
    @note
        購入アイテムによる処理をする
 */
-(void)	_payment:(NSString*)in_pProducts;

/*!
    @brief  サーバー日付を取得依頼
    @return TRUE : 依頼成功 / FALSE : 依頼失敗
    @note
        ネットワークサーバーから最新の日付を取得依頼をする
*/
-(const BOOL) _requestServerDate;

@end

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;
@synthesize storeSuccessDelegate    = m_storeSuccessDelegate;
@synthesize bVisibleByGetNetTime    = mb_visibleByGetNetTime;

void uncaughtExceptionHandler( NSException* in_pException )
{
	CCLOG(@"CRASH: %@", in_pException);
	CCLOG(@"Stack Trace: %@", [in_pException callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    mp_bannerViewCtrl   = nil;
    mp_tweetViewController  = nil;
    mp_grayView = nil;
    mp_indicator    = nil;
    m_storeSuccessDelegate  = nil;
    mp_networkTimeErrorAlerView = nil;
    mp_gameTimer    = nil;
    mp_requestServerDateSendChk  = nil;
    mb_visibleByGetNetTime  = YES;
    mb_enableByGetNetTime   = YES;
    bgTask_ = UIBackgroundTaskInvalid;

	//	iOS4のみしかない処理に対応
	[UIViewController iOS4compatibilize];

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
    [BootScene setting];

	//	アドオンのトランザクションが残っている場合の対応
	[StoreAppPurchaseManager share].delegate	= self;

	[GameKitHelper shared].delegate	= self;
	//	ファイルテクスチャーロード
	[FileTexLoadManager shared];

	//	広告ビュー作成
	{
        UInt32  widthType   = GAD_SIZE_320x50.width;
        UInt32  heightType  = GAD_SIZE_320x50.height;
        
        if( isDeviceIPhone5() )
        {
            widthType   = GAD_SIZE_468x60.width;
        }
        
		mp_bannerViewCtrl	= [[BannerViewController alloc] initWithID:[DataBaseText getString:73] :widthType :heightType];
        CGPoint pos = ccp(ga_bannerPos[0], ga_bannerPos[1]);//converPosVariableDevice(ccp(ga_bannerPos[0], ga_bannerPos[1]));
		[mp_bannerViewCtrl setBannerPos:pos];
		
		const	SAVE_DATA_ST*	pSaveData	= [[DataSaveGame shared] getData];
		if( pSaveData->adsDel == 1 )
		{
			[mp_bannerViewCtrl setUse:NO];
		}
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
		mp_tweetViewController = [[TweetViewController alloc] initToSetup:@"btn_twitter01.png"];
	}
	
	//	TweetView呼び出し
	{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

		NSString*	pTweetViewShowName	= [NSString stringWithUTF8String:gp_tweetShowObserverName];
		[nc addObserver:self selector:@selector(onTweetViewShow:) name:pTweetViewShowName object:nil];
	}
		
    //	ストア処理関連のアラート
	{
		mp_storeBuyCheckAlerView	= [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        mp_storeSuccessAlerView	= [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
	}

    //  ネットタイム取得通知
    {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
		NSString*	pObserverName	= [NSString stringWithUTF8String:gp_getNetTimeObserverName];
		[nc addObserver:self selector:@selector(_onRequestGetServerDate) name:pObserverName object:nil];
    }
    
    //  バッチを非表示にする。
    //  回復が最大値になった時にバッチ表示していることがあるかもしれないので。
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
	if( [[[UIDevice currentDevice] systemVersion] floatValue] < 6.0 )
	{
		return UIInterfaceOrientationMaskLandscape;
	}

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
    [[DataSaveGame shared] save];

	if( [navController_ visibleViewController] == director_ )
	{
		StoreAppPurchaseManager*	pStoreInst	= [StoreAppPurchaseManager share];
		if( ([pStoreInst isTransaction] == NO) && (pStoreInst.bLoad == NO) )
		{
			[director_ pause];
		}
        
        //  バックグランド中も時間関連は継続しておく（１０分しかつかえないが）
        BOOL    bBackGroundSuppeoted = NO;
        UIDevice*   pDevice = [UIDevice currentDevice];
        if( [pDevice respondsToSelector:@selector(isMultitaskingSupported)])
        {
            bBackGroundSuppeoted    = pDevice.multitaskingSupported;
        }
        
        if( bBackGroundSuppeoted )
        {
            bgTask_  = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:bgTask_];
                bgTask_ = UIBackgroundTaskInvalid;
            }];
          
            DataSaveGame*   pDataSaveGameInst   = [DataSaveGame shared];
            const SAVE_DATA_ST* pSaveData   = [pDataSaveGameInst getData];

            dispatch_queue_t gcd_queue =
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(gcd_queue, ^{
                //  バックグランド中は実行する。
                while(bgTask_ != UIBackgroundTaskInvalid)
                {
                    if( pSaveData->playLife < eSAVE_DATA_PLAY_LIEF_MAX )
                    {
                        SInt32  nowCureTime = pDataSaveGameInst.nowCureTime;
                        //  回復時間になっているか
                        if( nowCureTime <= 0 )
                        {
                            //  回復
                            [pDataSaveGameInst addPlayLife:1];
                            
                            //  バッチ表示
                            [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                            
                            //  ローカル通信をする
                            [[UIApplication sharedApplication] cancelAllLocalNotifications];
                            UILocalNotification* plocalNotification = [[[UILocalNotification alloc] init] autorelease];
                            //  通知内容を指定
                            [plocalNotification setAlertBody:[DataBaseText getString:1052]];
                            [plocalNotification setHasAction:NO];
                            
                            [[UIApplication sharedApplication] presentLocalNotificationNow:plocalNotification];
                        }
                    }
                }
            });
        }
	}
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
	{
		StoreAppPurchaseManager*	pStoreInst	= [StoreAppPurchaseManager share];
		if( ([pStoreInst isTransaction] == NO) && (pStoreInst.bLoad == NO) )
		{
			[director_ resume];
		}
        
        //  アプリがフォワードになったら再度タイム取得する
        mb_visibleByGetNetTime  = YES;
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        if( bgTask_ != UIBackgroundTaskInvalid )
        {
            [application endBackgroundTask:bgTask_];
            bgTask_ = UIBackgroundTaskInvalid;
        }
	}
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
	{
		StoreAppPurchaseManager*	pStoreInst	= [StoreAppPurchaseManager share];
		if( ([pStoreInst isTransaction] == NO) && (pStoreInst.bLoad == NO) )
		{
			[director_ stopAnimation];
		}        
	}
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
	{
		StoreAppPurchaseManager*	pStoreInst	= [StoreAppPurchaseManager share];
		if( ([pStoreInst isTransaction] == NO) && (pStoreInst.bLoad == NO) )
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

    [BootScene release];
    
	[GameKitHelper end];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	NSLog(@"warning free memory 1.5MB low¥n");
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
		[[GameKitHelper shared] submitScore:pSaveData->score category:pDataName];
	}
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
    @brief  ネットタイム取得開始
 */
-(void) _onRequestGetServerDate
{
    //  通信開始タイマー作成
    if( mp_requestServerDateSendChk == nil )
    {
        mp_requestServerDateSendChk  = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(_onRequestServerDateByTimer:) userInfo:nil repeats:YES];
        NSAssert(mp_requestServerDateSendChk, @"");
    }    
}

/*
    @brief  ゲームタイマースタート
 */
-(void) _requestGameTimerUpdate
{
    if( mp_gameTimer == nil )
    {
        mp_gameTimer  = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_onUpdateCntSecTimer:) userInfo:nil repeats:YES];
        NSAssert(mp_gameTimer, @"");
    }    
}

/*
    @brief  １秒ごとのタイマーカウント
 */
-(void) _onUpdateCntSecTimer:(id)in_sender
{
    DataSaveGame*   pDataSaveGameInst   = [DataSaveGame shared];
    pDataSaveGameInst.gameTime  += 1;
    [pDataSaveGameInst addPlayLifeTimerCnt:-1];
    [pDataSaveGameInst addEventTimerCnt:-1];
}

/*
 */
-(void) _onRequestServerDateByTimer:(id)in_sender
{
    //  すでに別口でネットワークで発生しているのであればいったん止める
    if( [UIApplication sharedApplication].networkActivityIndicatorVisible == YES )
    {
        return;
    }
    
    if( mb_enableByGetNetTime == NO )
    {
        return;
    }

    mb_visibleByGetNetTime  = NO;
    {
        if( [self _requestServerDate] == NO )
        {
            UIAlertView*	pAlert	= [[[UIAlertView alloc]
                                        initWithTitle:[DataBaseText getString:1050]
                                        message:[DataBaseText getString:1051]
                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:
                                        nil, nil] autorelease];
            
            mp_networkTimeErrorAlerView = pAlert;
            [pAlert show];
        }
        else
        {
            [[CCDirector sharedDirector] pause];
        }
        
        [mp_requestServerDateSendChk invalidate];
        mp_requestServerDateSendChk  = nil;
    }
}

/*
	@brief	広告バナー表示
*/
-(void)	onBannerShow
{
	const	SAVE_DATA_ST*	pSaveData	= [[DataSaveGame shared] getData];
	if( pSaveData->adsDel == 1 )
	{
		return;
	}
	
	UIView*	pView	= [CCDirector sharedDirector].view;
	if( [mp_bannerViewCtrl.view isDescendantOfView:pView] == NO )
	{
		[pView addSubview:mp_bannerViewCtrl.view];
		[pView bringSubviewToFront:mp_bannerViewCtrl.view];
	}
	[mp_bannerViewCtrl showHide:NO];
}

/*
	@brief	広告バナー非表示
*/
-(void)	onBannerHide
{
	const	SAVE_DATA_ST*	pSaveData	= [[DataSaveGame shared] getData];
	if( pSaveData->adsDel == 1 )
	{
		[mp_bannerViewCtrl setUse:NO];
	}

	[mp_bannerViewCtrl showHide:YES];
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
            if( [TWTweetComposeViewController canSendTweet] )
            {
                TWTweetComposeViewController*	pCtrl	= [[TWTweetComposeViewController alloc] init];
                [pCtrl setInitialText:pTweetText];
                AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
                [pApp.navController presentModalViewController:pCtrl animated:YES];
                [pCtrl release];                
            }
            else
            {
                //  ツイートが利用できないの。
            }
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

/*
 @brief	トランザクションの開始
 */
-(void)	onStartTransaction:(const STORE_REQUEST_TYPE_ENUM)in_type
{
	NSString*	pAlerTitleStr	= nil;
	if( in_type == eSTORE_REQUEST_TYPE_PAY )
	{
		pAlerTitleStr	= [DataBaseText getString:118];
	}
	else if( in_type == eSTORE_REQUEST_TYPE_RESTORE )
	{
		pAlerTitleStr	= [DataBaseText getString:119];
	}
	else if( in_type == eSTORE_REQUEST_TYPE_RESTART )
	{
		pAlerTitleStr	= [DataBaseText getString:120];
	}

    if( pAlerTitleStr != nil )
	{
		[mp_storeBuyCheckAlerView setTitle:pAlerTitleStr];
		[mp_storeBuyCheckAlerView setMessage:[DataBaseText getString:121]];
		[mp_storeBuyCheckAlerView show];
	}
}

/*
 @brief	トランザクションの終了
 */
-(void)	onEndTransaction
{
	[self _storeEnd];
}

/*
 @brief	購入決済終了
 */
-(void)	onPaymentPurchased:(NSString*)in_pProducts
{
	[self _payment:in_pProducts];
}

/*
 @brief	リストア完了
 */
-(void)	onPaymentRestore:(NSString*)in_pProducts
{
	[self _payment:in_pProducts];
}

/*
 @brief	決済途中キャンセル
 */
-(void)	onPaymentFailed:(NSError*)in_pError
{
	NSString*	pMessageStr	= [in_pError localizedDescription];
    
	//	購入失敗通知
	switch( in_pError.code )
	{
		case SKErrorClientInvalid:
		{
			//	不正なクライアント
			break;
		}
		case SKErrorPaymentCancelled:
		{
			//	購入がキャンセル
			pMessageStr	= [DataBaseText getString:115];
			break;
		}
		case SKErrorPaymentInvalid:
		{
			//	不正な購入
			break;
		}
		case SKErrorPaymentNotAllowed:
		{
			//	購入が許可されていない
			pMessageStr	= [DataBaseText getString:116];
			break;
		}
		case SKErrorStoreProductNotAvailable:
		{
			//	プロダクトが使えない
			break;
		}
		case SKErrorUnknown:
		{
			//	未知のエラー
		}
		default:
		{
			break;
		}
	}
	
	[self _requestStoreError:pMessageStr];
}

//  プロダクト情報取得
-(void) onGetProduect:(SKProduct*)in_pProduct
{
    DataStoreList*  pDataStoreShared    = [DataStoreList shared];
    SInt32		dataNum	= [pDataStoreShared dataNum];
    
    for( SInt32 data_i = 0; data_i < dataNum; ++data_i )
    {
        const STORE_DATA_ST*    pData   = [pDataStoreShared getData:data_i];
        if( [[NSString stringWithUTF8String:pData->aStoreIdName] isEqualToString:in_pProduct.productIdentifier] )
        {
            [pDataStoreShared setBuyMoney:data_i :[in_pProduct.price unsignedLongValue]];
            break;
        }
    }
}

//  プロダクトデータ取得終了
-(void) onEndGetProducts
{
    [self _storeEnd];
}

/*
 @brief	リクエスト開始
 */
-(void)	onRequest
{
    mb_enableByGetNetTime   = NO;

	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
	
	UIView*	pView	= [CCDirector sharedDirector].view;
    
	CGSize	winSize	= [CCDirector sharedDirector].winSize;
	//	通信状態を表示
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
	
	UIView*	pGrayView	= [[UIView alloc] initWithFrame:CGRectMake(0,0,winSize.width,winSize.height)];
	[pGrayView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f]];
	pGrayView.tag	= 21;
	[pView addSubview:pGrayView];
    
	UIActivityIndicatorView*	pIndicator	= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[pIndicator setCenter:ccp(winSize.width * 0.5f, winSize.height * 0.5f)];
	[pGrayView addSubview:pIndicator];
	[pIndicator startAnimating];
    
	mp_grayView	= pGrayView;
	mp_indicator	= pIndicator;
}

/*
 @brief	リクエスト失敗
 */
-(void)	onErrorRequest:(NSError *)in_pError
{
	[self _storeEnd];
	
	NSString*	pMessage	= nil;
	if( in_pError != nil )
	{
		pMessage	= [in_pError localizedDescription];
	}
	
	if( (pMessage == nil) || ([pMessage isEqualToString:@""]) )
	{
		pMessage	= [DataBaseText getString:1000];
	}
	
	[self _requestStoreError:pMessage];
}

/*
 @brief	ストアのエラー時の処理
 */
-(void)	_requestStoreError:(NSString*)in_pErrorMessage
{
	UIAlertView*	pAlert	= [[[UIAlertView alloc]
								initWithTitle:@"" message:in_pErrorMessage
								delegate:self
								cancelButtonTitle:[DataBaseText getString:46]
								otherButtonTitles:nil, nil] autorelease];
	[pAlert show];
    mp_storeErrorAlerView   = pAlert;
}

/*
    @brief	ストアの終了処理
 */
-(void)	_storeEnd
{
	[mp_storeBuyCheckAlerView dismissWithClickedButtonIndex:0 animated:YES];

	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
    
	if( mp_indicator )
	{
		[mp_indicator removeFromSuperview];
		mp_indicator	= nil;
	}
	
	if( mp_grayView )
	{
		[mp_grayView removeFromSuperview];
		mp_grayView	= nil;
	}
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;
}

/*
    @brief	購入処理
 */
-(void)	_payment:(NSString*)in_pProducts
{
    mp_storeSuccessProduct  = [in_pProducts retain];

	//	購入内容によって設定する
	DataStoreList*	pStoreInst	= [DataStoreList shared];
	if( pStoreInst != nil )
	{
		for( int i = 0; i < pStoreInst.dataNum; ++i )
		{
			const STORE_DATA_ST*	pData	= [pStoreInst getData:i];
			if( pData != nil )
			{
				NSString*	pStr	= [NSString stringWithUTF8String:pData->aStoreIdName];
				if([pStr isEqualToString:in_pProducts])
				{
					switch( pData->no )
					{
                        case eSTORE_ID_CUTABS:
                        {
                            [[DataSaveGame shared] saveCutAdsFlg];
                            
                            //	バナー非表示通知
                            {
                                NSString*	pBannerHideName	= [NSString stringWithUTF8String:gp_bannerHideObserverName];
                                NSNotification *n = [NSNotification notificationWithName:pBannerHideName object:nil];
                                NSAssert(n, @"");
                                [[NSNotificationCenter defaultCenter] postNotification:n];
                            }
                            break;
                        }
                        case eSTORE_ID_CURELIEF:
                        {
                            [[DataSaveGame shared] addPlayLife:eSAVE_DATA_PLAY_LIEF_MAX];
                            break;
                        }
                        case eSTORE_ID_MONEY_3000:		{ [[DataSaveGame shared] addSaveMoeny:3000]; break; }
                        case eSTORE_ID_MONEY_9000:		{ [[DataSaveGame shared] addSaveMoeny:9000]; break; }
                        case eSTORE_ID_MONEY_80000:		{ [[DataSaveGame shared] addSaveMoeny:80000]; break; }
                        case eSTORE_ID_MONEY_400000:	{ [[DataSaveGame shared] addSaveMoeny:400000]; break; }
                        case eSTORE_ID_MONEY_900000:	{ [[DataSaveGame shared] addSaveMoeny:900000]; break; }
					}
				}
			}
		}        
	}
    
    {
        //	購入終了後に呼び出す
        {
            NSString*	pPaymentObsName	= [NSString stringWithUTF8String:gp_paymentObserverName];
            NSNotification *n = [NSNotification notificationWithName:pPaymentObsName object:nil];
            NSAssert(n, @"");
            [[NSNotificationCenter defaultCenter] postNotification:n];
        }
    }
	
    [mp_storeSuccessAlerView setMessage:[DataBaseText getString:114]];
    if( [mp_storeSuccessAlerView numberOfButtons] <= 0 )
    {
        [mp_storeSuccessAlerView addButtonWithTitle:[DataBaseText getString:46]];
    }
	[mp_storeSuccessAlerView show];
}

/*
    @brief
 */
-(void)	alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( mp_storeSuccessAlerView == alertView )
    {
        if( m_storeSuccessDelegate && ([m_storeSuccessDelegate respondsToSelector:@selector(onStoreSuccess:)]) )
        {
            //  ストア成功
            [m_storeSuccessDelegate onStoreSuccess:mp_storeSuccessProduct];
            mp_storeSuccessProduct  = nil;
        }
        mb_enableByGetNetTime   = YES;
    }
    else if( mp_storeErrorAlerView == alertView )
    {
        mb_enableByGetNetTime   = YES;
        mp_storeErrorAlerView   = nil;
    }
    else if( mp_networkTimeErrorAlerView == alertView )
    {
        [self _requestServerDate];
        mp_networkTimeErrorAlerView = nil;
    }
}

//  通信結果取得
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)receiveData
{
    //  ゲーム初期化
    [DataSaveGame shared].gameTime  = 0;

    //  取得する文字列は「年／月／日 時:分:秒」なのは確実
    NSString* pStr  = [[[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"%@", pStr);
    
    //  文字列を解析
    NSDateComponents*   pComp   = [[[NSDateComponents alloc] init] autorelease];
    pComp.year  = 0;
    pComp.month = 0;
    pComp.day   = 0;
    pComp.hour  = 0;
    pComp.minute    = 0;
    pComp.second    = 0;
    
    {
        //  年月日と時分日で分ける
        NSArray*    pItems  = [pStr componentsSeparatedByString:@" "];
        NSAssert([pItems count] == 2, @"");
        //  「年/月/日」を取得
        NSString*   pYearMonthDayStr    = [pItems objectAtIndex:0];
        {
            NSArray*    pYearMonthDayItem   = [pYearMonthDayStr componentsSeparatedByString:@"/"];
            pComp.year      = [[pYearMonthDayItem objectAtIndex:0] intValue];
            pComp.month     = [[pYearMonthDayItem objectAtIndex:1] intValue];
            pComp.day       = [[pYearMonthDayItem objectAtIndex:2] intValue];
        }
        
        //  「時:分:秒」を」取得
        NSString*   pHourMinSecStr    = [pItems objectAtIndex:1];
        {
            NSArray*    pHourMinSecItem = [pHourMinSecStr componentsSeparatedByString:@":"];
            pComp.hour      = [[pHourMinSecItem objectAtIndex:0] intValue];
            pComp.minute    = [[pHourMinSecItem objectAtIndex:1] intValue];
            pComp.second    = [[pHourMinSecItem objectAtIndex:2] intValue];
        }
    }
    
    NSCalendar* pCal    = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDate* nowDate = [pCal dateFromComponents:pComp];
    
    //  日付をローカル保存
    [DataSaveGame shared].networkDate   = nowDate;
    
    //  日付関連に関わるステータスを更新
    [[DataSaveGame shared] updateTimeStatus:nowDate];
    
    //  ゲーム内タイマー開始
    [self _requestGameTimerUpdate];
}

//  通信成功
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    //  インジケータ表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[CCDirector sharedDirector] resume];
}

//  通信失敗
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"network error");
	UIAlertView*	pAlert	= [[[UIAlertView alloc]
								initWithTitle:[DataBaseText getString:1050]
								message:[DataBaseText getString:1051]
								delegate:self cancelButtonTitle:@"OK" otherButtonTitles:
								nil, nil] autorelease];
    
	[pAlert show];
    
    mp_networkTimeErrorAlerView = pAlert;
    
    //  通信失敗表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(const BOOL) _requestServerDate
{
    NSURL*  pUrl    = [[NSURL alloc] initWithString:@"http://n2-games.com/time/time.php"];
    NSURLRequest*   pReq    = [[NSURLRequest alloc] initWithURL:pUrl];
    NSURLConnection*    pCon    = [[NSURLConnection alloc] initWithRequest:pReq delegate:self];
    if( pCon == nil )
    {
        //  失敗表示
        NSLog(@"network error");
        return NO;
    }
    
	CGSize	winSize	= [CCDirector sharedDirector].winSize;

    // グレービューを載せる
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    [grayView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    
    //インジケーターを載せる
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setCenter:CGPointMake(winSize.width * 0.5f, winSize.height * 0.5f)];
    [grayView addSubview:indicator];
    [indicator startAnimating];
    
    [grayView release];
    [indicator release];

    return YES;
}

@end

