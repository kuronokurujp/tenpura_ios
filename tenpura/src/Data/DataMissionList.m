//
//  DataMissionList.m
//  tenpura
//
//  Created by y.uchida on 12/11/29.
//
//

#import "DataMissionList.h"
#import "DataBaseText.h"
#import "DataNetaList.h"
#import "DataNetaPackList.h"
#import "DataSaveGame.h"

struct	MISSION_DATA_ST
{
	UInt32	no;
	UInt32	missionId;
	char	aNameTextField[128];
	char	aGetTextField[128];
	//	ミッションの種類ごとに異なるデータ
	union
	{
		char	data[32];
		struct
		{
			SInt32	no;
			UInt32	num;
			UInt32	bonusMoney;
		} itemuGet;
		
		struct
		{
			int64_t	score;
		//	char	rank;
			SInt32	bounusMoney;
		} hiscore;
		
	} customData;
};

@interface DataMissionList (PriveteMethod)

-(const struct MISSION_DATA_ST*)_getData:(UInt32)in_idx;
-(BOOL)	_parse:(struct MISSION_DATA_ST*)out_pData :(NSArray*)in_dataArray;
-(SInt32)	_getNetaTextToNo:(const char*)in_pStr;
-(UInt32)	_getMissionNoToSaveDataMissionIdx:(UInt32)in_no;

@end

@implementation DataMissionList

static DataMissionList*	sp_MissionListInst	= nil;

//	ミッションタイプ
enum
{
	eMISSION_TYPE_ID_GET_ITEM	= 1,
	eMISSION_TYPE_ID_HISCORE,
};

@synthesize dataNum	= m_dataNum;

/*
	@brief
	@return
*/
+(DataMissionList*)	shared
{
	if( sp_MissionListInst == nil )
	{
		sp_MissionListInst	= [[DataMissionList alloc] init];
	}
	
	return sp_MissionListInst;
}

/*
	@brief
*/
+(void)	end
{
	if( sp_MissionListInst != nil )
	{
		[sp_MissionListInst release];
		sp_MissionListInst	= nil;
	}
}

+(id)alloc
{
	NSAssert(sp_MissionListInst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"missionListData" ofType:@"csv"];

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pItems	= nil;

		m_dataNum	= [pLines count];
		NSAssert(0 < m_dataNum, @"データが一つもない。");
		mp_dataList	= (struct MISSION_DATA_ST*)malloc(m_dataNum * sizeof(struct MISSION_DATA_ST));
		
		UInt32	dataIdx	= 0;
		for( SInt32 i = 0; i < m_dataNum; ++i, ++dataIdx )
		{
			pObj	= [pLines objectAtIndex:i];
			pItems	= [pObj componentsSeparatedByString:@","];
			//	解析
			if( [self _parse:&mp_dataList[ dataIdx ]:pItems] == NO )
			{
				//	失敗
				--dataIdx;
			}
		}
		
		m_dataNum	= dataIdx;
		
		[pLines release];
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	free(mp_dataList);
	mp_dataList	= nil;

	[super dealloc];
}

/*
	@brief	ミッション名取得
*/
-(NSString*)	getMissonName:(UInt32)in_idx
{
	const struct MISSION_DATA_ST*	pData	= [self _getData:in_idx];
	if( pData != nil )
	{
		return	[NSString stringWithUTF8String:pData->aNameTextField];
	}
	
	return nil;
}

/*
	@brief	ミッション成功時のメッセージ取得
*/
-(NSString*)	getSuccessMsg:(UInt32)in_idx
{
	const struct MISSION_DATA_ST*	pData	= [self _getData:in_idx];
	if( pData != nil )
	{
		return	[NSString stringWithUTF8String:pData->aGetTextField];
	}
	
	return nil;
}

/*
	@brief	ミッション成功かどうかフラグ設定
*/
-(void)	setSuccess:(BOOL)in_flg :(UInt32)in_idx
{
	if( in_idx < m_dataNum )
	{
		[[DataSaveGame shared] saveMissionFlg:in_flg:[self _getMissionNoToSaveDataMissionIdx:mp_dataList[in_idx].no]];
	}
}

