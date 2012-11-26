//
//  GameManager.m
//  Gen
//
//  Created by Andrey Korikov on 13.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "GameManager.h"
#import "Scene1.h"
#import "Scene2.h"
#import "Scene3.h"
#import "Scene4.h"
#import "Scene5.h"
#import "Scene6.h"
#import "Scene7.h"
#import "Scene8.h"
#import "Scene9.h"
#import "Scene10.h"
#import "Scene11.h"
#import "Scene12.h"
#import "Scene13.h"
#import "Scene14.h"
#import "Scene15.h"
#import "Scene16.h"
#import "Scene17.h"
#import "Scene18.h"
#import "Scene19.h"
#import "Scene20.h"
#import "Scene21.h"
#import "Scene22.h"
#import "Scene23.h"
#import "Scene24.h"
#import "Scene25.h"
#import "Scene26.h"
#import "Scene27.h"
#import "Scene28.h"
#import "Scene29.h"
#import "Scene30.h"
#import "Scene31.h"
#import "Scene32.h"
#import "Scene33.h"
#import "Scene34.h"
#import "Scene35.h"
#import "Scene36.h"
#import "Scene37.h"
#import "Scene38.h"
#import "Scene39.h"
#import "Scene40.h"
#import "MainMenuLayer.h"
#import "LevelSelectLayer.h"

@implementation GameManager

static GameManager* _sharedGameManager = nil;

@synthesize isMusicON;
@synthesize isSoundEffectsON;
@synthesize hasLevelWin;
@synthesize managerSoundState;
@synthesize listOfSoundEffectFiles;
@synthesize soundEffectsState;
@synthesize curLevel;
@synthesize lastLevel;
@synthesize numOfSavedCells = _numOfSavedCells;
@synthesize numOfTotalCells = _numOfTotalCells;
@synthesize numOfMaxCells = _numOfMaxCells;
@synthesize numOfNeededCells = _numOfNeededCells;
@synthesize levelTotalScore = _levelTotalScore;
@synthesize levelElapsedTime = _levelElapsedTime;
@synthesize levelStarsNum = _levelStarsNum;
@synthesize levelTappedNum = _levelTappedNum;
@synthesize levelName = _levelName;

+ (GameManager*)sharedGameManager {
    @synchronized([GameManager class])
    {
        if (!_sharedGameManager) {
            [[self alloc] init];
        }
        return _sharedGameManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([GameManager class])
    {
        NSAssert(_sharedGameManager == nil, @"Attempted to allocate a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;
}

- (void)setMusicState:(BOOL)state
{
    [self setIsMusicON:state];
    if ([soundEngine isBackgroundMusicPlaying]) {
        [soundEngine pauseBackgroundMusic];
    }
    else 
    {
        [soundEngine resumeBackgroundMusic];
    }
}

- (void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) &&
        (managerSoundState != kAudioManagerFailed)) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) ||
                (managerSoundState == kAudioManagerFailed)) {
                break; 
            }
            waitCycles = waitCycles + 1;
        }
    }
    if (managerSoundState == kAudioManagerReady && isMusicON && playedBackgroundMusic != trackFileName) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine setBackgroundMusicVolume:0.4];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
        playedBackgroundMusic = trackFileName;
    }
}

- (void)stopSoundEffect:(ALuint)soundEffectID {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopEffect:soundEffectID];
    }
}

- (ALuint)playSoundEffect:(NSString *)soundEffectKey {
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady && isSoundEffectsON) {
        NSNumber *isSFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isSFXLoaded boolValue] == SFX_LOADED) {
            soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey]];
        } else {
            CCLOG(@"GameManager->SoundEffect %@ is not loaded",soundEffectKey);
        }
    } else {
        CCLOG(@"GameManager->Sound Manager is not ready, cannot play %@", soundEffectKey);
    }
    return soundID;
}

- (NSString*)formatSceneTypeToString:(SceneTypes)sceneID {
    NSString *result = nil;
    switch (sceneID) {
        case kNoSceneUninitialized:
            result = @"kNoSceneUninitialized";
            break;
        case kMainMenuScene:
            result = @"kMainMenuScene";
            break;
        case kInfoScene:
            result = @"kInfoScene";
            break;
        case kLoadingScene:
            result = @"kLoadingScene";
            break;
        case kLevelSelectScene:
            result = @"kLevelSelectScene";
            break;
        default:
//            [NSException raise:NSGenericException format:@"Unexpected SceneType"];
            // Если здесь не обраб. конкретная сцена, значит звуки для сцены загружаются из общей секции SoundEffects.plist
            result = @"kGeneralSounds";
    }
    return result;
}

