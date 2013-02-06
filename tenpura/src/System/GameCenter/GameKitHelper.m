//
//  GameKitHelper.m
//  tenpura
//
//  Created by y.uchida on 12/11/06.
//
//

#import "GameKitHelper.h"
#import "AppDelegate.h"

@interface GameKitHelper (PrivateMethod)

-(void)	registerForLoaclPlayerAuthChange;
-(void)	onLocalPlayerAuthenticationChanged;
-(void)	setLastError:(NSError*)in_pError;
-(void)	retrieveScoresForPlayers:(NSArray*)players category:(NSString*)category range:(NSRange)range
								playerScope:(GKLeaderboardPlayerScope)playerScope
								timeScope:(GKLeaderboardTimeScope)timeScope;
-(void)	dimissModalViewController;
-(GKAchievement*)	getAhievementByID:(NSString*)identifier;
-(void)	loadAchiveements;

@end

@implementation GameKitHelper

static GameKitHelper*	s_pGameKitHelperInst	= nil;

#define IOS_OR_LATER( ver ) \
  (NSOrderedAscending != [[[UIDevice currentDevice] systemVersion] \
    compare:ver options:NSNumericSearch])

@synthesize delegate	= m_delegate;
@synthesize isGameCenterAvaliable	= mb_isGameCenterAvaliable;
@synthesize achievements	= mp_achievements;
@synthesize achievementDescriptions	= mp_achievementDescriptions;

/*
	@brief
*/
+(GameKitHelper*)	shared
{
	if( s_pGameKitHelperInst == nil )
	{
		s_pGameKitHelperInst	= [[GameKitHelper alloc] init];
	}
	
	return s_pGameKitHelperInst;
}

/*
	@brief
*/
+(void)	end
{
	if( s_pGameKitHelperInst != nil )
	{
		[s_pGameKitHelperInst release];
	}
	
	s_pGameKitHelperInst	= nil;
}

/*
	@brief
*/
+(id)	alloc
{
	NSAssert(s_pGameKitHelperInst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		mb_isGameCenterAvaliable	= NO;
		m_delegate	= nil;
		mp_lastError	= nil;
		mp_achievements	= nil;

		//	GameCenterが使えるかチェック
		{
			Class	gameKitLocalPlayerClass	= NSClassFromString(@"GKLocalPlayer");
			BOOL	isLocalPlayerAvailable	= (gameKitLocalPlayerClass != nil);
			
			//	デバイスがiOS4.1以降か
			NSString*	pReqSysVer	= @"4.1";
			NSString*	pCurrSysVer	= [[UIDevice currentDevice] systemVersion];
			BOOL	isOSVer41	= ([pCurrSysVer compare:pReqSysVer options:NSNumericSearch] != NSOrderedAscending);
			
			mb_isGameCenterAvaliable	= (isLocalPlayerAvailable && isOSVer41);
			NSLog(@"GameCenter avaliable = %@", mb_isGameCenterAvaliable ? @"YES" : @"NO" );

			[self registerForLoaclPlayerAuthChange];
		}
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	if( mp_lastError != nil )
	{
		[mp_lastError release];
	}
	mp_lastError	= nil;
	
	if( mp_achievements != nil )
	{
		[mp_achievements release];
	}
	mp_achievements	= nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

/*
	@brief	認証開始
*/
-(void)	authenticateLocalPlayer
{
	if( mb_isGameCenterAvaliable == NO )
	{
		return;
	}
	
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if(IOS_OR_LATER(@"6.0"))
	{
		pLocalPlayer.authenticateHandler	= ^(UIViewController* viewController, NSError* error)
		{
			if( viewController != nil )
			{
				CCLOG(@"viewController");
				AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
				[pApp.navController presentViewController:viewController animated:YES completion:nil];
			}
			else if( pLocalPlayer.isAuthenticated )
			{
				CCLOG(@"authenticated");
				[self loadAchiveements];
			}
			else
			{
				CCLOG(@"dispGameCenter");
			}
		};
	}
	else
	{
		if( pLocalPlayer.authenticated == NO )
		{
			[pLocalPlayer authenticateWithCompletionHandler:
			^(NSError*	pError)
			{
				[self setLastError:pError];
				if( pError == nil )
				{
					[self loadAchiveements];
				}
			}];
		}
	}
}

/*
	@brief	リーダーボードに値設定
*/
-(void)	submitScore:(int64_t)in_score category:(NSString*)in_pCategoryName
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		CCLOG(@"error submitScore");
		return;
	}

	GKScore*	pGKScore	= [[[GKScore alloc] initWithCategory:in_pCategoryName] autorelease];
	pGKScore.value	= in_score;
	
	[pGKScore reportScoreWithCompletionHandler:
	^(NSError* error)
	{
		[self setLastError:error];
		BOOL	bSuccess	= (error != nil);
		if( bSuccess == YES )
		{
			if( m_delegate != nil )
			{
				NSAssert(m_delegate, @"nil delegate");
				if( [m_delegate respondsToSelector:@selector(onScoresSubmitted:) ] )
				{
					[m_delegate onScoresSubmitted:bSuccess];
				}
			}
		}
	}];
}

