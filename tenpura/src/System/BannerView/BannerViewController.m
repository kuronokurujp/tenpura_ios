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

@end

@implementation BannerViewController

//	ゲーム内の動作停止させるかどうか
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
	 
	if( mp_bannerView != nil )
	{
		return;
	}

	mp_bannerView	= [AdWhirlView requestAdWhirlViewWithDelegate:self];
	mp_bannerView.delegate	= self;
	[self.view addSubview:mp_bannerView];
	
	mp_bannerView.frame	= m_rect;
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

@end
