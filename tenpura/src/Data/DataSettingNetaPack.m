//
//  DataSettingNetaPack.m
//  tenpura
//
//  Created by y.uchida on 12/11/03.
//
//

#import "DataSettingNetaPack.h"

@implementation DataSettingNetaPack

@synthesize no	= m_no;

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		m_no	= 0;
	}
	
	return self;
}

/*
	@brief	別データからのデータコピー用
*/
-(void)CopyData:(DataSettingNetaPack *)in_pData
{
	if( in_pData == nil )
	{
		return;
	}
	
	m_no	= in_pData.no;
}

@end
