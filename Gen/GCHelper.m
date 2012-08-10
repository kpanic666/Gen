//
//  GCHelper.m
//  SpaceViking
//
//  Created by Andrey Korikov on 15.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "GCHelper.h"
#import "GCDatabase.h"

@implementation GCHelper

@synthesize scoresToReport;
@synthesize achievementsToReport;

#pragma mark Loading/Saving

static GCHelper *sharedHelper = nil;
+ (GCHelper*)sharedInstance
{
    @synchronized([GCHelper class])
    {
        if (!sharedHelper) {
            sharedHelper = [loadData(@"GameCenterData") retain];
            if (!sharedHelper) {
                [[self alloc] initWithScoresToReport:[NSMutableArray array] achievementsToReport:[NSMutableArray array]];
            }
        }
        return sharedHelper;
    }
    return nil;
}

+ (id)alloc
{
    @synchronized([GCHelper class])
    {
        NSAssert(sharedHelper == nil, @"Attempted to allocated a \
                 second instance of the GCHelper singleton");
        sharedHelper = [super alloc];
        return sharedHelper;
    }
    return nil;
}

- (void)save
{
    saveData(self, @"GameCenterData");
}

- (BOOL)isGameCenterAvailable
{
    // Check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // Check if the device is running IOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)initWithScoresToReport:(NSMutableArray *)theScoresToReport achievementsToReport:(NSMutableArray *)theAchievementsToReport
{
    if ((self = [super init])) {
        self.scoresToReport = theScoresToReport;
        self.achievementsToReport = theAchievementsToReport;
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}

- (void)sendScore:(GKScore *)score
{
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if (error == NULL) {
                               NSLog(@"Successfully sent score!");
                               [scoresToReport removeObject:score];
                           } else {
                               NSLog(@"Score failed to send... will try again later. Reason: %@", error.localizedDescription);
                           }
                       });
    }];
}

- (void)sendAchievement:(GKAchievement *)achievement
{
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if (error == NULL) {
                               NSLog(@"Successfully sent achievement!");
                               [achievementsToReport removeObject:achievement];
                           } else {
                               NSLog(@"Achievement failed to send... will try again later. Reason: %@", error.localizedDescription);
                           }
                       });
    }];
}

- (void)resendData
{
    for (GKAchievement *achievement in achievementsToReport) {
        [self sendAchievement:achievement];
    }
    for (GKScore *score in scoresToReport) {
        [self sendScore:score];
    }
}

#pragma mark Internal functions
- (void)authenticationChanged
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
                           NSLog(@"Authentication changed: player authenticated.");
                           userAuthenticated = TRUE;
                           [self resendData];
                       } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
                           NSLog(@"Authentication changed: player not authenticated.");
                           userAuthenticated = FALSE;
                       }
                   });
}

- (void)authenticateLocalUser
{
    if (!gameCenterAvailable) {
        return;
    }
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
}

- (void)reportScore:(NSString *)identifier score:(int)rawScore
{
    GKScore *score = [[[GKScore alloc] initWithCategory:identifier] autorelease];
    score.value = rawScore;
    [scoresToReport addObject:score];
    [self save];
    
    if (!gameCenterAvailable || !userAuthenticated) return;
    [self sendScore:score];
}

- (void)reportAchievement:(NSString *)identifier percentComplete:(double)percentComplete
{
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
    achievement.showsCompletionBanner = YES;
    achievement.percentComplete = percentComplete;
    [achievementsToReport addObject:achievement];
    [self save];
    
    if (!gameCenterAvailable || !userAuthenticated) return;
    [self sendAchievement:achievement];
}

- (void)resetAchievements
{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if (error == NULL) {
                               NSLog(@"Achievement reset succesfull");
                               [achievementsToReport removeAllObjects];
                               [self save];
                           } else {
                               NSLog(@"Achievement failed to send... will try again later. Reason: %@", error.localizedDescription);
                           }
                       });
    }];
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:scoresToReport forKey:@"ScoresToReport"];
    [aCoder encodeObject:achievementsToReport forKey:@"AchievementsToReport"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSMutableArray *theScoresToReport = [aDecoder decodeObjectForKey:@"ScoresToReport"];
    NSMutableArray *theAchievementToReport = [aDecoder decodeObjectForKey:@"AchievementToReport"];
    return [self initWithScoresToReport:theScoresToReport achievementsToReport:theAchievementToReport];
}

@end
