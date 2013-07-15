//
//  DustBoxToTenpura.m
//  tenpura
//
//  Created by y.uchida on 13/06/18.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "DustBoxToTenpura.h"


@implementation DustBoxToTenpura

//  コリジョンの範囲
-(CGRect)getColBox
{
    CGRect  rect;
    rect.size.width = self.colBoxSizeX;
    rect.size.height    = self.colBoxSizeY;
    rect.origin.x   = self.position.x - rect.size.width;
    rect.origin.y   = self.position.y - rect.size.height;
    
    return rect;
}

#ifdef DEBUG
-(void)	draw
{
	[super draw];
    
	ccDrawColor4B(255, 0, 128, 255);
	CGPoint	p1,p2,p3,p4;
	
	CGRect	rect	= [self getColBox];
	//	オブジェクト描画位置が原点になるので原点値を引く
    
	p1	= ccp(rect.origin.x,rect.origin.y);
	p2	= ccp(rect.origin.x,rect.origin.y + rect.size.height);
	p3	= ccp(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height);
	p4	= ccp(rect.origin.x + rect.size.width,rect.origin.y);
    
	ccDrawLine(p1,p2);
	ccDrawLine(p2,p3);
	ccDrawLine(p3,p4);
	ccDrawLine(p4,p1);
	
	ccDrawColor4B(255, 255, 255, 255);
}
#endif

@end
