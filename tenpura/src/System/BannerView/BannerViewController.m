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

@interface BannerViewController (PrivateMethod)

-(void)	_onBannerRequest;
-(void)	_setBannerRequestTimeSecVal:(float)in_val;

@end

@implementation BannerViewController

//	ゲーム内の動作停止させるかどうか
@synthesize bStopAnim	= mb_stopAnim;
@synthesize requestTime;

-(id)	initWithID:(NSString*)in_pIdName
{
	mp_bannerView.adUnitID	= in_pIdName;
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
		mb_stopAnim	= NO;
		m_requestTimeSecVal	= 10.f;
		
		CGRect	bannerRect	= CGRectMake(
										0,
										0,
										GAD_SIZE_320x50.width,
										GAD_SIZE_320x50.height);
		mp_bannerView	= [[GADBannerView alloc] initWithFrame:bannerRect];
//		mp_bannerView.adUnitID	= @"a150a203dfecc8a";
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
	[mp_bannerView release];
	mp_bannerView	= nil;

	[super dealloc];
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
	[mp_bannerView loadRequest:pRp];
	
	mp_timer	= [NSTimer scheduledTimerWithTimeInterval:m_requestTimeSecVal
							target:self
							selector:@selector(_onBannerRequest)
							userInfo:nil
							repeats:YES];
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
	@brief	Admob広告をアプリ内で表示するケース
*/
- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    [[CCDirector sharedDirector] stopAnimation];
    mb_stopAnim = YES;
}

/*
	@brief	アプリ内で表示した広告を閉じる時
*/
- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    if (mb_stopAnim)
	{
        [[CCDirector sharedDirector] startAnimation];
        mb_stopAnim = NO;
    }
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
	@brief	バナーの表示リクエスト
*/
-(void)	_onBannerRequest
{
//	[mp_bannerView loadRequest:[GADRequest request]];
}

/*
	@brief	広告リクエスト時間（描画）を設定
*/
-(void)	_setBannerRequestTimeSecVal:(float)in_val
{
	if( 0 < in_val )
	{
		m_requestTimeSecVal	= in_val;
	}
}

@end