/*
	@brief	ミッションが成功しているかのフラグ取得
*/
-(BOOL)	isSuccess:(UInt32)in_idx
{
	const struct MISSION_DATA_ST*	pData	= [self _getData:in_idx];
	if( pData != nil )
	{
		DataSaveGame*	pSaveDataInst	= [DataSaveGame shared];
		NSAssert(pSaveDataInst, @"セーブデータがない");
	
		const SAVE_DATA_ST*	pSaveData	= [pSaveDataInst getData];
		return pSaveData->aMissionFlg[[self _getMissionNoToSaveDataMissionIdx:pData->no]];
	}

	return NO;
}

/*
	@brief	ミッション成功しているかとうかのチェック
*/
-(BOOL)	checSuccess:(UInt32)in_idx
{
	DataSaveGame*	pSaveDataInst	= [DataSaveGame shared];
	NSAssert(pSaveDataInst, @"セーブデータがない");
	
	const SAVE_DATA_ST*	pSaveData	= [pSaveDataInst getData];

	const struct MISSION_DATA_ST*	pData	= [self _getData:in_idx];
	//	すでに成功しているのは除外する
	if( (pData != nil) && (pSaveData->aMissionFlg[[self _getMissionNoToSaveDataMissionIdx:pData->no]] == NO) )
	{
		switch (pData->missionId)
		{
			case eMISSION_TYPE_ID_GET_ITEM:
			{
				UInt32	netaGetCnt	= 0;

				DataNetaPackList*	pDataNetaPackInst	= [DataNetaPackList shared];
				for( SInt32 i = 0; i < eSAVE_DATA_NETA_PACKS_MAX; ++i )
				{
					const	SAVE_DATA_NETA_ST*	pItem	= [pSaveDataInst getNetaPackOfIndex:i];
					if( pItem != NULL )
					{
						const NETA_PACK_DATA_ST*	pNetaPackData	= [pDataNetaPackInst getDataSearchId:pItem->no];
						if( pNetaPackData != NULL )
						{
							for( SInt32 j = 0; j < eNETA_PACK_MAX; ++j )
							{
								if( pNetaPackData->aNetaId[j] == pData->customData.itemuGet.no )
								{
									++netaGetCnt;
								}
							}
						}
					}
				}

				if( (pData->customData.itemuGet.num <= netaGetCnt) )
				{
					//	成功
					[pSaveDataInst addSaveMoeny:pData->customData.itemuGet.bonusMoney];
					return YES;
				}
				
				break;
			}
			case eMISSION_TYPE_ID_HISCORE:
			{
				if( pData->customData.hiscore.score <= pSaveData->score )
				{
					//	成功
				//	[pSaveDataInst saveRank:pData->customData.hiscore.rank];
					[pSaveDataInst addSaveMoeny:pData->customData.hiscore.bounusMoney];

					return YES;
				}
				
				break;
			}
			default:
			{
				NSAssert(0, @"ミッション種類IDが不定");
				break;
			}
		}
	}
	
	return NO;
}

/*
	@brief	データ取得
	@param	データidx
	@return	データ取得
*/
-(const struct MISSION_DATA_ST*)_getData:(UInt32)in_idx
{
	if( in_idx < m_dataNum )
	{
		return &mp_dataList[in_idx];
	}
	
	return nil;
}

