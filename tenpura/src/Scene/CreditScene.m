//
//  CreditScene.m
//  tenpura
//
//

#import "CreditScene.h"

#import "./../Data/DataGlobal.h"
#import "./../System/Sound/SoundManager.h"

@interface CreditScene (PrivateMethoe)

-(void)	pressBackBtn;

@end

@implementation CreditScene

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_view	= nil;
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	if( mp_view != nil )
	{
		UIView*	pView	= [CCDirector sharedDirector].view;
		if( [mp_view isDescendantOfView:pView] == YES )
		{
			[mp_view removeFromSuperview];
		}

		[mp_view release];
	}
	
	[super dealloc];
}

/*
	@brief	変移演出終了
*/
-(void)	onEnterTransitionDidFinish
{
	//	ビューに表示
	{
		UIView*	pView	= [CCDirector sharedDirector].view;
		[pView	addSubview:mp_view];
	}

	[super onEnterTransitionDidFinish];
}

/*
	@brief	シーン終了(変移開始)
*/
-(void)	onExitTransitionDidStart
{
	UIView*	pView	= [CCDirector sharedDirector].view;
	if( [mp_view isDescendantOfView:pView] == YES )
	{
		[mp_view removeFromSuperview];
	}

	[super onExitTransitionDidStart];
}

/*
	@brief
*/
-(void)	didLoadFromCCB
{
	//	htmlファイル表示
	{
		CGRect	webViewRect	= CGRectMake(creditSceneXPos, creditSceneYPos, creditSceneSizeWidth, creditSceneSizeHeight );
		mp_view	= [[UIWebView alloc] initWithFrame:webViewRect];
		NSString*	pFilePath	= [[NSBundle mainBundle] pathForResource:@"credit" ofType:@"html"];
		NSURL*	pFileUrl	= [NSURL fileURLWithPath:pFilePath];
		[mp_view loadRequest:[NSURLRequest requestWithURL:pFileUrl]];
	}
}

/*
	@brief	前の画面に戻る
*/
-(void)	pressBackBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:g_sceneChangeTime];
	
	[[SoundManager shared] playSe:@"pressBtnClick"];
}

@end
