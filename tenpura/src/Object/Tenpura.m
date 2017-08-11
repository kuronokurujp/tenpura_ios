//
//  Tenpura.m
//  tenpura
//
//  Created by y.uchida on 12/09/22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tenpura.h"

#import "./../Data/DataTenpuraPosList.h"
#import "./../Data/DataGlobal.h"
#import "./../Object/Customer.h"
#import	"./../System/Anim/AnimManager.h"
#import "./../System/Sound/SoundManager.h"
#import "./../System/Common.h"

@interface Tenpura (PrivateMethod)

-(void)		_setup:(const NETA_DATA_ST*)in_pData;
-(CGRect)	_getTexRect:(SInt32)in_idx;

-(void)	_settingEffect:(TENPURA_STATE_ET)in_state;

//	消滅演出終了
-(void)	_endEatAction;

//	揚げる時間を取得
-(Float32)	_getRaiseTime:(TENPURA_STATE_ET)in_state;

@end

@implementation Tenpura

static const float	s_normalScaleVal	= 3.f / 4.f;

enum
{
	eACTTAG_LOCK_SCALE	= 1,
	eCHILD_TAG_ANIM_ABURA,
	eCHILD_TAG_ANIM_CURSOR,
	eCHILD_TAG_ANIM_STAR,
};

//	プロパティ定義
@synthesize posDataIdx	= m_posDataIdx;
@synthesize data		= m_data;
@synthesize delegate	= m_delegate;
@synthesize bNonBurn    = mb_nonBurn;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		memset( &m_data, 0, sizeof(m_data) );
		mp_sp			= nil;
		m_delegate		= nil;
		mb_lock		= NO;
		mb_fly		= NO;
		mb_fever	= NO;
        mb_nonBurn  = NO;
		m_posDataIdx	= -1;
		m_raiseTimeRate	= 1.f;
		m_baseTimeRate	= 1.f;
		m_nowRaiseTime	= 0.f;

		m_state			= eTENPURA_STATE_VERYBAD;
		AnimManager*	pAnimManager	= [AnimManager shared];

		CCNode*	pEff	= nil;
		pEff	= [pAnimManager createNode:[NSString stringWithUTF8String:ga_animDataList[eANIM_ABURA].pImageFileName] :YES];
		[pEff setVisible:NO];
		[self addChild:pEff z:0 tag:eCHILD_TAG_ANIM_ABURA];
		
		pEff	= [pAnimManager createNode:[NSString stringWithUTF8String:ga_animDataList[eANIM_STAR].pImageFileName] :YES];
		[pEff setVisible:NO];
		[self addChild:pEff z:2.f tag:eCHILD_TAG_ANIM_STAR];
		
		pEff	= [pAnimManager createNode:[NSString stringWithUTF8String:ga_animDataList[eANIM_CURSOR].pImageFileName] :YES];
		[pEff setVisible:NO];
		[self addChild:pEff z:1.f tag:eCHILD_TAG_ANIM_CURSOR];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	mp_sp	= nil;
	[super dealloc];
}

/*
	@brief
*/
-(void)	update:(ccTime)delta
{
	if( [self isFly] && (mb_fever == NO) )
	{
		Float32	nextRaiseTime	= [self _getRaiseTime:m_state];
		if( 0.f <= nextRaiseTime )
		{
			m_nowRaiseTime	+= delta;
			if( nextRaiseTime <= m_nowRaiseTime )
			{
				m_nowRaiseTime	= 0.f;

				++m_state;
				[self setState:m_state];
			}
		}
	}

	//	ロック中であればタッチによる移動処理をする。
	{
		if( mb_lock == YES ) {
			//	タッチ中かどうか
			
		}
	}
	
	{
		CCNode*	pAnimCursor	= [self getChildByTag:eCHILD_TAG_ANIM_CURSOR];
		CCNode*	pAnimStar	= [self getChildByTag:eCHILD_TAG_ANIM_STAR];
		if( pAnimCursor )
		{
			[pAnimCursor setScale:mp_sp.scale];
		}
		
		if( pAnimStar )
		{
			[pAnimStar setScale:mp_sp.scale];
		}
	}
}

/*
	@brief	セットアップ
*/
-(void)	setupToPosIndex:(const NETA_DATA_ST*)in_pData :(const SInt32)in_posDataIdx :(Float32)in_raiseSpeedRate
{
	[self _setup:in_pData];
	
	//	座標設定
	{
		DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
		TENPURA_POS_ST	tenpuraPosData	= [pDataTenpuraPosList getData:in_posDataIdx];
		[self setPosition:ccp(tenpuraPosData.x, tenpuraPosData.y)];
		
		m_posDataIdx	= in_posDataIdx;
	}
	m_baseTimeRate	= in_raiseSpeedRate;
}

