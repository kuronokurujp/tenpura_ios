//
//  GameKitHelper.h
//  tenpura
//
//  Created by y.uchida on 12/11/06.
//
//

#import <Foundation/Foundation.h>

@protocol GameKitHelperProtocol<NSObject>

//	接続成功
-(void)	onLocalPlayerAuthenticationChanged;
//	スコア送信成功
-(void)	onScoresSubmitted:(BOOL)in_bSuccess;
//	スコア更新
-(void)	onScoresReceived:(NSArray*)in_pScores;
//	リーダーボード閉じる
-(void)	onLeaderboardViewDismissed;
//	アチーブメントデータ送信
-(void)	onAchievementReported:(GKAchievement*)achievement;
//	アチーブメントリスト読み込み完了
-(void)	onAchievementsLoaded:(NSMutableDictionary*)achievements;
//	アチーブメント詳細読み込み完了
-(void)	onAchievementDescription:(NSMutableDictionary*)achievementDescriptions;

#ifdef DEBUG
//	アチーブメントリストリセット
-(void)	onResetAchievements:(BOOL)in_bSuccess;
#endif
@end

/*
	@brief	ゲームセンター制御ヘルパー
*/
@interface GameKitHelper : NSObject<
	GKLeaderboardViewControllerDelegate,
	GKGameCenterControllerDelegate,
	GKAchievementViewControllerDelegate>
{
@private
	id<GameKitHelperProtocol>	m_delegate;
	BOOL	mb_isGameCenterAvaliable;
	NSError*	mp_lastError;
	NSMutableDictionary*	mp_achievements;
	NSMutableDictionary*	mp_achievementDescriptions;
}

//	プロパティ
@property	(nonatomic, retain)	id<GameKitHelperProtocol>	delegate;
@property	(nonatomic, readonly)	BOOL	isGameCenterAvaliable;
@property	(nonatomic, retain)	NSMutableDictionary*	achievements;
@property	(nonatomic, retain)	NSMutableDictionary*	achievementDescriptions;

//	関数
+(GameKitHelper*)	shared;
+(void)	end;

//	接続開始
-(void)	authenticateLocalPlayer;
//	リーダーボードに値設定
-(void)	submitScore:(int64_t)in_score category:(NSString*)in_pCategoryName;
//	リーダーボードの１〜１０までのスコア取得送信
-(void)	retrieveTopTenAllTimeGlobalScores;
//	アチーブメントのデータ送信
-(void)	reportAchievmentWithID:(NSString*)identifier :(float)percent;

//	リーダーボード表示
-(void)	showLeaderboard;
//	ゲームセンター表示
-(void)	showGameCenter;

#ifdef DEBUG
//	アチーブメントのデータリセット
-(void)	resetAchievements;
#endif


@end
