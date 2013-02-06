//
//  TweetViewController.h
//  BigShot
//
//  Created by Kasajima Yasuo on 11/11/08.
//  Copyright (c) 2011 kyoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UIViewController<UIWebViewDelegate>
{
@private
    UIWebView *m_pTweetWebView;
	NSString*	mp_retBtnText;
	NSString*	mp_retBtnImageFileName;
}

- (id)initToSetup:(NSString*)in_pRetBtnText :(NSString*)in_pRetImageFileName;

- (void)startTweetViewWithTweetText:(NSString*)tweetText :(NSString*)in_pSearchURL;
@end