/*
	@brief	１〜１０までのリーダーボード設定
*/
-(void)	retrieveTopTenAllTimeGlobalScores
{
}

/*
	@brief	リーダーボード更新
*/
-(void)	retrieveScoresForPlayers:(NSArray*)players category:(NSString*)category range:(NSRange)range
								playerScope:(GKLeaderboardPlayerScope)playerScope
								timeScope:(GKLeaderboardTimeScope)timeScope
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		return;
	}

	GKLeaderboard*	pLeaderboard	= nil;
	if( ( players != nil ) && ([players count] > 0 ) )
	{
		pLeaderboard	= [[[GKLeaderboard alloc] initWithPlayerIDs:players] autorelease];
	}
	else
	{
		pLeaderboard	= [[[GKLeaderboard alloc] init] autorelease];
		pLeaderboard.playerScope	= playerScope;
	}
	
	if( pLeaderboard != nil )
	{
		pLeaderboard.timeScope	= timeScope;
		pLeaderboard.category	= category;
		pLeaderboard.range		= range;
		
		[pLeaderboard loadScoresWithCompletionHandler:
		^(NSArray* scores, NSError* error)
		{
			[self setLastError:error];
			if( m_delegate != nil )
			{
				[m_delegate onScoresReceived:scores];
			}
		}];
	}
}

/*
	@brief	アチーブメントのデータ送信
*/
-(void)	reportAchievmentWithID:(NSString*)identifier :(float)percent
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		return;
	}

	GKAchievement*	pAhievment	= [self getAhievementByID:identifier];
	if( ( pAhievment != nil ) && pAhievment.percentComplete < percent )
	{
		pAhievment.percentComplete	= percent;
		[pAhievment reportAchievementWithCompletionHandler:^(NSError* error)
		{
			[self setLastError:error];
			if( ( m_delegate != nil ) && ([self respondsToSelector:@selector(onAchievementReported:)]) )
			{
				CCLOG(@"success achievement");
				[m_delegate onAchievementReported:pAhievment];
			}
		}
		];
	}
}

/*
	@brief	リーダーボード表示
*/
-(void)	showLeaderboard
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		return;
	}
	
	GKLeaderboardViewController*	pLeaderboardVC	= [[[GKLeaderboardViewController alloc] init] autorelease];
	if( pLeaderboardVC != nil )
	{
		pLeaderboardVC.leaderboardDelegate	= self;
		
		AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
		[pApp.navController presentModalViewController:pLeaderboardVC animated:YES];
	}
}

/*
	@brief	ゲームセンター表示
*/
-(void)	showGameCenter
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		return;
	}
	
	GKGameCenterViewController*	pGameViewCtrl	= [[[GKGameCenterViewController alloc] init] autorelease];
	if( pGameViewCtrl != nil )
	{
		pGameViewCtrl.gameCenterDelegate	= self;

		AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
		[pApp.navController presentModalViewController:pGameViewCtrl animated:YES];
	}
}

#ifdef DEBUG

/*
	@brief	アチーブメントのデータリセット
*/
-(void)	resetAchievements
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		return;
	}

	[mp_achievements removeAllObjects];
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		BOOL	bSuccess	= (error == nil);
		if( ( m_delegate != nil ) && ( [self respondsToSelector:@selector(onResetAchievements:)] ) )
		{
			[m_delegate onResetAchievements:bSuccess];
		}
	}];
}

