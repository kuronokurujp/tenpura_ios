//
//  AnimActionNumCounterLabelTTF.m
//  tenpura
//
//  Created by y.uchida on 13/02/27.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "AnimActionNumCounterLabelTTF.h"

@implementation AnimActionNumCounterLabelTTF

@synthesize countNum	= m_count;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		m_num	= 0;
		m_count	= 0;
		m_addNum	= 0;
		m_time	= 0.f;
		m_oldNum	= 0;
		mp_format	= @"%d";

		[self scheduleUpdate];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	mp_format	= nil;
	[super dealloc];
}

/*
	@brief
*/
-(void)	update:(ccTime)delta
{
	if( m_num != m_count )
	{
		m_time += delta;
		Float32	inp	= MIN(m_time, 1.f);
		m_num = m_oldNum + (inp * m_addNum);
		[super setString:[NSString stringWithFormat:mp_format, m_num]];
	}
}

/*
	@brief	表示フォーマット
*/
-(void)	setStringFormat:(NSString*)in_pFormat
{
	mp_format	= [in_pFormat retain];
}

/*
	@brief	カウント目標値設定
*/
-(void)	setCountNum:(SInt32)in_num
{
	if( m_num != m_count )
	{
		//	前のがアニメしているなら上書き
		[self setNum:m_count];
	}
	
	m_count	= in_num;
	if( m_num != m_count )
	{
		//	カウントアニメ開始
		m_oldNum	= m_num;
		m_addNum	= (m_count - m_num);// > 0 ? 1 : -1;
		m_time	= 0;
	}
}

/*
	@brief	カウントせずに即反映
*/
-(void)	setNum:(SInt32)in_num
{
	m_count	= in_num;
	m_num	= in_num;
	
	[super setString:[NSString stringWithFormat:mp_format, m_num]];
}

@end
