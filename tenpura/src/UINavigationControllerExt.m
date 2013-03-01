//
//  UINavigationControllerExt.m
//  tenpura
//
//  Created by y.uchida on 12/11/07.
//
//

#import "UINavigationControllerExt.h"
#import <objc/runtime.h>

//	iOS4のみに実装されている機能の実装
@implementation UIViewController (iOS4Compatible)

+(void)	iOS4compatibilize
{
	Method	ml	= class_getClassMethod(	self.class,
										@selector(iOS4_presentViewController:animated:completion:));
	class_addMethod(	self.class,
						@selector(presentViewController:animated:completion:),
						method_getImplementation(ml),
						method_getTypeEncoding(ml));

}

-(void)	iOS4_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
	NSLog(@"calle iOS4 only system");
	[self presentModalViewController:viewControllerToPresent animated:flag];
	[self performSelector:@selector(callBlock:) withObject:completion afterDelay:(flag) ? 0.5f : 0.f];
}

-(void)	callBlock:(void (^)(void))block
{
	if( block )
	{
		block();
	}
}

@end

@implementation UINavigationControllerExt

-(NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	return UIInterfaceOrientationMaskLandscape;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
