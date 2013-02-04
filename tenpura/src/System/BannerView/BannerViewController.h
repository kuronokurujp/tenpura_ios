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
	NSTimer*		mp_timer;
	CGRect			m_rect;
	NSString*		mp_keyId;
	BOOL			mb_stopAnim;
	float			m_requestTimeSecVal;
}

@property	(nonatomic, readonly)BOOL	bStopAnim;
@property	(nonatomic, assign, setter = _setBannerRequestTimeSecVal: )float requestTime;
@property	(nonatomic, retain)AdWhirlView*	pAwView;

//	関数
-(id)	initWithID:(NSString*)in_pIdName;
-(void)	setBannerPos:(CGPoint)in_pos;

@end
