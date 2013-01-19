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
@synthesize raiseSpeedRate	= m_raiseSpeedRate;

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		m_no	= 0;
		m_raiseSpeedRate	= 0.f;
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
	m_raiseSpeedRate	= in_pData.raiseSpeedRate;
}

@end
