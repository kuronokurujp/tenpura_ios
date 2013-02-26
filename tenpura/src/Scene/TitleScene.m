//
//  TitleScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TitleScene.h"

#import "./../CCBReader/CCBReader.h"
#import "./../Data/DataSaveGame.h"
#import "./../Data/DataGlobal.h"
#import "./../System/GameCenter/GameKitHelper.h"
#import "./../System/Sound/SoundManager.h"
#import "./../Data/DataBaseText.h"

@implementation TitleScene

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		[[GameKitHelper shared] authenticateLocalPlayer];

#ifdef DEBUG
	CCMenuItemFont*	pResetSaveItem		= [CCMenuItemFont	itemWithString:[NSString stringWithUTF8String:[[DataBaseText shared] getText:0]]
	block:^(id sender)
	{
		[[DataSaveGame shared] reset];
	}
	];
	[pResetSaveItem setFontSize:12.f];
	
	CCMenu*	pMenu	= [CCMenu menuWithItems:pResetSaveItem, nil];
	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	[pMenu setPosition:ccp( 120.f, winSize.height - 32 )];
	[self addChild:pMenu z:20];
#endif
		[[SoundManager shared] playBgm:@"normalBGM"];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	pressTwitterBtn
{
	DataBaseText*	pDataText	= [DataBaseText shared];

    NSString*	tweetText	= [NSString stringWithUTF8String:[pDataText getText:55]];
	NSString*	searchURL	= [NSString stringWithUTF8String:[pDataText getText:56]];

	NSString*	pTextKeyName		= [NSString stringWithUTF8String:gp_tweetTextKeyName];
	NSString*	pSearchURLKeyName	= [NSString stringWithUTF8String:gp_tweetSearchURLKeyName];
	NSDictionary*	pDlc	= [NSDictionary dictionaryWithObjectsAndKeys:
		tweetText,	pTextKeyName,
		searchURL,	pSearchURLKeyName,
		nil];

	NSString*	pOBName	= [NSString stringWithUTF8String:gp_tweetShowObserverName];
	NSNotification*	pNotification	=
	[NSNotification notificationWithName:pOBName object:self userInfo:pDlc];
	
	[[NSNotificationCenter defaultCenter] postNotification:pNotification];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	ゲーム変移
*/
-(void)	pressGameBtn
{
	CCScene*	sinagakiScene	= [CCBReader sceneWithNodeGraphFromFile:@"setting.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:sinagakiScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] replaceScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	ゲームセンター変移
*/
-(void)	pressGameCenterBtn
{
	[[GameKitHelper shared] showGameCenter];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	ヘルプ画面変移
*/
-(void)	pressHelpBtn
{
	CCScene*	helpScene	= [CCBReader sceneWithNodeGraphFromFile:@"help.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:helpScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] replaceScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	アプリ画面変移
*/
-(void)	pressMoreAppBtn
{
	[[SoundManager shared] playSe:@"btnClick"];
	
	DataBaseText*	pDataText	= [DataBaseText shared];
    NSString*	pURLText	= [NSString stringWithUTF8String:[pDataText getText:72]];
	NSURL*	pUrl	= [NSURL URLWithString:pURLText];
	[[UIApplication sharedApplication] openURL:pUrl];
}

@end
