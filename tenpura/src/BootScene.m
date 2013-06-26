//
//  BootScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "BootScene.h"

#import "./Data/DataBaseText.h"
#import "./Data/DataNetaList.h"
#import "./Data/DataSaveGame.h"
#import "./Data/DataTenpuraPosList.h"
#import "./Data/DataGlobal.h"
#import "./Data/DataMissionList.h"
#import "./Data/DataItemList.h"
#import "./Data/DataCustomerList.h"
#import "./Data/DataStoreList.h"
#import "./Data/DataNetaPackList.h"
#import "./Data/DataEventDataList.h"
#import "./System/Sound/SoundManager.h"
#import "./System/FileLoad/FileTexLoadManager.h"
#import "./System/Store/StoreAppPurchaseManager.h"
#import "./CCBReader/CCBReader.h"

// BootScene implementation
@implementation BootScene

+(CCScene *) scene
{    
    return [CCBReader sceneWithNodeGraphFromFile:@"title.ccbi"];
}

/*
    @brief
 */
+(void) setting
{
	//	必要なデータを読み込む
	[DataItemList shared];
	[DataNetaList shared];
	[DataTenpuraPosList shared];
	[DataBaseText shared];
	[DataCustomerList shared];
	[DataStoreList shared];
	[DataNetaPackList shared];
	[StoreAppPurchaseManager share];
	[DataStoreList shared];
    [DataEventDataList shared];
    
	/*
     ミッションリストデータ読み込み順序が下記のより上だとハングするので注意
     テキスト
     ネタ
     セーブデータ
     */
	[DataMissionList shared];
    
	//	サウンド管理データファイル設定
	[[SoundManager shared] setup:[NSString stringWithUTF8String:gp_soundDataListName]];

	[DataSaveGame shared];

    //	テクスチャー先読み
    {
        UInt32	num	= sizeof(ga_animDataList) / sizeof(ga_animDataList[0]);
        for( UInt32 i = 0; i < num; ++i )
        {
            [[FileTexLoadManager shared] LoadAsync:[NSString stringWithUTF8String:ga_animDataList[i].pImageFileName]];
        }
        
        num	= sizeof(gpa_spriteFileNameList) / sizeof(gpa_spriteFileNameList[0]);
        for( UInt32 i = 0; i < num; ++i )
        {
            [[FileTexLoadManager shared] LoadAsync:[NSString stringWithUTF8String:gpa_spriteFileNameList[i]]];
        }
    }
    
    //	SE先読み
    [[SoundManager shared] preLoad:@"caf"];
    
    //	トランザクション中かチェック
    [[StoreAppPurchaseManager share] checkTransaction];
}

+(void) release
{
    [DataEventDataList end];
	[DataNetaPackList end];
	[StoreAppPurchaseManager end];
	[DataStoreList end];
	[DataMissionList end];
	[DataItemList end];
	[DataCustomerList end];
	[DataBaseText end];
	[DataNetaList end];
	[DataSaveGame end];
	[DataTenpuraPosList end];
    
	[SoundManager end];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]))
	{
		[self scheduleUpdate];		
	}

	return self;
}

-(void) update:(ccTime)delta
{
	//	シーン変更
	CCScene*	mainScene	= [CCBReader sceneWithNodeGraphFromFile:@"title.ccbi"];
	[[CCDirector sharedDirector] replaceScene:mainScene];
}

@end
