//
//  TenpuraIcon.m
//  tenpura
//
//  Created by y.uchida on 12/10/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "TenpuraIcon.h"


@implementation TenpuraIcon

@synthesize no	= m_no;

/*
	@brief	初期化
*/
-(id)	initWithFile:(NSString*)in_pFileName:(SInt32)in_no
{
	if( self = [super init] )
	{
		mp_sp	= [CCSprite node];
		[mp_sp initWithFile:in_pFileName];
		
		[mp_sp setAnchorPoint:ccp(0,0)];
		[self addChild:mp_sp];
		
		m_no	= in_no;
	}
	
	return self;
}

@end