- (NSDictionary*)getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
    NSString *fullFileName = @"SoundEffects.plist";
    NSString *plistPath;
    
    // 1: Получаем путь к файлу Plist
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"SoundEffects" ofType:@"plist"];
    }
    
    // 2: Читаем файл свойст
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: Если прочитанный файл пуст - то файл не найден
    if (plistDictionary == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil;
    }
    
    // 4: Если listOfSoundEffects пуст, то загружаем его
    if ((listOfSoundEffectFiles == nil) || ([listOfSoundEffectFiles count] < 1)) {
        [self setListOfSoundEffectFiles:[[NSMutableDictionary alloc] init]];
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [listOfSoundEffectFiles addEntriesFromDictionary:[plistDictionary objectForKey:sceneSoundDictionary]];
        }
        CCLOG(@"Number of SFX filenames:%d",[listOfSoundEffectFiles count]);
    }
    
    // 5: Загрузить список звуковых эффектов и присвоить им состояние Unloaded
    if ((soundEffectsState == nil) || ([soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *soundEffectKey in listOfSoundEffectFiles) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:soundEffectKey];
        }
    }
    
    // 6: Возвращаем только мини список звуковых эффектов для текущей сцены
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = [plistDictionary objectForKey:sceneIDName];
    return soundEffectsList;
}

- (void)loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (managerSoundState == kAudioManagerInitializing) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (sceneID == lastLevel) {
        return;
    }
    
    if (managerSoundState == kAudioManagerFailed) {
        return;
    }
    NSDictionary *soundEffectsToLoad = [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToLoad == nil) {
        CCLOG(@"There are no SFX to load for this scene");
        return;
    }
    // Получить список файлов и предзагрузить их
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (NSString *keyString in soundEffectsToLoad) {
        CCLOG(@"\nLoading Audio Key:%@ File:%@", keyString, [soundEffectsToLoad objectForKey:keyString]);
        [soundEngine preloadEffect:[soundEffectsToLoad objectForKey:keyString]];
        [soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
    }
    [pool release];
}

- (void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (sceneID == kNoSceneUninitialized || sceneID == curLevel) {
        return; // Nothing to unload
    }
    NSDictionary *soundEffectsToUnload = [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToUnload == nil) {
        CCLOG(@"There are no SFX to unload for this scene");
        return; 
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (managerSoundState == kAudioManagerReady) {
        // Get all of the entries and unload
        for(NSString *keyString in soundEffectsToUnload) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [soundEngine unloadEffect:keyString];
            CCLOG(@"\nUnloading Audio Key:%@ File:%@",keyString,
                  [soundEffectsToUnload objectForKey:keyString]);
        }
    }
    [pool release];
}

- (void)initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing;
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_LOW];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    // Wait for the audio manager to initialize
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    // At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || audioManager.soundEngine.functioning == NO) {
        CCLOG(@"CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed;
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        [soundEngine setEffectsVolume:0.5];
        CCLOG(@"CocosDenshion is Ready");
    }
}

- (void)setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES;
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncSetupOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initAudioAsync) object:nil];
        [queue addOperation:asyncSetupOperation];
        [asyncSetupOperation autorelease];
    }
}

- (id)init {
    self = [super init];
    if (self != nil) {
        // Game Manager Initialized
        CCLOG(@"Game Manager Singleton init");
        isMusicON = YES;
        isSoundEffectsON = YES;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        currentScene = kNoSceneUninitialized;
    }
    return self;
}

- (void)reloadCurrentScene {
    [self runSceneWithID:curLevel];
}

- (void)runNextScene {
    [self runSceneWithID:(SceneTypes) (curLevel + 1)];
}

