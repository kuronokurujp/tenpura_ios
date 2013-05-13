//
//  AnimActionNumCounterLabelTTF.m
//  tenpura
//
//  Created by y.uchida on 13/02/27.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "AnimActionNumCounterLabelTTF.h"

@implementation AnimActionNumCounter

@synthesize countNum	= m_count;

/*
	@brief	初期化
*/
-(id)	init
{
	m_num	= 0;
	m_count	= 0;
	m_addNum	= 0;
	m_time	= 0.f;
	m_oldNum	= 0;
	mp_format	= @"%d";

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
-(bool)	update:(ccTime)delta
{
	if( m_num != m_count )
	{
		m_time += delta;
		Float32	inp	= MIN(m_time, 1.f);
		m_num = m_oldNum + (inp * m_addNum);
		
		return YES;
	}
	
	return NO;
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
}

/*
	@brief	文字列取得
*/
-(NSString*)	getText
{
	return [NSString stringWithFormat:mp_format, m_num];
}

@end

@implementation AnimActionNumCounterLabelTTF

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_animCnt	= [AnimActionNumCounter alloc];
		[self scheduleUpdate];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	if( mp_animCnt != nil )
	{
		[mp_animCnt release];
	}

	[super dealloc];
}

/*
	@brief
*/
-(void)	update:(ccTime)delta
{
	if( [mp_animCnt update:delta] == YES )
	{
		[super setString:[mp_animCnt getText]];
	}
}

/*
	@brief	表示フォーマット
*/
-(void)	setStringFormat:(NSString*)in_pFormat
{
	[mp_animCnt setStringFormat:in_pFormat];
}

/*
	@brief	カウント目標値設定
*/
-(void)	setCountNum:(SInt32)in_num
{
	[mp_animCnt setCountNum:in_num];
}

/*
	@brief	カウントせずに即反映
*/
-(void)	setNum:(SInt32)in_num
{
	[mp_animCnt setNum:in_num];
	[super setString:[mp_animCnt getText]];
}

/*
	@brief	カウント値取得
*/
-(SInt32)	getCountNum
{
	return mp_animCnt.countNum;
}

@end

@implementation AnimActionNumCounterLabelBMT

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_animCnt	= [AnimActionNumCounter alloc];
		[self scheduleUpdate];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	if( mp_animCnt != nil )
	{
		[mp_animCnt release];
	}

	[super dealloc];
}

/*
	@brief
*/
-(void)	update:(ccTime)delta
{
	if( [mp_animCnt update:delta] == YES )
	{
		[super setString:[mp_animCnt getText]];
	}
}

/*
	@brief	表示フォーマット
*/
-(void)	setStringFormat:(NSString*)in_pFormat
{
	[mp_animCnt setStringFormat:in_pFormat];
}

/*
	@brief	カウント目標値設定
*/
-(void)	setCountNum:(SInt32)in_num
{
	[mp_animCnt setCountNum:in_num];
}

/*
	@brief	カウントせずに即反映
*/
-(void)	setNum:(SInt32)in_num
{
	[mp_animCnt setNum:in_num];
	[super setString:[mp_animCnt getText]];
}

/*
	@brief	カウント値取得
*/
-(SInt32)	getCountNum
{
	return mp_animCnt.countNum;
}

@end

