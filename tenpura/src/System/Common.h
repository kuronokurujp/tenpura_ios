//
//  Common.h
//  tenpura
//
//  Created by y.uchida on 13/09/28.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#ifndef tenpura_SysCommon_h
#define tenpura_DataGlobal_h

//  異なる解像度にあわせた座標位置
const CGPoint    converPosVariableDevice( const CGPoint in_pos );

//  異なる解像度にあわせたサイズ
const CGSize   converSizeVariableDevice( const CGSize in_size );

const bool isDeviceIPhone5();

#endif