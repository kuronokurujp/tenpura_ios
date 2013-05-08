//
//  ActionCustomer.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "../Data/DataNetaList.h"

@class Customer;
@class Tenpura;
@class TenpuraIcon;

/*
	@brief	客のアクション制御
*/
@interface ActionCustomer : CCNode
{
	Customer*	mp_customer;
	CCLabelTTF*	mp_scoreLabel;
	CCLabelTTF*	mp_moneyLabel;
	CCSprite*	mp_moneyIcon;
	
	CGPoint	m_scoreLabelPos;
	CGPoint	m_moneyLabelPos;
	
	SInt32	m_getScore;
	SInt32	m_getMoeny;
	
	BOOL	mb_flash;
}

//	初期化
-(id)	initWithCusomer:(Customer*)in_pCustomer;

//	出現アクション(食べる時)
-(void)	putEat;
//	出現アクション(リザルト時)
-(void)	putResult;
//	出現アクション中
-(BOOL)	isRunPutAct;

//	退場アクション
-(void)	exit;

//	点滅アクション
-(void)	loopFlash;
-(void)	endFlash;

//	リザルトスコア表示アクション
-(void)	putResultScore;

//	食べた時のアクション
-(void)eatVeryGood:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money;
-(void)eatBat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money;
-(void)eatVeryBat:(Tenpura*)in_pTenpura :(SInt32)in_score :(SInt32)in_money;

//	違う食べ物を与えたときの怒りアクション
-(void)anger:(Tenpura*)in_pTenpura;

-(void)	pauseSchedulerAndActions;
-(void)	resumeSchedulerAndActions;

@end
