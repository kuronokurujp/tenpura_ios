//
//  ActionCustomerBase.h
//  tenpura
//
//  Created by y.uchida on 12/12/01.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//	前方宣言
@class Customer;

@interface ActionCustomerBase : CCNode
{
@protected
	Customer*	mp_onwer;
}

//	関数定義
-(void)	initialize:(Customer*)in_pOnwer;
-(void)	finalize;

@end
