//
//  ChildCell.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ChildCell.h"
#import "GameManager.h"

@implementation ChildCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    bodyDef.linearDamping = 0.1f;
    bodyDef.fixedRotation = TRUE;
    bodyDef.allowSleep = FALSE;
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    // Создаем тела и спрайты с 2мя разными размерами
    float scale = CCRANDOM_0_1();
    if (scale <= 0.5f) {
        scale = 0.8f;
        fixtureDef.density = 3.0;
        fixtureDef.friction = 0.1;
        fixtureDef.restitution = 0.4;
    } else {
        scale = 1.0f;
        fixtureDef.density = 5.0;
        fixtureDef.friction = 0.3;
        fixtureDef.restitution = 0.1;
    }
    [self setScale:scale];
    shape.m_radius = self.contentSize.width * 0.22f * scale / PTM_RATIO;
    fixtureDef.shape = &shape;
    fixtureDef.filter.categoryBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    if (characterState == kStateDead) {
        return;
    }
    if ((characterState == kStateTakingDamage) && ([self numberOfRunningActions] > 0)) {
        return;
    }
    if ([self numberOfRunningActions] == 0) {
        if (characterHealth <= 0 && characterState != kStateSoul) {
            [self changeState:kStateDead];
        }
    }
    
    if (characterState == kStateBeforeSoul && body == nil) {
            [self changeState:kStateSoul];
    }
    
    if (characterState == kStateSoul && [self numberOfRunningActions] == 0) {
        if (body == nil) {
            
            // Уменьшает клетку
            self.scale = 0.7;
            
            // Определяем следующую точку для произвольного движения внутри выхода
            if (!exitCellSprite) {
                exitCellSprite = (GameCharacter*) [[self parent] getChildByTag:kExitCellSpriteTagValue];
            }
            CGRect exitBoundingBox = [exitCellSprite adjustedBoudingBox];
            int yPositionInExitCell = exitBoundingBox.origin.y + random() % (int)exitBoundingBox.size.height;
            int xPositionInExitCell = exitBoundingBox.origin.x + random() % (int)exitBoundingBox.size.width;
            
            // Рэндомно двигаем клетки внутри выхода
            id randomMove = [CCSequence actions:
                              [CCMoveTo actionWithDuration:2.5f position:ccp(xPositionInExitCell, yPositionInExitCell)],
                              [CCDelayTime actionWithDuration:0.1f],
                              nil];
            [self runAction:randomMove];
        }
    }
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_idle.png"]];
        gameObjectType = kChildCellType;
        characterState = kStateSpawning;
        characterHealth = kChildCellHealth;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void) removeCellSprite {
    
    [self setIsActive:FALSE];
    [self removeFromParentAndCleanup:NO];
}

- (CGRect)adjustedBoudingBox {
    
    // Увеличиваем AABB клетки до больших размеров. Нужно для разброса клеток после их смерти при сооударении с красной клеткой
    CGRect exitBoundingBox = [self boundingBox];
    float offset = exitBoundingBox.size.width * 6;
    float addAmount = offset * 2;
    
    exitBoundingBox = CGRectMake(exitBoundingBox.origin.x - offset, exitBoundingBox.origin.y - offset, addAmount, addAmount);
    
    return exitBoundingBox;
}

- (void)changeState:(CharacterStates)newState
{
    if (characterState == newState) {
        return;
    }
    
    [self stopAllActions];
    [self setCharacterState:newState];
    
    switch (newState) {
        case kStateTakingDamage:
        {
            characterHealth -= kRedCellDamage;
            
            // Destroy Physics body
            self.markedForDestruction = YES;
            [GameManager sharedGameManager].numOfTotalCells--;
        
            PLAYSOUNDEFFECT(@"CHILDCELL_DYING_1");
            break;
        }
            
        case kStateConnecting:
            // Клетка уже в зоне действия сенсора ParentCell, но джойнта еще нет
            break;
            
        case kStateConnected:
        {
            // Нужно менять вид клетки. Это состояние принимается клеткой когда был создан джойнт
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_connected.png"]];
            break;
        }
            
        case kStateDisconnecting:
            // Клетка вышла из зоны действия сенсора, но джойнт еще не разорван
            break;
            
        case kStateIdle:
        {
            // Меняется внешний вид клетки на обычный. В этом состояний объект может продолжать двигаться по инерции,
            // но на нее уже не влияет игрок.
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_idle.png"]];
            break;
        }
            
        case kStateBeforeSoul:
        {
            self.markedForDestruction = YES;
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_idle.png"]];
            [GameManager sharedGameManager].numOfTotalCells--;
            break;
        }
            
        case kStateSoul:
        {
            // Клетка ударилась об выход и должна уничтожить физ тело и сменить спрайт и дрыгаться внутри выхода
            [self setCharacterHealth:0];
            
            PLAYSOUNDEFFECT(@"CHILDCELL_SOUL_1");
            
            // 1. Меняем цвет у умерших клеток
            self.color = ccc3(255, 0, 253);
            self.opacity = 200;
            
            // 2. Двигаем мертвые клетки (души) в центр выхода
            int timeToMove = random() % 3 + 1;   // 1-4 sec
            exitCellSprite = (GameCharacter*) [[self parent] getChildByTag:kExitCellSpriteTagValue];
            CCEaseBounceIn *moveInsideElastic = [CCEaseBounceIn actionWithAction:[CCMoveTo actionWithDuration:timeToMove position:exitCellSprite.position]];
            [self runAction:moveInsideElastic];

            break;
        }
            
        case kStateDead:
        {
            int frameNum = random() % 2 + 1;
            float travelTime = CCRANDOM_0_1() + 1;
            float rotateTime = CCRANDOM_0_1() * 2;
            float rotateAngle = 360;
            if (CCRANDOM_0_1() <= 0.5f) rotateAngle *= -1;
            CGRect cellBB = [self adjustedBoudingBox];
            int yRandPosAtSceen = cellBB.origin.y + random() % (int)cellBB.size.height;
            int xRandPosAtSceen = cellBB.origin.x + random() % (int)cellBB.size.width;
            
            // Change sprite frame to random RedCell particle. Уменьшаем клетку в размере
            NSString *frameName = [NSString stringWithFormat:@"redcell_particle%d.png", frameNum];
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
            
            
            // Move to random position at random speed, rotate and fade after target position
            CCMoveTo *dyingMove = [CCMoveTo actionWithDuration:travelTime position:ccp(xRandPosAtSceen, yRandPosAtSceen)];
            CCSequence *dyingFade = [CCSequence actions:
                                     [CCDelayTime actionWithDuration:travelTime - 0.4f],
                                     [CCFadeOut actionWithDuration:0.4f],
                                     [CCCallFunc actionWithTarget:self selector:@selector(removeCellSprite)],
                                     nil];
            CCRepeatForever *dyingRotate = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:rotateTime angle:rotateAngle]];
            
            [self runAction:dyingRotate];
            [self runAction:dyingMove];
            [self runAction:dyingFade];

            break;
        }
            
        default:
            break;
    }
}

- (void)dealloc
{
    exitCellSprite = nil;
    [super dealloc];
}

@end
