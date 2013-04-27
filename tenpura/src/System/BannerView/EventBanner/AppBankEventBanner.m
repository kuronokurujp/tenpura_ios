//
//  AppBankEventBanner.m
//  CameraPuzzle
//
//  Created by 星 弘高 on 12/09/24.
//
//

#import "AppBankEventBanner.h"
@interface AppBankEventBanner(){
    NADView* appbankView;
}@end
@implementation AppBankEventBanner
@synthesize delegate;
-(void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request{

    appbankView =[[NADView alloc]init];
    [appbankView  setFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)];
    [appbankView setDelegate:self];
    [appbankView setNendID:API_KEY spotID:SPOT_ID];
    [appbankView setRootViewController:[[UIViewController alloc]init]];
    [appbankView load:nil];
  //  [appbankView release];
    
}
-(void)nadViewDidFinishLoad:(NADView *)adView{
    [self.delegate customEventBanner:self didReceiveAd:adView];
}
-(void)dealloc{
    [super dealloc];
   [appbankView release];
    appbankView=nil;
   self.delegate=nil;
    
}
-(void)nadViewDidFailToReceiveAd:(NADView *)adView {
    NSLog(@"delegate nadViewDidReceiveAd:");
    //[appbankView load:nil];
   // appbankView=nil;
    

}
@end
