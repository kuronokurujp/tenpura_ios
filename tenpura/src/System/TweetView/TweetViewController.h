//
//  TweetViewController.h
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UIViewController<UIWebViewDelegate>
{
@private
	UIWebView *m_pTweetWebView;
	NSString*	mp_retBtnImageFileName;
}

- (id)initToSetup:(NSString*)in_pRetImageFileName;

- (void)startTweetViewWithTweetText:(NSString*)tweetText :(NSString*)in_pSearchURL;
@end
