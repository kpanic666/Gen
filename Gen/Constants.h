//
//  Constants.h
//  Gen
//
//  Created by Andrey Korikov on 17.01.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#define kBox2DLayer 15
#define kPauseLayer 16
#define kGameOverLayer 17
#define kMainSpriteBatchNode 18
#define kBubbleCellTagValue 19
#define kExitCellSpriteTagValue 20
#define kExitCellPlayingWhenIdleTimer 4.0f
#define kDrawNodeTagValue 21
#define kChildCellHealth 100
#define kParentCellSpriteTagValue 10
#define kRedCellDamage 100
#define kMagneticPowerMultiplier 0.1
#define kLevelCount 40
// Air bubbles and sun bliks properties
#define kWaterWaveForegroundTag 22
#define kWaterWaveBackgroundTag 23
#define kWaterWavesPPS 100
#define kMaxBubbleMoveDelay 10
#define kMinBubbleMoveDelay 0
#define kMaxNumOfBubbleOnScene 13
#define kiPadScreenOffsetX 32
#define kiPadScreenOffsetY 64
// Parent Cell Radius drawing
#define kSuperpowerNumOfWaves 4
#define kSuperpowerScaleChangeSpeed 0.1
#define kSuperpowerRotationSpeed 180
// BombCell Parameters
#define kBombRadius 4   //meters. размер childcell около 0.35м
#define kBombPower 1.3    //Multiplicator
// Score multiplicators
#define kLevelMaxTime 30
#define kRemainingTimeMulti 50
#define kExtraCellsMulti 200
#define kGoalCellsMulti 100
#define kStarAchievedMulti 1000
#define kTapMulti -50
// Testflight
#define kTestFlightTeamToken @"544c9348f13c1963799af034d50d7e9c_MTA5NDMzMjAxMi0wNy0xMiAxMjoxMjo1OC42NzUwMjY"
// Achievements
#define kAchievementLevel10 @"com.atomgames.genby.achievement.level10"
#define kAchievementLevel20 @"com.atomgames.genby.achievement.level20"
#define kAchievementLevel30 @"com.atomgames.genby.achievement.level30"
#define kAchievementLevel40 @"com.atomgames.genby.achievement.level40"
#define kAchievementStarry @"com.atomgames.genby.achievement.starry"
#define kAchievementStargazer @"com.atomgames.genby.achievement.stargazer"
#define kAchievementSuperstar @"com.atomgames.genby.achievement.superstar"
#define kAchievementBubblepopper @"com.atomgames.genby.achievement.bubblepopper"
#define kAchievementLighthunger @"com.atomgames.genby.achievement.lighthunger"
#define kAchievementLighthungerNum 50
#define kAchievementIFeelGood @"com.atomgames.genby.achievement.ifeelgood"
#define kAchievementIFeelGoodNum 150
#define kAchievementOhNoNo @"com.atomgames.genby.achievement.ohnono"
#define kAchievementOhNoNoNum 300
#define kAchievementAwesome @"com.atomgames.genby.achievement.awesome"
#define kAchievementTrueGenbyFan @"com.atomgames.genby.achievement.truegenbyfan"
#define kAchievementFastAndSatisfying @"com.atomgames.genby.achievement.fastandsatisfying"
#define kAchievementRushHour @"com.atomgames.genby.achievement.rushhour"
#define kAchievementBomber @"com.atomgames.genby.achievement.bomber"
#define kAchievementFirstFail @"com.atomgames.genby.achievement.firstfail"
#define kAchievementFirstFailNum 1
#define kAchievementUnwary @"com.atomgames.genby.achievement.unwary"
#define kAchievementUnwaryNum 50
#define kAchievementCellDestroyer @"com.atomgames.genby.achievement.celldestroyer" // Destroy 100 cells
#define kAchievementCellDestroyerNum 100
// Leaderboards
#define kLeaderboardChapter1 @"com.atomgames.genby.leaderboard.chapter1"

