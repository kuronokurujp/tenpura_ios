//
//  BootScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "BootScene.h"

#import "./Data/DataNetaList.h"
#import "./Data/DataTenpuraPosList.h"
#import "./Data/DataSaveGame.h"
#import "./Data/DataBaseText.h"
#import "./Data/DataGlobal.h"
#import "./System/Sound/SoundManager.h"
#import "./System/FileLoad/FileTexLoadManager.h"
#import "./CCBReader/CCBReader.h"

// BootScene implementation
@implementation BootScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BootScene *layer = [BootScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
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
