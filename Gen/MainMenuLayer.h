//
//  MainMenuLayer.h
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"
#import <GameKit/GameKit.h>

@interface MainMenuLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>

+ (id)scene;

@end
