//
//  UIAlertView+Block.h
//  tenpura
//
//  Created by Yuto Uchida on 2014/05/01.
//
//

#import <UIKit/UIKit.h>

/**
	@brief	UIAlerViewのブロック呼び出し
	@note
		クラス拡張をしたかったのだが、delegateが呼ばれないので継承にした。
*/
@interface UIAlertViewBlock : UIAlertView
<
	UIAlertViewDelegate
>

typedef void (^AlertViewCompletion)(UIAlertView *alertView, NSInteger buttonIndex);
 
-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(AlertViewCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