// Collision Filter Categories. 0×1, 0×2, 0×4, 0×8, 0×10, 0×20, 0×40, 0×80.. From 0×0001 to 0×8000 and only power of 2!
// You can use ^ to exclude category from maskbit or use | to sum category in mask bits. maskbits = 0xFFFF ^ 0x0002
// maskbits = 0xFFFF ^ (0x0002 | 0x0003)
typedef enum {
    kParentCellFilterCategory = 0x0002,
    kChildCellFilterCategory = 0x0004,
    kExitCellFilterCategory = 0x0008,
    kMagneticCellFilterCategory = 0x0016,
    kRedCellFilterCategory = 0x0020,
    kMovingWallFilterCategory = 0x0040,
    kBubbledChildCellFilterCategory = 0x0080,
    kBubbleCellFilterCategory = 0x0100,
    kGroundCellFilterCategory = 0x0200,
    kMetalCellFilterCategory = 0x0300
} FilterCategories;

typedef enum {
    kNoSceneUninitialized=0,
    kMainMenuScene=1,
    kInfoScene=2,
    kLoadingScene=3,
    kLevelSelectScene=4,
    kGameLevel1=101,
    kGameLevel2=102,
    kGameLevel3=103,
    kGameLevel4=104,
    kGameLevel5=105,
    kGameLevel6=106,
    kGameLevel7=107,
    kGameLevel8=108,
    kGameLevel9=109,
    kGameLevel10=110,
    kGameLevel11=111,
    kGameLevel12=112,
    kGameLevel13=113,
    kGameLevel14=114,
    kGameLevel15=115,
    kGameLevel16=116,
    kGameLevel17=117,
    kGameLevel18=118,
    kGameLevel19=119,
    kGameLevel20=120,
    kGameLevel21=121,
    kGameLevel22=122,
    kGameLevel23=123,
    kGameLevel24=124,
    kGameLevel25=125,
    kGameLevel26=126,
    kGameLevel27=127,
    kGameLevel28=128,
    kGameLevel29=129,
    kGameLevel30=130,
    kGameLevel31=131,
    kGameLevel32=132,
    kGameLevel33=133,
    kGameLevel34=134,
    kGameLevel35=135,
    kGameLevel36=136,
    kGameLevel37=137,
    kGameLevel38=138,
    kGameLevel39=139,
    kGameLevel40=140
} SceneTypes;

typedef enum {
    kLinkTypeGameSite,
    kLinkTypeDeveloperSite,
    kLinkTypePublisherSite
} LinkTypes;

typedef enum {
    kAudioManagerUninitialized=0,
    kAudioManagerFailed=1,
    kAudioManagerInitializing=2,
    kAudioManagerInitialized=100,
    kAudioManagerLoading=200,
    kAudioManagerReady=300
} GameManagerSoundState;

// Turn ON=1 or OFF=0 DEBUG DRAW
#define DEBUG_DRAW 0

// Audio Items
#define AUDIO_MAX_WAITTIME 150

// Audio Constants
#define SFX_NOTLOADED NO
#define SFX_LOADED YES

#define PLAYSOUNDEFFECT(...) [[GameManager sharedGameManager] playSoundEffect:__VA_ARGS__]
#define STOPSOUNDEFFECT(...) [[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

// Background Music
// Menu Scenes
//#define BACKGROUND_TRACK_MAIN_MENU @"VikingPreludeV1.mp3"

// GameLevel1
#define BACKGROUND_TRACK_1 @"back_Wallpaper.mp3"

// GameLevel2
//#define BACKGROUND_TRACK_PUZZLE @"VikingPreludeV1.mp3"

// GameLevel3
//#define BACKGROUND_TRACK_MINECRAFT @"DrillBitV2.mp3"

// GameLevel4
//#define BACKGROUND_TRACK_ESCAPE @"EscapeTheFutureV3.mp3"

// PTM ratio for Box2D
#define PTM_RATIO ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 64.0 : 32.0)

// iOS version check macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
