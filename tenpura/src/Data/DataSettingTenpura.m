//
//  DataSettingTenpura.m
//  tenpura
//
//  Created by y.uchida on 12/11/03.
//
//

#import "DataSettingTenpura.h"

@implementation DataSettingTenpura

@synthesize no	= m_no;
@synthesize raiseTimeRate	= m_raiseTimeRate;

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
-(void)CopyData:(DataSettingTenpura *)in_pData
{
	if( in_pData == nil )
	{
		return;
	}
	
	m_no	= in_pData.no;
	m_raiseTimeRate	= in_pData.raiseTimeRate;
}

@end
