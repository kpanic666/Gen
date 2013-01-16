//
//  GameState.m
//  SpaceViking
//
//  Created by Andrey Korikov on 15.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "GameState.h"
#import "GCDatabase.h"

@implementation GameState

static GameState *sharedInstance = nil;

+ (GameState*)sharedInstance
{
    @synchronized([GameState class])
    {
        if (!sharedInstance) {
            sharedInstance = [loadData(@"GameState") retain];
            if (!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil;
}

+ (id)alloc
{
    @synchronized([GameState class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocated a \
                 second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

- (void)save
{
    saveData(self, @"GameState");
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_completedLevel10 forKey:@"CompletedLevel10"];
    [aCoder encodeBool:_completedLevel20 forKey:@"CompletedLevel20"];
    [aCoder encodeBool:_completedLevel30 forKey:@"CompletedLevel30"];
    [aCoder encodeBool:_completedLevel40 forKey:@"CompletedLevel40"];
    [aCoder encodeBool:_completedFirstFail forKey:@"CompletedFirstFail"];
    [aCoder encodeBool:_completedUnwary forKey:@"CompletedUnwary"];
    [aCoder encodeBool:_completedDestroyer forKey:@"CompletedDestroyer"];
    [aCoder encodeBool:_completedLightHunger forKey:@"CompletedLightHunger"];
    [aCoder encodeBool:_completedIFeelGood forKey:@"CompletedIFeelGood"];
    [aCoder encodeBool:_completedOhNoNo forKey:@"CompletedOhNoNo"];
    [aCoder encodeBool:_completedStarry forKey:@"CompletedStarry"];
    [aCoder encodeBool:_completedStarry forKey:@"CompletedStargazer"];
    [aCoder encodeBool:_completedStargazer forKey:@"CompletedSuperstar"];
    [aCoder encodeBool:_completedAwesome forKey:@"CompletedAwesome"];
    [aCoder encodeBool:_completedTrueGenbyFan forKey:@"CompletedTrueGenbyFan"];
    [aCoder encodeBool:_completedMoreFun forKey:@"CompletedMoreFun"];
    [aCoder encodeBool:_completedRushHour forKey:@"CompletedRushHour"];
    [aCoder encodeDouble:_gameTotalRunTime forKey:@"GameTotalRunTime"];
    [aCoder encodeInt:_cellsKilled forKey:@"CellsKilled"];
    [aCoder encodeInt:_foodEaten forKey:@"FoodEaten"];
    [aCoder encodeInt:_bombsExploded forKey:@"BombsExploded"];
    [aCoder encodeInt:_bubblesPoped forKey:@"BubblesPoped"];
    [aCoder encodeInt:_highestOpenedLevel forKey:@"HighestOpenedLevel"];
    [aCoder encodeInt:_totalNumOfReceivedStars forKey:@"TotalNumOfReceivedStars"];
    [aCoder encodeObject:_levelHighestScoreArray forKey:@"LevelHighestScoreArray"];
    [aCoder encodeObject:_levelHighestStarsNumArray forKey:@"LevelHighestStarsNumArray"];
}

- (id)init {
    if ((self = [super init])) {
        _highestOpenedLevel = 1;
        _levelHighestScoreArray = [[NSMutableArray alloc] initWithCapacity:kLevelCount];
        _levelHighestStarsNumArray = [[NSMutableArray alloc] initWithCapacity:kLevelCount];
        for (int i = 0 ; i < kLevelCount ; i++)
        {
            [_levelHighestScoreArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
            [_levelHighestStarsNumArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        [self setCompletedLevel10:[aDecoder decodeBoolForKey:@"CompletedLevel10"]];
        [self setCompletedLevel20:[aDecoder decodeBoolForKey:@"CompletedLevel20"]];
        [self setCompletedLevel30:[aDecoder decodeBoolForKey:@"CompletedLevel30"]];
        [self setCompletedLevel40:[aDecoder decodeBoolForKey:@"CompletedLevel40"]];
        [self setCompletedFirstFail:[aDecoder decodeBoolForKey:@"CompletedFirstFail"]];
        [self setCompletedUnwary:[aDecoder decodeBoolForKey:@"CompletedUnwary"]];
        [self setCompletedDestroyer:[aDecoder decodeBoolForKey:@"CompletedDestroyer"]];
        [self setCompletedLightHunger:[aDecoder decodeBoolForKey:@"CompletedLightHunger"]];
        [self setCompletedIFeelGood:[aDecoder decodeBoolForKey:@"CompletedIFeelGood"]];
        [self setCompletedOhNoNo:[aDecoder decodeBoolForKey:@"CompletedOhNoNo"]];
        [self setCompletedStarry:[aDecoder decodeBoolForKey:@"CompletedStarry"]];
        [self setCompletedStargazer:[aDecoder decodeBoolForKey:@"CompletedStargazer"]];
        [self setCompletedSuperstar:[aDecoder decodeBoolForKey:@"CompletedSuperstar"]];
        [self setCompletedAwesome:[aDecoder decodeBoolForKey:@"CompletedAwesome"]];
        [self setCompletedTrueGenbyFan:[aDecoder decodeBoolForKey:@"CompletedTrueGenbyFan"]];
        [self setCompletedMoreFun:[aDecoder decodeBoolForKey:@"CompletedMoreFun"]];
        [self setCompletedRushHour:[aDecoder decodeBoolForKey:@"CompletedRushHour"]];
        [self setGameTotalRunTime:[aDecoder decodeDoubleForKey:@"GameTotalRunTime"]];
        [self setCellsKilled:[aDecoder decodeIntForKey:@"CellsKilled"]];
        [self setFoodEaten:[aDecoder decodeIntForKey:@"FoodEaten"]];
        [self setBombsExploded:[aDecoder decodeIntForKey:@"BombsExploded"]];
        [self setBubblesPoped:[aDecoder decodeIntForKey:@"BubblesPoped"]];
        [self setHighestOpenedLevel:[aDecoder decodeIntForKey:@"HighestOpenedLevel"]];
        [self setTotalNumOfReceivedStars:[aDecoder decodeIntForKey:@"TotalNumOfReceivedStars"]];
        _levelHighestScoreArray = [[aDecoder decodeObjectForKey:@"LevelHighestScoreArray"] retain];
        _levelHighestStarsNumArray = [[aDecoder decodeObjectForKey:@"LevelHighestStarsNumArray"] retain];
    }
    return self;
}

- (void)resetState
{
    [self setCompletedLevel10:NO];
    [self setCompletedLevel20:NO];
    [self setCompletedLevel30:NO];
    [self setCompletedLevel40:NO];
    [self setCompletedFirstFail:NO];
    [self setCompletedUnwary:NO];
    [self setCompletedDestroyer:NO];
    [self setCompletedLightHunger:NO];
    [self setCompletedIFeelGood:NO];
    [self setCompletedOhNoNo:NO];
    [self setCompletedStarry:NO];
    [self setCompletedStargazer:NO];
    [self setCompletedSuperstar:NO];
    [self setCompletedAwesome:NO];
    [self setCompletedRushHour:NO];
    [self setCompletedTrueGenbyFan:NO];
    [self setCompletedMoreFun:NO];
    [self setGameTotalRunTime:0];
    [self setCellsKilled:0];
    [self setFoodEaten:0];
    [self setBombsExploded:0];
    [self setBubblesPoped:0];
    [self setHighestOpenedLevel:1];
    [self setTotalNumOfReceivedStars:0];
    [_levelHighestScoreArray removeAllObjects];
    [_levelHighestStarsNumArray removeAllObjects];
    
    for (int i = 0 ; i < kLevelCount ; i++)
    {
        [_levelHighestScoreArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
        [_levelHighestStarsNumArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
    }
    
    [self save];
}

- (int)getHighestScoreForSceneID:(SceneTypes)sceneID
{
    return [[_levelHighestScoreArray objectAtIndex:(int)sceneID-101] integerValue];
}

- (void)dealloc
{
    [_levelHighestScoreArray release];
    _levelHighestScoreArray = nil;
    [_levelHighestStarsNumArray release];
    _levelHighestStarsNumArray = nil;
    
    [super dealloc];
}

@end
