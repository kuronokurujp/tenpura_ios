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

#define API_KEY	@"a6eca9dd074372c898dd1df549301f277c53f2b9"
#define SPOT_ID	@"3172"

@synthesize delegate;

-(void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
	if( appbankView != nil )
	{
		[appbankView setDelegate:nil];
		[appbankView release];
		appbankView	= nil;
	}
	
	NSArray* pItems	= nil;
	if( serverParameter != nil )
	{
		pItems	= [serverParameter componentsSeparatedByString:@","];
	}

	NSString*	pApiKey	= API_KEY;
	NSString*	pSPotId	= SPOT_ID;
	if( pItems != nil )
	{
		SInt32	dataIdx	= 0;
		pApiKey	= [pItems objectAtIndex:dataIdx];
		++dataIdx;

		pSPotId	= [pItems objectAtIndex:dataIdx];
	}

	appbankView =[[NADView alloc]init];

	[appbankView setIsOutputLog:NO];
#ifdef DEBUG
	[appbankView setIsOutputLog:YES];
#endif

	[appbankView  setFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)];
	[appbankView setDelegate:self];
	[appbankView setNendID:pApiKey spotID:pSPotId];
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
	//	再ロード
	[appbankView load:nil];
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
