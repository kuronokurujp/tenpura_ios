//
//  HelpScene.m
//  tenpura
//
//  Created by y.uchida on 12/12/24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "HelpScene.h"

#import "./../CCBReader/CCBReader.h"

@interface HelpScene (PrivateMethoe)

-(void)	pressBackBtn;

@end

@implementation HelpScene

/*
	@brief
*/
-(void)	pressBackBtn
{
	CCScene*	pTitleScene	= [CCBReader sceneWithNodeGraphFromFile:@"title.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:2 scene:pTitleScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] replaceScene:pTransFade];
}

@end
