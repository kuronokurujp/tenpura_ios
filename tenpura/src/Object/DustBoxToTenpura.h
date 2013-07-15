//
//  DustBoxToTenpura.h
//  tenpura
//
//  Created by y.uchida on 13/06/18.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DustBoxToTenpura : CCSprite
{
}

@property   (nonatomic, readonly)Float32    colBoxSizeX;
@property   (nonatomic, readonly)Float32    colBoxSizeY;

//  コリジョンの範囲
-(CGRect)getColBox;

@end
