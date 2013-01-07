//
//  FileTexLoadManager.h
//  tenpura
//
//  Created by y.uchida on 13/01/07.
//
//

#import <Foundation/Foundation.h>

@interface FileTexLoadManager : NSObject

+(FileTexLoadManager*)	shared;
+(void)	end;

//	ファイル非同期読み込み
-(void)	LoadAsync:(NSString*)in_pFileName;

@end
