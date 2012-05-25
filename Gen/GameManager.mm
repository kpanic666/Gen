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
@synthesize numOfNeededCells = _numOfNeededCells;

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
    if (managerSoundState == kAudioManagerReady && isMusicON) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
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
        case kGameLevel4:
            result = @"kGameLevel4";
            break;
        case kGameLevel5:
            result = @"kGameLevel5";
            break;
        case kGameLevel6:
            result = @"kGameLevel6";
            break;
        case kGameLevel8:
            result = @"kGameLevel8";
            break;
        case kGameLevel13:
            result = @"kGameLevel13";
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
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
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
        hasLevelWin = NO;
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
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    lastLevel = curLevel;
    curLevel = sceneID;
    id sceneToRun = nil;
    switch (sceneID) {
        case kMainMenuScene:
            sceneToRun = [MainMenuLayer scene];
            break;
            
        case kInfoScene:
            //sceneToRun = [CreditsScene node];
            break;
            
        case kLoadingScene:
            //sceneToRun = [IntroScene node];
            break;
            
        case kLevelSelectScene:
            sceneToRun = [LevelSelectLayer scene];
            break;    
            
        case kGameLevel1:
            _numOfNeededCells = kScene1Needed;
            sceneToRun = [Scene1 node];
            break;
        case kGameLevel2:
            _numOfNeededCells = kScene2Needed;
            sceneToRun = [Scene2 node];
            break;
        case kGameLevel3:
            _numOfNeededCells = kScene3Needed;
            sceneToRun = [Scene3 node];
            break;
        case kGameLevel4:
            _numOfNeededCells = kScene4Needed;
            sceneToRun = [Scene4 node];
            break;
        case kGameLevel5:
            _numOfNeededCells = kScene5Needed;
            sceneToRun = [Scene5 node];
            break;
        case kGameLevel6:
            _numOfNeededCells = kScene6Needed;
            sceneToRun = [Scene6 node];
            break;
        case kGameLevel7:
            _numOfNeededCells = kScene7Needed;
            sceneToRun = [Scene7 node];
            break;
        case kGameLevel8:
            _numOfNeededCells = kScene8Needed;
            sceneToRun = [Scene8 node];
            break;
        case kGameLevel9:
            _numOfNeededCells = kScene9Needed;
            sceneToRun = [Scene9 node];
            break;
        case kGameLevel10:
            _numOfNeededCells = kScene10Needed;
            sceneToRun = [Scene10 node];
            break;    
        case kGameLevel11:
            _numOfNeededCells = kScene11Needed;
            sceneToRun = [Scene11 node];
            break;
        case kGameLevel12:
            _numOfNeededCells = kScene12Needed;
            sceneToRun = [Scene12 node];
            break;
        case kGameLevel13:
            _numOfNeededCells = kScene13Needed;
            sceneToRun = [Scene13 node];
            break;
        case kGameLevel14:
            _numOfNeededCells = kScene14Needed;
            sceneToRun = [Scene14 node];
            break;
        case kGameLevel15:
            _numOfNeededCells = kScene15Needed;
            sceneToRun = [Scene15 node];
            break;
        case kGameLevel16:
            _numOfNeededCells = kScene16Needed;
            sceneToRun = [Scene16 node];
            break;
        case kGameLevel17:
            _numOfNeededCells = kScene17Needed;
            sceneToRun = [Scene17 node];
            break;
        case kGameLevel18:
            _numOfNeededCells = kScene18Needed;
            sceneToRun = [Scene18 node];
            break;
        case kGameLevel19:
            _numOfNeededCells = kScene19Needed;
            sceneToRun = [Scene19 node];
            break;
        case kGameLevel20:
            _numOfNeededCells = kScene20Needed;
            sceneToRun = [Scene20 node];
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
    
    // Load Audio for new scene based on sceneID
    [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:currentScene]];
    
    // Menu Scenes have a value of < 100
//    if (sceneID < 100) {
//        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
//            CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
//            if (screenSize.width == 960.0f) {
//                // IPhone 4 Retina
//                [sceneToRun setScaleX:0.9375f];
//                [sceneToRun setScaleY:0.8333f];
//                CCLOG(@"GM:Scaling for Iphone 4 (retina)");
//            } else {
//                [sceneToRun setScaleX:0.4688f];
//                [sceneToRun setScaleY:0.4166f];
//                CCLOG(@"GM:Scaling for Iphone 3G (or older)");
//            }
//        }
//    }
    // Game Scenes have a value of > 100
//    if (sceneID > 100) {
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            [sceneToRun setScaleX:1.06];
//            [sceneToRun setScaleY:1.2];
//        }
//    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] pushScene:sceneToRun];
    } else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.1f scene:sceneToRun]];
    }
    
    [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
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
    return levelSize;
}

@end
