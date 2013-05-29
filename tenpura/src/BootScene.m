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
#import "./Data/DataOjamaNetaList.h"
#import "./Data/DataStoreList.h"
#import "./Data/DataNetaPackList.h"
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
	[DataSaveGame shared];
	[DataNetaList shared];
	[DataTenpuraPosList shared];
	[DataBaseText shared];
	[DataItemList shared];
	[DataCustomerList shared];
	[DataOjamaNetaList shared];
	[DataStoreList shared];
	[DataNetaPackList shared];
	[StoreAppPurchaseManager share];
	[DataStoreList shared];

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

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]))
	{
		[self scheduleUpdate];
		
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

	return self;
}

-(void) update:(ccTime)delta
{
	//	シーン変更
	CCScene*	mainScene	= [CCBReader sceneWithNodeGraphFromFile:@"title.ccbi"];
	[[CCDirector sharedDirector] replaceScene:mainScene];
}

@end