/*
	@brief	データ解析
	@param	データ出力/データ設定
	@return	成功=YES / 失敗=NO
*/
-(BOOL)	_parse:(struct MISSION_DATA_ST*)out_pData :(NSArray*)in_dataArray
{
	if( out_pData == nil )
	{
		return NO;
	}

	memset( out_pData, 0, sizeof(struct MISSION_DATA_ST) );

	SInt32	dataIdx	= 0;

	//	no
	out_pData->no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	missionId
	out_pData->missionId	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	名称
	const char*	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	NSString*	pChangeString	= [DataBaseText getStringOfField:pStr];
	if( pChangeString != nil )
	{
		strcpy( out_pData->aNameTextField, [pChangeString UTF8String] );
	}
	else
	{
		strcpy( out_pData->aNameTextField, pStr );
	}
	++dataIdx;

	//	名称の引数１
	UInt32	nameTextFieldParamNum	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	名称引数２
	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	pChangeString	= [DataBaseText getStringOfField:pStr];
	char	aNameTextFieldParamStr[128]	= {'\n'};
	if( pChangeString != nil )
	{
		strcpy( aNameTextFieldParamStr, [pChangeString UTF8String] );
	}
	else
	{
		strcpy( aNameTextFieldParamStr, pStr );
	}
	++dataIdx;

	//	獲得
	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	pChangeString	= [DataBaseText getStringOfField:pStr];
	if( pChangeString != nil )
	{
		strcpy( out_pData->aGetTextField, [pChangeString UTF8String] );
	}
	else
	{
		strcpy( out_pData->aGetTextField, pStr );
	}
	++dataIdx;
	
	//	獲得の引数
	UInt32	getTextFieldParamNum	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	ミッション項目内容文字列変換
	{
		NSString*	pText	= nil;
		switch (out_pData->missionId)
		{
			case eMISSION_TYPE_ID_GET_ITEM:
			{
				pText	= [NSString stringWithUTF8String:out_pData->aNameTextField];
				pText	= [NSString stringWithFormat:pText, [NSString stringWithUTF8String:aNameTextFieldParamStr], nameTextFieldParamNum];
				strcpy( out_pData->aNameTextField, [pText UTF8String]);

				pText	= [NSString stringWithUTF8String:out_pData->aGetTextField];
				pText	= [NSString stringWithFormat:pText, getTextFieldParamNum];
				strcpy( out_pData->aGetTextField, [pText UTF8String]);

				out_pData->customData.itemuGet.no	= [self _getNetaTextToNo:aNameTextFieldParamStr];
				out_pData->customData.itemuGet.num	= nameTextFieldParamNum;
				out_pData->customData.itemuGet.bonusMoney	= getTextFieldParamNum;

				break;
			}
			case eMISSION_TYPE_ID_HISCORE:
			{
				pText	= [NSString stringWithUTF8String:out_pData->aNameTextField];
				pText	= [NSString stringWithFormat:pText, nameTextFieldParamNum];
				strcpy( out_pData->aNameTextField, [pText UTF8String]);

				pText	= [NSString stringWithUTF8String:out_pData->aGetTextField];
				pText	= [NSString stringWithFormat:pText, getTextFieldParamNum];
				strcpy( out_pData->aGetTextField, [pText UTF8String]);

				out_pData->customData.hiscore.score	= nameTextFieldParamNum;
				out_pData->customData.hiscore.bounusMoney	= (SInt32)getTextFieldParamNum;

				break;
			}
			default:
			{
				NSAssert(0, @"ミッションIDが不定");
				break;
			}
		}
	}

	return YES;
}

/*
	@brief	ネタ名からネタno取得
*/
-(SInt32)	_getNetaTextToNo:(const char*)in_pStr
{
	DataNetaList*	pNetaInst	= [DataNetaList shared];
	NSAssert(pNetaInst, @"ネタデータがない");
	
	NSString*	pCmpStr1	= [NSString stringWithUTF8String:in_pStr];

	const NETA_DATA_ST*	pNetaData	= nil;
	UInt32	netaDataNum	= pNetaInst.dataNum;
	for( UInt32 i = 0; i < netaDataNum; ++i )
	{
		pNetaData	= [pNetaInst getData:i];

		NSString*	pCmpStr2	= [DataBaseText getString:pNetaData->textID];
		if( [pCmpStr1 isEqualToString:pCmpStr2] )
		{
			//	ヒット
			return pNetaData->no;
		}
	}

	return -1;
}

/*
	@brief	ミッションnoからセーブデータに格納するミッションidxに変換
*/
-(UInt32)	_getMissionNoToSaveDataMissionIdx:(UInt32)in_no
{
	SInt32	missionIdx	= in_no - 1;
	NSAssert(0 <= missionIdx, @"セーブデータに格納するミッションidx値が不正(%ld)", missionIdx);
	NSAssert((UInt32)missionIdx < eSAVE_DATA_MISSION_MAX, @"ミッションnoがこれ以上割り振れない(上限は1~%dまで)", eSAVE_DATA_MISSION_MAX);

	return (UInt32)missionIdx;
}

@end
