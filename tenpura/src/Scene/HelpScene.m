//
//  HelpScene.m
//  tenpura
//
//  Created by y.uchida on 12/12/24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "HelpScene.h"

#import "./../CCBReader/CCBReader.h"
#import "./../Data/DataGlobal.h"
#import "./../System/Sound/SoundManager.h"

//	指定した値をループするマクロ(unsigneの型だと失敗するので注意)
#define LOOP( _MIN_, _MAX_, _NUM_ ) (_MAX_) <= (_NUM_) ? (_MIN_) : (_NUM_) < (_MIN_) ? (_MAX_) - 1 : (_NUM_)

@interface HelpScene (PrivateMethoe)

-(void)	pressBackBtn;
-(void)	pressPageNextBtn;
-(void)	pressPagePrevBtn;
-(void)	changePage:(SInt32)in_idx;

@end

@implementation HelpScene

//	help用htmlファイル一覧
static NSString*	sp_helpHtmlNameList[]	=
{
	@"help1",
	@"help2",
	@"help3",
	@"help4",
	@"help5",
};

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		m_nowPageNum	= 0;
		m_maxPageNum	= sizeof(sp_helpHtmlNameList) / sizeof(sp_helpHtmlNameList[0]);
		mp_helpView	= nil;
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	if( mp_helpView != nil )
	{
		UIView*	pView	= [CCDirector sharedDirector].view;
		if( [mp_helpView isDescendantOfView:pView] == YES )
		{
			[mp_helpView removeFromSuperview];
		}

		[mp_helpView release];
	}
	
	[super dealloc];
}

/*
	@brief	変移演出終了
*/
-(void)	onEnterTransitionDidFinish
{
	//	バナー表示通知
	{
		NSString*	pBannerShowName	= [NSString stringWithUTF8String:gp_bannerShowObserverName];
		NSNotification *n = [NSNotification notificationWithName:pBannerShowName object:nil];
		NSAssert(n, @"");
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}

	//	ビューに表示
	{
		UIView*	pView	= [CCDirector sharedDirector].view;
		[pView	addSubview:mp_helpView];

		[self changePage:m_nowPageNum];
	}

	[super onEnterTransitionDidFinish];
}

/*
	@brief	シーン終了(変移開始)
*/
-(void)	onExitTransitionDidStart
{
	//	バナー非表示通知
	{
		NSString*	pBannerHideName	= [NSString stringWithUTF8String:gp_bannerHideObserverName];
		NSNotification *n = [NSNotification notificationWithName:pBannerHideName object:nil];
		NSAssert(n, @"");
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}

	UIView*	pView	= [CCDirector sharedDirector].view;
	if( [mp_helpView isDescendantOfView:pView] == YES )
	{
		[mp_helpView removeFromSuperview];
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
		CGRect	webViewRect	= CGRectMake(helpSceneXPos, helpSceneYPos, helpSceneSizeWidth, helpSceneSizeHeight );
		mp_helpView	= [[UIWebView alloc] initWithFrame:webViewRect];	
	}
}

/*
	@brief	タイトルに戻る
*/
-(void)	pressBackBtn
{
	CCScene*	pTitleScene	= [CCBReader sceneWithNodeGraphFromFile:@"title.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:2 scene:pTitleScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] replaceScene:pTransFade];
	
	[[SoundManager shared] play:eSOUND_CLICK04];
}

/*
	@brief	次のページに移行
*/
-(void)	pressPageNextBtn
{
	m_nowPageNum	= LOOP( 0, m_maxPageNum, m_nowPageNum + 1 );
	[self changePage:m_nowPageNum];
	
	[[SoundManager shared] play:eSOUND_CLICK01];
}

/*
	@brief	前のページに移行
*/
-(void)	pressPagePrevBtn
{
	m_nowPageNum	= LOOP( 0, m_maxPageNum, m_nowPageNum - 1 );
	[self changePage:m_nowPageNum];
	
	[[SoundManager shared] play:eSOUND_CLICK01];
}

/*
	@brief	ページ切り替え
*/
-(void)	changePage:(SInt32)in_idx
{
	NSAssert( mp_helpView, @"webViewを確保していない" );
	NSString*	pFilePath	= [[NSBundle mainBundle] pathForResource:sp_helpHtmlNameList[in_idx] ofType:@"html"];
	NSURL*	pFileUrl	= [NSURL fileURLWithPath:pFilePath];
	[mp_helpView loadRequest:[NSURLRequest requestWithURL:pFileUrl]];
}

@end
