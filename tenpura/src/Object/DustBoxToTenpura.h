//
//  DustBoxToTenpura.h
//  tenpura
//
//  Created by y.uchida on 13/06/18.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    eANIM_DUST_DUST_BOX_TO_TENPURA  = 0,
} ANIM_DUST_BOX_TO_TENPURA_ENUM;

@interface DustBoxToTenpura : CCSprite
{
}

@property   (nonatomic, readonly)Float32    colBoxSizeX;
@property   (nonatomic, readonly)Float32    colBoxSizeY;

//  アニメ開始
-(void) startAnim:(const ANIM_DUST_BOX_TO_TENPURA_ENUM)in_anim;

//  コリジョンの範囲
-(CGRect)getColBox;

@end
