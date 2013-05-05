//
//  AppBankEventBanner.m
//  CameraPuzzle
//

#import "AppBankEventBanner.h"
@interface AppBankEventBanner()
{
	NADView* appbankView;
}
@end

@implementation AppBankEventBanner

@synthesize delegate;

-(void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request{

	if( appbankView != nil )
	{
		[appbankView setDelegate:nil];
		[appbankView release];
		appbankView	= nil;
	}

	appbankView =[[NADView alloc]init];

	[appbankView setIsOutputLog:NO];
#ifdef DEBUG
	[appbankView setIsOutputLog:YES];
#endif

	[appbankView  setFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)];
	[appbankView setDelegate:self];
	[appbankView setNendID:API_KEY spotID:SPOT_ID];
	[appbankView load:nil];
}

-(void) nadViewDidFinishLoad:(NADView *)adView
{
	[self.delegate customEventBanner:self didReceiveAd:adView];
}

-(void) dealloc
{
	[appbankView setDelegate:nil];
	[appbankView release];
	appbankView=nil;
	
	[super dealloc];	
}

-(void) nadViewDidFailToReceiveAd:(NADView *)adView
{
	NSLog(@"delegate nadViewDidReceiveAd:");
}

-(void) viewWillDisappear:(BOOL)animated
{
	[appbankView pause];
}

-(void) viewWillAppear:(BOOL)animated
{
	[appbankView resume];
}

@end
