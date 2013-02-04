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

@interface BannerViewController (PrivateMethod)

-(void)	_onBannerRequest;
-(void)	_setBannerRequestTimeSecVal:(float)in_val;

@end

@implementation BannerViewController

//	ゲーム内の動作停止させるかどうか
@synthesize bStopAnim	= mb_stopAnim;
@synthesize requestTime;
@synthesize pAwView	= mp_bannerView;

-(id)	initWithID:(NSString*)in_pIdName
{
	if( self = [super init] )
	{
		mp_keyId	= [in_pIdName retain];
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
		m_rect	= CGRectMake( 0, 0, 320, 50);
    }

    return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[mp_keyId release];
	mp_keyId	= nil;

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
	
	mp_bannerView	= [AdWhirlView requestAdWhirlViewWithDelegate:self];
	mp_bannerView.delegate	= self;
	[self.view addSubview:mp_bannerView];
	
	mp_bannerView.frame	= m_rect;

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

- (NSString *)adWhirlApplicationKey
{
	return mp_keyId;
}

/*
	@brief
*/
- (UIViewController *)viewControllerForPresentingModalView
{
	AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
    return pApp.navController;
}

/*
	@brief	バナー座標値
*/
-(void)	setBannerPos:(CGPoint)in_pos
{
	m_rect.origin	= in_pos;
	[mp_bannerView setFrame:m_rect];
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