/*
	@brief
*/
-(void)	setupToPos:(const NETA_DATA_ST*)in_pData :(const CGPoint)in_pos :(Float32)in_raiseSpeedRate
{
	[self _setup:in_pData];

	[self setPosition:in_pos];
	
	m_raiseTimeRate	= in_raiseSpeedRate;
}

/*
	@brief	揚げる開始
*/
-(void)	start
{
	//	揚げる段階を設定
	[self reset];
	
	//	配置演出
	{
		[mp_sp setScale:1.2f];
		[mp_sp setOpacity:0];

		Float32	time	= 0.1f;
		CCScaleTo*	pScaleBy	= [CCScaleTo actionWithDuration:time scale:s_normalScaleVal];
		CCFadeIn*	pFadeIn		= [CCFadeIn actionWithDuration:time];
		CCCallBlock*	pEndCall	= [CCCallBlock actionWithBlock:^(void){
			mb_lock	= NO;
			
			//	油アニメ
			AnimActionSprite*	pAburaAnim	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_ABURA];
			[pAburaAnim startLoop:NO];
			[pAburaAnim setVisible:YES];
			[pAburaAnim setScale:1.5f];
			[pAburaAnim setOpacity:255 * 0.8f];
		}];
	
		CCSequence*	pSeq		= [CCSequence actionOne:pScaleBy two:pEndCall];
		
		[mp_sp runAction:pSeq];
		[mp_sp runAction:pFadeIn];
	}

	[self _settingEffect:m_state];
	
	[self setVisible:YES];
	mb_fly	= YES;
}

/*
	@brief
*/
-(void)	end
{
	[mp_sp setScale:s_normalScaleVal];

	//	使用した座標データを未使用状態に
	if( m_posDataIdx != -1 )
	{
		DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
		[pDataTenpuraPosList setUseFlg:NO :m_posDataIdx];
	}

	mb_fly			= NO;
	mb_lock			= NO;
	m_posDataIdx	= -1;
	m_nowRaiseTime	= 0.f;

	AnimActionSprite*	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_CURSOR];
	[pEff end];

	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_STAR];
	[pEff end];

	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_ABURA];
	[pEff end];

	[self stopAllActions];
	[self unscheduleAllSelectors];
	[self setVisible:NO];
}

/*
	@brief	リセット
*/
-(void)	reset
{
	mb_lock	= NO;
	m_nowRaiseTime	= 0.f;
	m_state		= eTENPURA_STATE_VERYGOOD;
	[mp_sp setScale:s_normalScaleVal];
	
	//	揚げる段階を設定
	[self unscheduleUpdate];
	[self scheduleUpdate];

	AnimActionSprite*	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_CURSOR];
	[pEff end];
	[pEff setVisible:NO];

	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_STAR];
	[pEff end];
	[pEff setVisible:NO];

	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_ABURA];
	[pEff end];
	[pEff setVisible:NO];

	[mp_sp setTextureRect:[self _getTexRect:(SInt32)m_state]];
}

/*
	@brief	タッチ可能か
*/
-(BOOL)	isTouchOK
{
	return (mb_lock == NO) && (mb_fly == YES);
}

/*
	@brief	揚げている途中か
*/
-(BOOL)	isFly
{
	return (mb_fly && (mb_lock == NO));
}

/*
	@brief	使用中か
*/
-(BOOL)	isUse
{
	return mb_fly;
}

/*
	@brief	食べるアクション
*/
-(void)	eatAction:(Float32)in_time
{
	NSAssert(mb_fly == YES, @"天ぷらをあげていない");
	NSAssert( (_parent != nil ) && ([_parent isKindOfClass:[Customer class]] == YES), @"このアクションは客が親でないとだめ");

	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
	[pDataTenpuraPosList setUseFlg:NO :m_posDataIdx];
	m_posDataIdx	= -1;

	AnimActionSprite*	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_ABURA];
	[pEff end];
	[pEff setVisible:NO];

	mb_lock	= YES;
	[mp_sp setScale:0.5f];
	
	CCScaleTo*	pScale	= [CCScaleTo actionWithDuration:in_time scale:0.1];
	CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(_endEatAction)];
	CCSequence*	pSeq	= [CCSequence actions:pScale, pEndCall, nil];
	[mp_sp runAction:pSeq];
}

/*
	@brief
*/
-(void)	setPosOfIndex:(const UInt32)in_posDataIdx
{
	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
	TENPURA_POS_ST	tenpuraPosData	= [pDataTenpuraPosList getData:in_posDataIdx];
	[self setPosition:ccp(tenpuraPosData.x, tenpuraPosData.y)];
		
	m_posDataIdx	= in_posDataIdx;
}

