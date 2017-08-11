//
//  Common.c
//  tenpura
//
//  Created by y.uchida on 13/09/28.
//
//

#include <stdio.h>
#include "Common.h"

//  異なる解像度にあわせた座標位置
const CGPoint    converPosVariableDevice( const CGPoint in_pos )
{
    CGPoint pos = in_pos;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
    {
     //   Float32 sclae   = (screenBounds.size.height / 480.f);
        
        // iPhone 5(4-inchスクリーン)用のレイアウト
        pos.x += ((screenBounds.size.height - 480) * 0.5f);//(pos.x * sclae);
    }
    
    return  pos;
}

//  異なる解像度にあわせたサイズ
const CGSize   converSizeVariableDevice( const CGSize in_size )
{
    CGSize size = in_size;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
    {
        Float32 sclae   = (screenBounds.size.height / 480.f);
        
        // iPhone 5(4-inchスクリーン)用のレイアウト
        size.width *= sclae;
    }
    
    return  size;
}

const bool isDeviceIPhone5()
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return (screenBounds.size.height == 568);
}

