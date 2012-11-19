//
//  TweetViewController.m
//

#import "TweetViewController.h"
#import "cocos2d.h"
#import "AppDelegate.h"

@implementation TweetViewController

//	それぞれのビューのタグ
enum
{
    eTAG_GRAY_VIEW = 100,
	eTAG_TAB_VIEW,
	eTAG_WEB_VIEW,
	eTAB_BTN_VIEW,
};

/*
	@brief	初期化
	@note	引数の値はこちらでは使用しない
*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		//	タブビュー設置
		{
			UIView*	pOldTabBar	= [self.view viewWithTag:eTAG_GRAY_VIEW];
			[pOldTabBar removeFromSuperview];
			
			UITabBar*	tabBar = [[UITabBar alloc] init];
			tabBar.tag	= eTAG_TAB_VIEW;
			[self.view addSubview:tabBar];
			[tabBar release];
		}
        
		//	Webビュー設置
		{
			UIView*	pOldWebView	= [self.view viewWithTag:eTAG_WEB_VIEW];
			[pOldWebView removeFromSuperview];
			
			tweetWebView = [[UIWebView alloc] init];
			[tweetWebView setDelegate:self];
			[self.view addSubview:tweetWebView];
		}
        
		//	 戻るボタンビュー設置
		{
			UIView*	pOldBtnView	= [self.view viewWithTag:eTAB_BTN_VIEW];
			[pOldBtnView removeFromSuperview];

			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			[btn setBackgroundImage:[UIImage imageNamed:@"Default.png"] forState:UIControlStateNormal];
			[btn setTitle:@"戻る" forState:UIControlStateNormal];
		
			btn.tag	= eTAB_BTN_VIEW;
			[btn addTarget:self action:@selector(pressBackBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:btn];
		}
    }

    return self;
}

/*
	@brief	WebViewを終了させるボタン
*/
- (void)pressBackBtn:(id)sender
{
	AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
    [pApp.navController dismissModalViewControllerAnimated:YES];
}

/*
	@brief	TweetViewを開く
*/
- (void)startTweetViewWithTweetText:(NSString*)tweetText:(NSString*)in_pSearchURL
{
    NSString *tweetURL = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?original_referer=%@&text=%@",in_pSearchURL,tweetText];

    NSString *encodedTweetURL = (NSString *) CFURLCreateStringByAddingPercentEscapes (NULL, (CFStringRef) tweetURL, NULL, NULL,kCFStringEncodingUTF8);
    
    NSURL *url = [NSURL URLWithString:encodedTweetURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [tweetWebView loadRequest:req];
	
	[encodedTweetURL release];

	//	WebView開始
	AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
    [pApp.navController presentModalViewController:self animated:YES];
}

/*
	@brief	WebViewロード開始
*/
-(void)webViewDidStartLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [(UIView *)[tweetWebView viewWithTag:eTAG_GRAY_VIEW] removeFromSuperview];
    
	CGSize	winSize	= [CCDirector sharedDirector].winSize;
	//	座標およびView大きさ設定
	{
		tweetWebView.frame	= CGRectMake(0, 0, winSize.width,winSize.height - 48);
	
		UIView*	pBtnView	= [self.view viewWithTag:eTAB_BTN_VIEW];
		pBtnView.frame	= CGRectMake(0, winSize.height - 48, winSize.width, 48);
	}

    // グレービューを載せる
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    [grayView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    grayView.tag = eTAG_GRAY_VIEW;
    
    [tweetWebView addSubview:grayView];
    
    //インジケーターを載せる
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setCenter:CGPointMake(winSize.width * 0.5f, winSize.height * 0.5f)];
    [grayView addSubview:indicator];
    [indicator startAnimating];
    
    [grayView release];
    [indicator release];
}

/*
	@brief	WebViewロード終了
*/
-(void)webViewDidFinishLoad:(UIWebView*)webView
{
    //終わったらViewを外す
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [(UIView *)[tweetWebView viewWithTag:eTAG_GRAY_VIEW] removeFromSuperview];
}


#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [tweetWebView release];
    [super dealloc];
}

@end
