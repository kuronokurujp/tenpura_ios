//
//  UIAlertView+Block.m
//  tenpura
//
//  Created by Yuto Uchida on 2014/05/01.
//
//
#import "UIAlertView+Block.h"
#import <objc/runtime.h>  
#define KEY_ALERTVIEW_BLOCK @"KEY_ALERTVIEW_BLOCK"

@implementation UIAlertViewBlock

-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(AlertViewCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self	= [self initWithTitle:title
					message:message
					delegate:self
					cancelButtonTitle:cancelButtonTitle
					otherButtonTitles:nil];

    if( self ) {
		if( otherButtonTitles != nil ) {
			va_list args	= nil;
			va_start(args, otherButtonTitles);
			for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
				[self addButtonWithTitle:arg];
			}
			va_end(args);
		}
		
        objc_setAssociatedObject(self,
                                 KEY_ALERTVIEW_BLOCK,
                                 [completion copy],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
	
	return self;
}

-(void)	alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AlertViewCompletion completion = objc_getAssociatedObject(self,
                                                              KEY_ALERTVIEW_BLOCK);
    if (completion) {
        completion(self, buttonIndex);
    }
}
 
-(void) dealloc
{
    objc_removeAssociatedObjects(self);
	[super dealloc];
}

@end
