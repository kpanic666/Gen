//
//  GCHelper.h
//  SpaceViking
//
//  Created by Andrey Korikov on 15.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Constants.h"

@interface GCHelper : NSObject <NSCoding> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
}

@property (retain) NSMutableArray *scoresToReport;
@property (retain) NSMutableArray *achievementsToReport;

+ (GCHelper*)sharedInstance;
- (void)authenticationChanged;
- (void)authenticateLocalUser;
- (void)save;
- (id)initWithScoresToReport:(NSMutableArray*)theScoresToReport achievementsToReport:(NSMutableArray*)theAchievementsToReport;
- (void)reportAchievement:(NSString*)identifier percentComplete:(double)percentComplete;
- (void)reportScore:(NSString*)identifier score:(int64_t)rawScore;
- (void)resetAchievements;

@end
