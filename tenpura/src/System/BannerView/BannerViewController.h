//
//  BannerViewController.h
//  tenpura
//
//  Created by y.uchida on 12/11/13.
//
//

#import <UIKit/UIKit.h>
#import "./../../Admob/GADBannerView.h"
#import "./../../Admob/GADBannerViewDelegate.h"

/*
	@note	Admobの広告には二つある
			１：アプリ内で広告を表示するケース
				さらに別アプリに飛ぶことができる
			２：別アプリを起動するケース
			
			１の対処で広告を開いたらアプリ内の動きを止める必要がある。
			さらに１から２に変異するケースもある。
*/
@interface BannerViewController : UIViewController
<
	GADBannerViewDelegate
>
{
@private
	GADBannerView*	mp_bannerView;
	NSString*	mp_unitIDName;
}

//	関数
-(id)	initWithID:(NSString*)in_pIdName;
-(void)	setBannerPos:(CGPoint)in_pos;
-(void)	setBannerID:(const char*)in_pName;
-(void)	showHide:(BOOL)in_bFlg;

@end
