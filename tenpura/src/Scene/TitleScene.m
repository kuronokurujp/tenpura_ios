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
#import "./../Data/DataItemList.h"
#import "./../Data/DataGlobal.h"
#import "./../System/GameCenter/GameKitHelper.h"
#import "./../System/Sound/SoundManager.h"
#import "./../Data/DataBaseText.h"

#ifdef DEBUG

#endif

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
//	デバッグ画面
        CCMenuItemFont*	pResetSaveItem		= [CCMenuItemFont	itemWithString:[NSString stringWithUTF8String:[[DataBaseText shared] getText:0]]
	block:^(id sender)
	{
		[[DataSaveGame shared] reset: [DataItemList shared]];
	}
	];
	[pResetSaveItem setFontSize:12.f];
    [pResetSaveItem setColor:ccBLACK];

        CCMenuItemFont*	pFullGetItem		= [CCMenuItemFont	itemWithString:@"アイテムすべて取得"
    block:^(id sender)
    {
        for( SInt32 i = 0; i < [DataItemList shared].dataNum; ++i )
        {
            const ITEM_DATA_ST*       pData   = [[DataItemList shared] getData:i];
            if( pData->itemType != eITEM_IMPACT_OPEN_NETAPACK )
            {
                [[DataSaveGame shared] addItem:pData->no];
            }
        }
    }
    ];
    [pFullGetItem setFontSize:12.f];
    [pFullGetItem setColor:ccBLACK];
    [pFullGetItem setPosition:ccp(0, -30)];
        

	CCMenu*	pMenu	= [CCMenu menuWithItems:pResetSaveItem, pFullGetItem, nil];
	[pMenu setPosition:ccp( 80.f, 300 )];
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
	if( [[GameKitHelper shared] showLeaderboard] == NO )
    {
        //	機能制限でつかえない
        UIAlertView*	pAlert	= [[[UIAlertView alloc]
                                    initWithTitle:@"" message:[DataBaseText getString:157]
                                    delegate:nil
                                    cancelButtonTitle:[DataBaseText getString:46]
                                    otherButtonTitles:nil, nil] autorelease];
        [pAlert show];
    }
	
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
	
	[[CCDirector sharedDirector] pushScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	アプリ画面変移
*/
-(void)	pressMoreAppBtn
{
	[[SoundManager shared] playSe:@"btnClick"];
	
	CCScene*	creditScene	= [CCBReader sceneWithNodeGraphFromFile:@"credit.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:creditScene withColor:ccBLACK];

	[[CCDirector sharedDirector] pushScene:pTransFade];
}

/*
 @brief	CCBI読み込み終了
 */
- (void) didLoadFromCCB
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		//	セッティング項目をあらかじめ取得する
		if( [pNode isKindOfClass:[CCLabelTTF class]] )
		{
            CCLabelTTF* pLabelTTF   = (CCLabelTTF*)pNode;
            if( [[pLabelTTF string] isEqualToString:@"konohaByParticle"] )
            {
                CCParticleSystemQuad*   pParticle   = [CCParticleSystemQuad particleWithFile:@"konoha.plist"];
                NSAssert(pParticle, @"");
                [pLabelTTF addChild:pParticle];
            }
            [pLabelTTF setString:@""];
		}
	}
}

@end
