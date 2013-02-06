//
//  TweetViewController.m
//

#import "TweetViewController.h"
#import "cocos2d.h"
#import "AppDelegate.h"

@interface TweetViewController (PriveteMethod)


- (void)pressBackBtn:(id)sender;

@end

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
	@brief
*/
- (id)initToSetup:(NSString*)in_pRetBtnText :(NSString*)in_pRetImageFileName
{
	mp_retBtnText	= [in_pRetBtnText retain];
	mp_retBtnImageFileName	= [in_pRetImageFileName retain];

	if( self = [super init] )
	{
		
	}
	
	return self;
}

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
			
			m_pTweetWebView = [[UIWebView alloc] init];
			[m_pTweetWebView setDelegate:self];
			[self.view addSubview:m_pTweetWebView];
		}
        
		//	 戻るボタンビュー設置
		{
			UIView*	pOldBtnView	= [self.view viewWithTag:eTAB_BTN_VIEW];
			[pOldBtnView removeFromSuperview];

			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			[btn setBackgroundImage:[UIImage imageNamed:mp_retBtnImageFileName] forState:UIControlStateNormal];
			[btn setTitle:mp_retBtnText forState:UIControlStateNormal];
		
			btn.tag	= eTAB_BTN_VIEW;
			[btn addTarget:self action:@selector(pressBackBtn:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:btn];
		}
    }

    return self;
}

/*
	@brief	解放
*/
- (void)dealloc
{
	[mp_retBtnText release];
	[mp_retBtnImageFileName release];
	
    [m_pTweetWebView release];
    [super dealloc];
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
- (void)startTweetViewWithTweetText:(NSString*)tweetText :(NSString*)in_pSearchURL
{
    NSString *tweetURL = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?original_referer=%@&text=%@",in_pSearchURL,tweetText];

    NSString *encodedTweetURL = (NSString *) CFURLCreateStringByAddingPercentEscapes (NULL, (CFStringRef) tweetURL, NULL, NULL,kCFStringEncodingUTF8);
    
    NSURL *url = [NSURL URLWithString:encodedTweetURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [m_pTweetWebView loadRequest:req];
	
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
    [(UIView *)[m_pTweetWebView viewWithTag:eTAG_GRAY_VIEW] removeFromSuperview];
    
	CGSize	winSize	= [CCDirector sharedDirector].winSize;
	//	座標およびView大きさ設定
	{
		m_pTweetWebView.frame	= CGRectMake(0, 0, winSize.width,winSize.height - 48);
	
		UIView*	pBtnView	= [self.view viewWithTag:eTAB_BTN_VIEW];
		pBtnView.frame	= CGRectMake(0, winSize.height - 48, winSize.width, 48);
	}

    // グレービューを載せる
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    [grayView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    grayView.tag = eTAG_GRAY_VIEW;
    
    [m_pTweetWebView addSubview:grayView];
    
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
    
    [(UIView *)[m_pTweetWebView viewWithTag:eTAG_GRAY_VIEW] removeFromSuperview];
}

-(NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	return UIInterfaceOrientationMaskLandscape;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
