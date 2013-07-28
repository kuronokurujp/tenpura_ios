//
//  TitleScene.h
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TitleScene : CCLayer
{
    CCParticleSystemQuad*   mp_particle;
}

-(void) resumeSchedulerAndActions;
-(void) pauseSchedulerAndActions;

@end
