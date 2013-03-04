//
//  BannerViewController.m
//  tenpura
//
//  Created by y.uchida on 12/11/13.
//
//

#import "BannerViewController.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "./../../Admob/GADRequest.h"

#import <AdSupport/ASIdentifierManager.h>

@implementation BannerViewController

-(id)	initWithID:(NSString*)in_pIdName
{
	mp_unitIDName	= [in_pIdName retain];
	if( self = [super init] )
	{
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		mp_bannerView	= nil;
		
		CGRect	bannerRect	= CGRectMake(
										0,
										0,
										GAD_SIZE_320x50.width,
										GAD_SIZE_320x50.height);
		mp_bannerView	= [[GADBannerView alloc] initWithFrame:bannerRect];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	if( [mp_bannerView isDescendantOfView:self.view] == YES )
	{
		[mp_bannerView removeFromSuperview];
	}

	mp_unitIDName	= nil;
	[mp_bannerView release];
	mp_bannerView	= nil;

	[super dealloc];
}

/*
	@brief
*/
- (BOOL)application:(UIApplication *)application
	didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Print IDFA (from AdSupport Framework) for iOS 6 and UDID for iOS < 6.
	if (NSClassFromString(@"ASIdentifierManager"))
	{
		NSLog(@"GoogleAdMobAdsSDK ID for testing: %@",
		[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
	}
	else
	{
		NSLog(@"GoogleAdMobAdsSDK ID for testing: %@", [[UIDevice currentDevice] uniqueIdentifier]);
	}

	return YES;
}

/*
	@brief	ビュー表示初回のみで呼ばれる
*/
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	親のビューを呼ばないとサイト以降しない
	AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
	mp_bannerView.rootViewController	= pApp.navController;
	
	mp_bannerView.delegate	= self;
	[self.view addSubview:mp_bannerView];
	
	GADRequest*	pRp	= [GADRequest request];
#ifdef DEBUG
	pRp.testing	= YES;
	pRp.testDevices	= [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
#endif
	NSLog(@"BannerUnitId : %@", mp_unitIDName);
	mp_bannerView.adUnitID	= mp_unitIDName;
	[mp_bannerView loadRequest:pRp];
}

/*
	@brief	メモリが足りなくなったときに呼ばれる
*/
-(void)	viewDidUnload
{
	if( [mp_bannerView isDescendantOfView:self.view] == YES )
	{
		[mp_bannerView removeFromSuperview];
	}

	[super viewDidUnload];
}

/*
	@brief	広告の読み込み成功
*/
-(void)	adViewDidReceiveAd:(GADBannerView *)view
{
	//	スライドアニメをする
	[UIView beginAnimations:@"BannerSlide" context:nil];
	[UIView commitAnimations];
}

/*
	@brief	広告の読み込み失敗
*/
-(void)	adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
	NSLog(@"adView:didFallError:%@", [error localizedDescription]);
}

/*
	@brief	Admob広告をアプリ内で表示するケース
*/
- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
	NSLog(@"広告を開く前");
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

/*
	@brief	アプリ内で表示した広告を閉じる時
*/
- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
	//	iAdはここは呼ばれない
	NSLog(@"広告直前を終了");
}

/*
	@brief
*/
-(void)	adViewDidDismissScreen:(GADBannerView *)adView
{
	NSLog(@"広告を終了");
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}

/*
	@brief	バナー座標値
*/
-(void)	setBannerPos:(CGPoint)in_pos
{
	CGRect	rect	= mp_bannerView.frame;
	rect.origin	= in_pos;
	[mp_bannerView setFrame:rect];
}

/*
	@brief	バナーのパブリッシュID
*/
-(void)	setBannerID:(const char*)in_pName
{
	if( in_pName == nil )
	{
		return;
	}
	
	NSString*	pIDName	= [NSString stringWithUTF8String:in_pName];
	[mp_bannerView setAdUnitID:pIDName];
}

/*
	@brief
*/
-(void)	showHide:(BOOL)in_bFlg
{
	[mp_bannerView setHidden:in_bFlg];
}

@end
