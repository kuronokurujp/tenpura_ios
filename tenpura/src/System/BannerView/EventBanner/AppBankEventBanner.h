//
//  AppBankEventBanner.h
//  CameraPuzzle
//
//  Created by 星 弘高 on 12/09/24.
//
//

#import <Foundation/Foundation.h>
#import "./../../../Admob/Add-ons/Mediation/GADCustomEventBanner.h"
#import "NADView.h"
//#define API_KEY	@"caf2591915a6bb98a690757a4bb06f43cecb5880"
//#define SPOT_ID	@"20215"
#define API_KEY	@"a6eca9dd074372c898dd1df549301f277c53f2b9"
#define SPOT_ID	@"3172"
@interface AppBankEventBanner : NSObject<NADViewDelegate,GADCustomEventBanner>
@property(nonatomic, assign)id<GADCustomEventBannerDelegate>delgate;

@end
