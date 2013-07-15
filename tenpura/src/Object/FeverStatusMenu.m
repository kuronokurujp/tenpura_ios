//
//  FeverStatusMenu.m
//  tenpura
//
//  Created by y.uchida on 13/07/09.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "FeverStatusMenu.h"

@implementation FeverStatusMenu

@synthesize bonusRateBMFont   = mp_bonusRateStr;
@synthesize timerBMFont       = mp_timerStr;

-(id)  init
{
    if( self = [super init])
    {
    }
    
    return self;
}

-(void) setup
{
    CCNode* pChildNode  = nil;
    CCARRAY_FOREACH(_children, pChildNode)
    {
        if( [pChildNode isKindOfClass:[CCLabelBMFont class]] )
        {
            CCLabelBMFont*  pLabelBMFont    = (CCLabelBMFont*)pChildNode;
            if( [pLabelBMFont.string isEqualToString:@"score"] )
            {
                mp_bonusRateStr = pLabelBMFont;
            }
            else if( [pLabelBMFont.string isEqualToString:@"time"] )
            {
                mp_timerStr = pLabelBMFont;
            }
        }
    }
}

@end
