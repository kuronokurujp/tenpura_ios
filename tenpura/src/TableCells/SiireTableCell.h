//
//  SiireTableCell.h
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "./../Object/TenpuraIcon.h"
#import "./../Data/DataNetaPackList.h"

@interface SiireTableCell : CCSprite {

@private
	CCLabelBMFont*	mp_nameLabel;
	CCLabelBMFont*	mp_moneyLabel;
	CCLabelBMFont*	mp_unknowLabel;
	CCLabelBMFont*	mpa_netaNameList[eNETA_PACK_MAX];
	TenpuraIcon*	mpa_tenpuraIcon[eNETA_PACK_MAX];
	CCSprite*	mp_soldOutSprite;
}

@property	(nonatomic, retain)CCLabelBMFont*	pNameLabel;
@property	(nonatomic, retain)CCLabelBMFont*	pMoneyLabel;
@property	(nonatomic, retain)CCLabelBMFont*	pUnknowLabel;

-(CCLabelBMFont*)	getNetaNameLabel:(SInt32)in_idx;
-(TenpuraIcon*)	getNetaIconObj:(SInt32)in_idx;
-(void)	setEnableSoldOut:(BOOL)in_bFlg;


@end
