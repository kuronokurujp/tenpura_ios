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
    UIWebView *tweetWebView;
}

- (void)pressBackBtn:(id)sender;
- (void)startTweetViewWithTweetText:(NSString*)tweetText:(NSString*)in_pSearchURL;
@end