/*
	@brief	揚げる速度変更;
*/
-(void)	setRaiseTimeRate:(Float32)in_rate
{
	m_raiseTimeRate	= in_rate;
}

/*
	@brief	フィーバー設定
*/
-(void)	setEnableFever:(const BOOL)in_bFlg
{
	if( in_bFlg == YES )
	{
		[self setState:eTENPURA_STATE_VERYGOOD];
        //  再配置状態中で非表示状態かも知れないので表示設定をする
        [self setVisible:YES];
	}
	
	mb_fever	= in_bFlg;
}

/*
	@brief	タッチロック
*/
-(void)	lockTouch {
	CCScaleBy*	pScaleBy	= [CCScaleBy actionWithDuration:0.1f scale:1.5f];
	[pScaleBy setTag:eACTTAG_LOCK_SCALE];

	[mp_sp setScale:s_normalScaleVal];
	[mp_sp runAction:pScaleBy];
	
	m_oldZOrder	= self.zOrder;
	[self setZOrder:30];
	
	//	油アニメをやめる
	AnimActionSprite*	pAburaAnim	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_ABURA];
	[pAburaAnim end];
	[pAburaAnim setVisible:NO];

	mb_lock	= YES;
	m_touchPrevPos	= self.position;
}

/*
	@brief
*/
-(void)	unLockTouch
{
	[mp_sp setScale:s_normalScaleVal];
    
	//	ロック用のスケールが残っていたら削除する
	if( [mp_sp getActionByTag:eACTTAG_LOCK_SCALE] )
	{
		[mp_sp stopActionByTag:eACTTAG_LOCK_SCALE];
	}
    
	[self setZOrder:m_oldZOrder];
	
	mb_lock	= NO;
}

-(void)	unLockTouchByPos:(const CGPoint)in_pos
{
    [self unLockTouch];
	
	//	油アニメを再開
	AnimActionSprite*	pAburaAnim	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_ABURA];
	[pAburaAnim startLoop:NO];
	[pAburaAnim setVisible:YES];
	
	[self setPosition:in_pos];
}

/*
	@brief	タッチのアンロック（アクション用）
*/
-(void)	unLockTouchByAct
{
	[mp_sp setScale:s_normalScaleVal];
	[self setZOrder:m_oldZOrder];	

	//	ロック用のスケールが残っていたら削除する
	if( [mp_sp getActionByTag:eACTTAG_LOCK_SCALE] )
	{
		[mp_sp stopActionByTag:eACTTAG_LOCK_SCALE];
	}

	CCMoveTo*	pMoveAct	= [CCMoveTo actionWithDuration:0.1f position:m_touchPrevPos];
	CCEaseIn*	pEaseInMoveAct	= [CCEaseOut actionWithAction:pMoveAct rate:2.f];

	CCCallBlock*	pEndAct	= [CCCallBlock actionWithBlock:^{
		[self unLockTouchByPos:m_touchPrevPos];
	}];

	CCSequence*	pSeq	= [CCSequence actionOne:pEaseInMoveAct two:pEndAct];
	[self runAction:pSeq];
}

/*
	@brief	オブジェクト矩形取得
*/
-(CGRect)	boundingBox
{
	CGSize	texSize	= [mp_sp textureRect].size;
	//	左下の点を開始点に
	CGPoint	pos	= ccp(	self.position.x - mp_sp.anchorPoint.x * texSize.width,
						self.position.y - mp_sp.anchorPoint.y * texSize.height);
    /*
    pos = converPosVariableDevice(pos);
    */
	CGRect	boxRect	= CGRectMake(pos.x, pos.y, texSize.width, texSize.height);
	
	return boxRect;
}

-(CGRect)   boundingBoxByTouch
{
	CGSize	texSize	= [mp_sp textureRect].size;
    texSize = converSizeVariableDevice(texSize);

    CGPoint convertPos = self.position;
    {
        CGSize  size    = CGSizeMake(1, 1);
        size    = converSizeVariableDevice(size);
        convertPos  = ccp(size.width * convertPos.x, size.height * convertPos.y);
    }

	//	左下の点を開始点に
	CGPoint	pos	= ccp(	convertPos.x - mp_sp.anchorPoint.x * texSize.width,
                      convertPos.y - mp_sp.anchorPoint.y * texSize.height);

	CGRect	boxRect	= CGRectMake(pos.x, pos.y, texSize.width, texSize.height);
	
	return boxRect;    
}

/*
	@brief	ポーズ
*/
-(void)	pauseSchedulerAndActions
{
	[super pauseSchedulerAndActions];
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		[pNode pauseSchedulerAndActions];
	}
}

/*
	@brief	再開
*/
-(void)	resumeSchedulerAndActions
{
	[super resumeSchedulerAndActions];
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		[pNode resumeSchedulerAndActions];
	}
}