#endif

/*
	@brief
*/
-(void)	registerForLoaclPlayerAuthChange
{
	if( mb_isGameCenterAvaliable == NO )
	{
		return;
	}

	NSNotificationCenter*	pNc	= [NSNotificationCenter defaultCenter];
	[pNc addObserver:self selector:@selector(onLocalPlayerAuthenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

/*
	@brief
*/
-(void)	onLocalPlayerAuthenticationChanged
{
	//	デリゲーダー先を呼ぶ
	if( m_delegate != nil )
	{
		if( [m_delegate respondsToSelector:@selector(onLocalPlayerAuthenticationChanged) ] )
		{
			[m_delegate onLocalPlayerAuthenticationChanged];
		}
	}
}

/*
	@brief
*/
-(void)	setLastError:(NSError*)in_pError
{
	mp_lastError	= in_pError.copy;
	if( mp_lastError != nil )
	{
		NSLog(@"GameKitHelper ERROR: %@", [mp_lastError userInfo].description);
	}
}

/*
	@brief	ビューを閉じる
*/
-(void)	dimissModalViewController
{
	AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
	[pApp.navController dismissModalViewControllerAnimated:YES];
}

/*
	@brief	アチーブメント取得
*/
-(GKAchievement*)	getAhievementByID:(NSString*)identifier
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		return nil;
	}
	
	GKAchievement*	pAchievement	= [mp_achievements objectForKey:identifier];
	if( pAchievement == nil )
	{
		pAchievement	= [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
		[mp_achievements setObject:pAchievement forKey:identifier];
	}

	return [[pAchievement retain] autorelease];
}

/*
	@brief	アチーブメントリスト読み込み
*/
-(void)	loadAchiveements
{
	GKLocalPlayer*	pLocalPlayer	= [GKLocalPlayer localPlayer];
	if( ( mb_isGameCenterAvaliable == NO ) || ( pLocalPlayer.authenticated == NO ) )
	{
		return;
	}
	
	[GKAchievement loadAchievementsWithCompletionHandler:
	^(NSArray* loadedAchievements, NSError* error)
	{
		[self setLastError:error];
		if( error == nil )
		{
			if( mp_achievements == nil )
			{
				mp_achievements	= [[NSMutableDictionary alloc] init];
			}
			else
			{
				[mp_achievements removeAllObjects];
			}
			
			for( GKAchievement* pAchievement in loadedAchievements )
			{
				[mp_achievements setObject:pAchievement forKey:pAchievement.identifier];
			}
			
			if( (m_delegate != nil ) && ([self respondsToSelector:@selector(onAchievementsLoaded:)]) )
			{
				[m_delegate onAchievementsLoaded:mp_achievements];
			}
		}
	}];
	
	[GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:
	^(NSArray* loadedAchievementDescriptions, NSError* error)
	{
		[self setLastError:error];
		if( error == nil )
		{
			if( mp_achievementDescriptions == nil )
			{
				mp_achievementDescriptions	= [[NSMutableDictionary alloc] init];
			}
			else
			{
				[mp_achievementDescriptions removeAllObjects];
			}
			
			for( GKAchievementDescription* pAchievementDescription in loadedAchievementDescriptions )
			{
				[mp_achievementDescriptions setObject:pAchievementDescription forKey:pAchievementDescription.identifier];
			}
			
			if( (m_delegate != nil ) && ([self respondsToSelector:@selector(onAchievementDescription:)]) )
			{
				[m_delegate onAchievementDescription:mp_achievementDescriptions];
			}
		}
	}];
}

/*
	@brief	ゲームセンターを閉じる
*/
-(void)	gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
	[self dimissModalViewController];
}

/*
	@brief	リーダーボード閉じる
*/
-(void)	leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dimissModalViewController];
	if( m_delegate != nil )
	{
		if( [m_delegate respondsToSelector:@selector(onLeaderboardViewDismissed) ] )
		{
			[m_delegate onLeaderboardViewDismissed];
		}
	}
}

/*
	@brief	アチーブメントを閉じる
*/
-(void)	achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[self dimissModalViewController];
}

@end
