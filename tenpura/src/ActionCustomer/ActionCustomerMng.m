//
//  ActionCustomerMng.m
//  tenpura
//
//  Created by y.uchida on 12/12/01.
//
//

#import "ActionCustomerMng.h"

@implementation ActionCustomerMng

/*
	@brief	初期化
*/
-(id)	initWithData:(Customer*)in_pOwner;
{
	NSAssert(in_pOwner, @"オーナー設定がない");
	if( self = [super init] )
	{
		mp_onwer	= in_pOwner;
	}
	
	return self;
}

/*
	@brief	終了
*/
-(void)	dealloc
{
	[super dealloc];
}

/*
	@brief	アクション設定
*/
-(BOOL)	setAction:(ACTION_CUSTOMER_ENUM)in_act
{
	return NO;
}

@end