/*
	@brief
*/
-(CGRect)	_getTexRect:(SInt32)in_idx
{
	return CGRectMake(0, m_texSize.height * in_idx, m_texSize.width, m_texSize.height);
}

/*
	@brief	エフェクト設定
*/
-(void)	_settingEffect:(TENPURA_STATE_ET)in_state
{
	AnimActionSprite*	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_CURSOR];
	[pEff end];
	[pEff setVisible:NO];
		
	pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_STAR];
	[pEff end];
	[pEff setVisible:NO];

	switch ((SInt32)in_state)
	{
		case eTENPURA_STATE_VERYGOOD:	//	最高
		{
			pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_CURSOR];
			[pEff startLoop:NO];
			[pEff setVisible:YES];

			pEff	= (AnimActionSprite*)[self getChildByTag:eCHILD_TAG_ANIM_STAR];
			[pEff startLoop:NO];
			[pEff setVisible:YES];

			break;
		}
	}
}

/*
	@brief	消滅演出終了
*/
-(void)	_endEatAction
{
	mb_lock	= NO;
	if( m_delegate != nil )
	{
		if( [m_delegate respondsToSelector:@selector(onAddChildTenpura:)] )
		{
			[m_delegate onAddChildTenpura:self];
		}
	}
}

/*
	@brief	状態設定
*/
-(void)	setState:(const TENPURA_STATE_ET)in_eState
{
	NSAssert(in_eState < eTENPURA_STATE_MAX, @"");
    switch ((SInt32)in_eState)
    {
        case eTENPURA_STATE_VERYGOOD:	//	最高
        {
            [[SoundManager shared] playSe:@"fried02"];
            break;
        }
        case eTENPURA_STATE_BAD:		//	焦げ
        {
            [[SoundManager shared] playSe:@"fried03"];
            break;
        }
        case eTENPURA_STATE_VERYBAD:	//	丸焦げ
        {
            [[SoundManager shared] playSe:@"fried04"];
            break;
        }
    }
    
    //	エフェクト設定
    [self _settingEffect:in_eState];

    switch ((SInt32)in_eState)
    {
        case eTENPURA_STATE_VERYGOOD:	//	最高
        case eTENPURA_STATE_BAD:		//	焦げ
        {
            [mp_sp setTextureRect:[self _getTexRect:(SInt32)in_eState]];
            break;
        }
        case eTENPURA_STATE_VERYBAD:		//	丸焦げ
        {
            [mp_sp setTextureRect:[self _getTexRect:(SInt32)in_eState]];
            
            break;
        }
        case eTENPURA_STATE_EXP:	//	爆発
        {
            if( m_delegate != nil )
            {
                if( [m_delegate respondsToSelector:@selector(onExpTenpura:)] )
                {
                    [m_delegate onExpTenpura:self];
                }
            }
            
            [self setVisible:NO];
            
            break;
        }
        case eTENPURA_STATE_RESTART:
        {
            //	再配置可能
            [self setVisible:NO];
            break;
        }
    }

    m_state = in_eState;
}

/*
	@brief
*/
-(void)		_setup:(const NETA_DATA_ST*)in_pData
{
	NSAssert(in_pData, @"");
	[super setup:in_pData];
	
	mb_lock		= NO;
	mb_fly	= NO;

	m_data	= *in_pData;
}

/*
	@brief	揚げる時間を取得
*/
-(Float32)	_getRaiseTime:(TENPURA_STATE_ET)in_state
{
	Float32	raiseSpeedRate	= (m_baseTimeRate * m_raiseTimeRate);
	Float32	time	= -1.f;
	switch ((SInt32)m_state)
	{
		case eTENPURA_STATE_VERYGOOD:	//	最高
        {
            if( mb_nonBurn == YES )
            {
                //  こげないようにするこれ以上進めないようにする
                return -1;
            }
        }
		case eTENPURA_STATE_BAD:		//	焦げ
		{
			time	= (m_data.aStatusList[m_state].changeTime * raiseSpeedRate);
			break;
		}
		case eTENPURA_STATE_VERYBAD:		//	丸焦げ
		{
			time	= 1.f * raiseSpeedRate;
			break;
		}
		case eTENPURA_STATE_EXP:	//	爆発
		{
			time	= 1.f;
			break;
		}
	}
	
	return time;
}

#ifdef DEBUG
-(void)	draw
{
	[super draw];

	ccDrawColor4B(255, 0, 255, 255);
	CGPoint	p1,p2,p3,p4;
	
	CGRect	rect	= [self boundingBox];
	//	オブジェクト描画位置が原点になるので原点値を引く
	rect.origin.x	= rect.origin.x - self.position.x;
	rect.origin.y	= rect.origin.y - self.position.y;

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
