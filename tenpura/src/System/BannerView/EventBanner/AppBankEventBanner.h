//
//  AppBankEventBanner.h
//

#import <Foundation/Foundation.h>
#import "./../../../Admob/Add-ons/Mediation/GADCustomEventBanner.h"
#import "NADView.h"

@interface AppBankEventBanner : NSObject<NADViewDelegate,GADCustomEventBanner>

@property(nonatomic, assign)id<GADCustomEventBannerDelegate>delgate;

@end
