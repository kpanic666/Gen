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
@synthesize completedLevel10;
@synthesize cellsKilled;

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
    [aCoder encodeBool:completedLevel10 forKey:@"CompletedLevel10"];
    [aCoder encodeInt:cellsKilled forKey:@"CellsKilled"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        completedLevel10 = [aDecoder decodeBoolForKey:@"CompletedLevel10"];
        cellsKilled = [aDecoder decodeIntForKey:@"CellsKilled"];
    }
    return self;
}

@end