- (void)runSceneWithID:(SceneTypes)sceneID {
    // reset all stats and score variable for new level
    [self setHasLevelWin:NO];
    [self setNumOfSavedCells:0];
    [self setNumOfTotalCells:0];
    [self setLevelElapsedTime:0];
    [self setLevelTotalScore:0];
    [self setLevelHighScoreAchieved:NO];
    [self setLevelStarsNum:0];
    [self setLevelTappedNum:0];
    [self setNeedToUpdateScore:NO];
    
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    lastLevel = curLevel;
    curLevel = sceneID;
    id sceneToRun = nil;
    switch (sceneID) {
        case kMainMenuScene:
            sceneToRun = [MainMenuLayer scene];
            [self playBackgroundTrack:BACKGROUND_TRACK_1];
            break;
            
        case kInfoScene:
            //sceneToRun = [CreditsScene node];
            break;
            
        case kLoadingScene:
//            sceneToRun = [LoadingLayer scene];
            break;
            
        case kLevelSelectScene:
            sceneToRun = [LevelSelectLayer scene];
            [self playBackgroundTrack:BACKGROUND_TRACK_1];
            break;    
            
        case kGameLevel1 ... kGameLevel40:
            [self setLevelName:[NSString stringWithFormat:@"1-%i", (int)sceneID-100]];
            sceneToRun = [NSClassFromString([NSString stringWithFormat:@"Scene%i", (int)sceneID-100]) node];
            if (sceneID < kGameLevel21) {
                [self playBackgroundTrack:BACK_1];
            }
            else
            {
                [self playBackgroundTrack:BACK_2];
            }
            break;
            
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        currentScene = oldScene;
        return;
    }
    
    if (oldScene < 100 || currentScene < 100) {
        [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
        // Load Audio for new scene based on sceneID
        [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:currentScene]];
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
    } else {
        [[CCTextureCache sharedTextureCache] removeUnusedTextures];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.1f scene:sceneToRun]];
    }
}

- (void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen {
    NSURL *urlToOpen = nil;
    switch (linkTypeToOpen) {
        case kLinkTypeDeveloperSite:
            CCLOG(@"Opening Developer Site");
            urlToOpen = [NSURL URLWithString:@"http://www.atomgames.com"];
            break;
            
        case kLinkTypeGameSite:
            CCLOG(@"Opening Game Site");
            urlToOpen = [NSURL URLWithString:@"http://www.atomgames.com/genby"];
            break;
            
        case kLinkTypePublisherSite:
            CCLOG(@"Opening Publisher Site");
            urlToOpen = [NSURL URLWithString:@"http://www.chillingo.com"];
            break;
 
        default:
            CCLOG(@"Defaulting to Developer Site");
            urlToOpen = [NSURL URLWithString:@"http://www.atomgames.com/"];
            break;
    }
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        CCLOG(@"%@%@",@"Failed to open url:",[urlToOpen description]);
        [self runSceneWithID:kMainMenuScene];
    }
}

- (CGSize)getDimensionsOfCurrentScene {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGSize levelSize;
    switch (currentScene) {
        case kGameLevel1:
            levelSize = screenSize;
            break;
//        case kGameLevel4:
//            levelSize = CGSizeMake(screenSize.width * 4.0f, screenSize.height);
//            break;
        default:
            CCLOG(@"Unknown Scene ID, returning default size");
            levelSize = screenSize;
            break;
    }
    
    // Делаем рамку уровня если игра запускается на iPad, чтобы не менять графику и физ объекты, мы просто все поменщаем в центр экрана
    // Слева и справа по 32 поинта, сверхи и снизу по 64
    // Iphone Screen to iPad
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        levelSize = CGSizeMake(levelSize.width - kiPadScreenOffsetX * 2, levelSize.height - kiPadScreenOffsetY * 2);
//    }

    return levelSize;
}

#pragma mark -
#pragma mark Stats Setters
// Добавляем для того, чтобы при обновлении статистики выставлялся в True флаг needToUpdateScore и обновлялся счет в UI

- (void)setNumOfTotalCells:(int)numOfTotalCells
{
    _numOfTotalCells = numOfTotalCells;
    if (curLevel >= kGameLevel1)
    {
        _needToUpdateScore = TRUE;
    }
}

- (void)setNumOfSavedCells:(int)numOfSavedCells
{
    _numOfSavedCells = numOfSavedCells;
    if (curLevel >= kGameLevel1)
    {
        _needToUpdateScore = TRUE;
    }
}

@end
