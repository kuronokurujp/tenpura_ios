//
//  BannerViewController.h
//  tenpura
//
//  Created by y.uchida on 12/11/13.
//
//

#import <UIKit/UIKit.h>
#import "./../../AdWhirl/AdWhirlView.h"
#import "./../../AdWhirl/AdWhirlDelegateProtocol.h"

/*
	@note	AdWhirl
			Web側で多数の広告対応ができる
			
			現在対応している広告
				Admob
*/
@interface BannerViewController : UIViewController
<
	AdWhirlDelegate
>
{
@private
	AdWhirlView*	mp_bannerView;
	CGRect			m_rect;
	NSString*		mp_keyId;
}

@property	(nonatomic, retain)AdWhirlView*	pAwView;

//	関数
-(id)	initWithID:(NSString*)in_pIdName;
-(void)	setBannerPos:(CGPoint)in_pos;
-(void)	showHide:(BOOL)in_bFlg;

@end
