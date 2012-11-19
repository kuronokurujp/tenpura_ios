//
//  SampleCell.h
//  SWTableViewSample
//
//  Created by koji on 11/11/05.
//  Copyright 2011 Alpha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWTableViewCell.h"
#import "SWTableViewSpriteCell.h"

//@class SWTableViewCell;
@interface SampleCell : SWTableViewCell {

@private
	//	変数定義
	CGSize	m_size;
}

@property	(nonatomic) CGSize size;

@end
