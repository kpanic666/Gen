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
#define kDrawNodeTagValue 21
#define kChildCellHealth 100
#define kParentCellSpriteTagValue 10
#define kRedCellDamage 100
#define kMagneticPowerMultiplier 0.15
#define kLevelCount 40
#define kMaxBubbleMoveDuration 15
#define kMinBubbleMoveDuration 5
#define kMaxNumOfBubbleOnScene 5
#define kiPadScreenOffsetX 32
#define kiPadScreenOffsetY 64
// Parent Cell Radius drawing
#define kParentCellRadiusWidthMax 2
#define kParentCellRadiusWidthMin 1
#define kParentCellRadiusWidthChangeSpeed 0.1
// BombCell Parameters
#define kBombTimer 3.0  //secs
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
#define kAchievementCellDestroyer @"com.atomgames.genby.achievement.celldestroyer" // Destroy 100 cells
#define kAchievementCellDestroyerNum 100
// Leaderboards
#define kLeaderboardChapter1 @"com.atomgames.genby.leaderboard.chapter1"

// Всего ячеек на уровне
typedef enum {
    kScene1Total = 24,
    kScene2Total = 17,
    kScene3Total = 7,
    kScene4Total = 10,
    kScene5Total = 14,
    kScene6Total = 41,
    kScene7Total = 10,
    kScene8Total = 10,
    kScene9Total = 4,
    kScene10Total = 12,
    kScene11Total = 13,
    kScene12Total = 15,
    kScene13Total = 8,
    kScene14Total = 25,
    kScene15Total = 16,
    kScene16Total = 14,
    kScene17Total = 26,
    kScene18Total = 9,
    kScene19Total = 9,
    kScene20Total = 14
} NumOfCellsTotal;

// Кол-во спасенных ячеек для окончания уровня
typedef enum {
    kScene1Needed = 20,
    kScene2Needed = 14,
    kScene3Needed = 6,
    kScene4Needed = 9,
    kScene5Needed = 14,
    kScene6Needed = 40,
    kScene7Needed = 10,
    kScene8Needed = 10,
    kScene9Needed = 4,
    kScene10Needed = 12,
    kScene11Needed = 12,
    kScene12Needed = 7,
    kScene13Needed = 8,
    kScene14Needed = 15,
    kScene15Needed = 16,
    kScene16Needed = 14,
    kScene17Needed = 26,
    kScene18Needed = 9,
    kScene19Needed = 9,
    kScene20Needed = 14
} NumOfCellsNeeded;

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
    kGroundCellFilterCategory = 0x0200
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
    kGameLevel20=120
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
