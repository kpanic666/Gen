//
//  ExitCell.mm
//  Gen
//
//  Created by Andrey Korikov on 22.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "ExitCell.h"

@implementation ExitCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    // Это область рта, только попав в эту область еда будет съедена. Запускается анимация жевания, еда уменьшается
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    shape.m_radius = [self boundingBox].size.width * 0.25 / PTM_RATIO;
    fixtureDef.shape = &shape;
    fixtureDef.filter.categoryBits = kExitCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
    
    // Создаем сенсор, который будет определять радиус, в котором будут притягиваться клетки
    fixtureDef.isSensor = TRUE;
    shape.m_radius = [self boundingBox].size.width * 0.6 / PTM_RATIO;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    if ([self numberOfRunningActions] == 0 && [self.tongue numberOfRunningActions] == 0 && [self.blink numberOfRunningActions] == 0)
    {
        // Not playing an animation
        if (self.characterState == kStateIdle) {
            millisecondsStayingIdle += deltaTime;
            if (millisecondsStayingIdle > kExitCellPlayingWhenIdleTimer) {
                [self changeState:kStatePlayingWhenIdle];
            }
        }
        else if (self.characterState != kStateIdle && self.characterState != kStateOpenedMouth) {
            millisecondsStayingIdle = 0.0f;
            [self changeState:kStateIdle];
        }
    }
    
}

- (void)initAnimation
{
    CCAnimationCache *animCache = [CCAnimationCache sharedAnimationCache];
    
	self.tongueAnim = [animCache animationByName:@"genby_anim_tongue"];
    self.tentaclesAnim = [animCache animationByName:@"genby_anim_tentacles"];
    self.blinkAnim = [animCache animationByName:@"genby_anim_blink"];
    self.openMouthAnim = [animCache animationByName:@"genby_anim_openmouth"];
    self.closeMouthAnim = [animCache animationByName:@"genby_anim_closemouth"];
    self.eatingAnim = [animCache animationByName:@"genby_anim_eating"];
    self.sadAnim = [animCache animationByName:@"genby_anim_sad"];
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        self.gameObjectType = kExitCellType;
        millisecondsStayingIdle = 3.0f;
        foodInSensorCounter = 0;
        self.leftEye = [CCSprite spriteWithSpriteFrameName:@"GB_eyeLeft.png"];
        self.rightEye = [CCSprite spriteWithSpriteFrameName:@"GB_eyeRight.png"];
        self.tongue = [CCSprite spriteWithSpriteFrameName:@"GB_tongue_1.png"];
        self.blink = [CCSprite spriteWithSpriteFrameName:@"GB_blink_1.png"];
        _leftEye.anchorPoint = ccp(0.5, 0);
        _rightEye.anchorPoint = ccp(0.5, 0);
        leftEyeInitPos = ccp(location.x - _leftEye.contentSize.width*0.75, location.y + _leftEye.contentSize.height*0.45);
        rightEyeInitPos = ccp(location.x + _rightEye.contentSize.width*0.75, location.y + _rightEye.contentSize.height*0.45);
        tongueInitPos = ccp(location.x - _tongue.contentSize.width*0.05, location.y - _tongue.contentSize.height*0.75);
        _leftEye.position = leftEyeInitPos;
        _rightEye.position = rightEyeInitPos;
        _tongue.position = tongueInitPos;
        _blink.position = ccp(location.x, location.y + _blink.contentSize.height*0.34);
        
        [self initAnimation];
        [self changeState:kStateIdle];
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [self.parent addChild:self.leftEye z:2];
    [self.parent addChild:self.rightEye z:2];
    [self.parent addChild:self.tongue z:2];
    [self.parent addChild:self.blink z:3];
}

- (void)changeState:(CharacterStates)newState
{
    // Ведем подсчет кол-ва еды в зоне сенсора
    if (newState == kStateOpenedMouth) {
        foodInSensorCounter++;
    }
    else if (newState == kStateCloseMouth || newState == kStateEating)
    {
        foodInSensorCounter--;
    }
    
    if (characterState == newState) {
        return;
    }
    
    CCAnimate *animateAction = nil;
    
    switch (newState) {
        case kStateIdle:
            [self showEyesAndTongue:YES];
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"GB_key.png"]];
            [self.tongue setDisplayFrameWithAnimationName:@"genby_anim_tongue" index:0];
            break;
            
        case kStatePlayingWhenIdle:
        {
            int animToPlay = random() % 4;
            switch (animToPlay) {
                case 0:
                    animateAction = [CCAnimate actionWithAnimation:self.tentaclesAnim];
                    break;
                case 1:
                    [self.tongue runAction:[CCAnimate actionWithAnimation:self.tongueAnim]];
                    break;
                case 2:
                {
                    id moveRight = [CCRotateBy actionWithDuration:0.2 angle:-45];
                    id moveLeft = [CCRotateBy actionWithDuration:0.2 angle:90];
                    id delayAction = [CCDelayTime actionWithDuration:0.4];
                    id seq = [CCSequence actions:moveRight, delayAction, moveLeft, delayAction, moveRight, nil];
                    [self.leftEye runAction:seq];
                    [self.rightEye runAction:[[seq copy] autorelease]];
                    
                    break;
                }
                case 3:
                    [self.blink setVisible:YES];
                    [self.blink runAction:[CCAnimate actionWithAnimation:self.blinkAnim]];
                    break;

                default:
                    break;
            }
            break;
        }
            
        case kStateOpenedMouth:
            CCLOG(@"kStateOpenMouth");
            [self showEyesAndTongue:NO];
            animateAction = [CCAnimate actionWithAnimation:self.openMouthAnim];
            break;
            
        case kStateCloseMouth:
            if (foodInSensorCounter > 0) return;
            [self showEyesAndTongue:NO];
            animateAction = [CCAnimate actionWithAnimation:self.closeMouthAnim];
            CCLOG(@"kStateCloseMouth");
            break;
            
        case kStateEating:
        {
            if (foodInSensorCounter > 0) return;
            [self showEyesAndTongue:NO];
            animateAction = [CCAnimate actionWithAnimation:self.eatingAnim];
            CCLOG(@"kStateEating");
            break;
        }
            
        case kStateSad:
            if (foodInSensorCounter > 0) return;
            [self showEyesAndTongue:NO];
            animateAction = [CCAnimate actionWithAnimation:self.sadAnim];
            CCLOG(@"kStateSad");
            break;

        default:
            break;
    }
    
    [self stopAllActions];
    [self setCharacterState:newState];
    
    if (animateAction != nil) {
        [self runAction:animateAction];
    }
}

- (void)showEyesAndTongue:(BOOL)switcher
{
    [self.rightEye setVisible:switcher];
    [self.leftEye setVisible:switcher];
    [self.tongue setVisible:switcher];
    [self.blink setVisible:NO];
}

- (void)dealloc
{
    [_leftEye release];
    [_rightEye release];
    [_tongue release];
    [_blink release];
    
    [_tongueAnim release];
    [_tentaclesAnim release];
    [_blinkAnim release];
    [_openMouthAnim release];
    [_closeMouthAnim release];
    [_eatingAnim release];
    [_sadAnim release];
    
    [super dealloc];
}

@end