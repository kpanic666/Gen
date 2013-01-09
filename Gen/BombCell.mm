//
//  BobmCell.m
//  Gen
//
//  Created by Andrey Korikov on 20.07.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "BombCell.h"
#import "GameState.h"

@implementation BombCell

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        self.dontCount = FALSE;
        self.spActive = FALSE;
        
        world = theWorld;
        [self setFoodTextureName:@"deadfish_idle"];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"deadfish_idle.png"]];
        [self setPosition:location];
        gameObjectType = kEnemyTypeBomb;
        characterState = kStateIdle;
        characterHealth = kChildCellHealth;
        [self createBodyAtLocation:location];
        self.boomAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"deadfish_anim_explosion"];
        self.timerAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"deadfish_anim_timer"];
    }
    return self;
}

- (void)boom
{
    // Вычисляем через b2Distance точки воздействия взрыва на телах childCells и кратчайшее расстояние до них для силы воздействия
    // Prepare input for distance query.
    
    if (!exploded) exploded = TRUE;
    
    [self runAction:[CCAnimate actionWithAnimation:self.boomAnim]];
    
    for (b2Body *b = world->GetBodyList(); b != NULL; b = b->GetNext())
    {
        if (b->GetUserData() != self && b->GetType() == b2_dynamicBody)
        {
            b2SimplexCache cache;
            cache.count = 0;
            b2DistanceInput distanceInput;
            b2DistanceOutput distanceOutput;
            b2DistanceProxy bombProxy;
            bombProxy.Set(body->GetFixtureList()->GetShape(), 0);
            distanceInput.proxyA = bombProxy;
            distanceInput.transformA = body->GetTransform();
            distanceInput.useRadii = false;
            b2DistanceProxy targetProxy;
            targetProxy.Set(b->GetFixtureList()->GetShape(), 0);
            distanceInput.proxyB = targetProxy;
            distanceInput.transformB = b->GetTransform();
            
            // Get the distance between shapes.
            b2Distance(&distanceOutput, &cache, &distanceInput);
            
            if (distanceOutput.distance < kBombRadius) {
                b2Vec2 distanceDiff = distanceOutput.pointA - distanceOutput.pointB;
                float atanFromDistance = atan2f(distanceDiff.y, distanceDiff.x);
                float xForce = (distanceOutput.distance - kBombRadius) * cosf(atanFromDistance) * kBombPower;
                float yForce = (distanceOutput.distance - kBombRadius) * sinf(atanFromDistance) * kBombPower;
                b->ApplyLinearImpulse(b2Vec2(xForce, yForce), distanceOutput.pointB);
            }
        }
    }
    
    // Apply shake effect to screen
    id shakeAction = [CCShaky3D actionWithRange:2 shakeZ:NO grid:ccg(15, 10) duration:0.5];
    [[[self parent] parent] runAction: shakeAction];
    
    [self changeState:kStateTakingDamage];
}

- (void)changeState:(CharacterStates)newState
{
    if (characterState == newState) {
        return;
    }
    
    [self setCharacterState:newState];
    
    switch (newState) {
        case kStateTakingDamage:
        {
            characterHealth -= kRedCellDamage;
            STOPSOUNDEFFECT(timerSound);
            
            // Destroy Physics body
            self.markedForDestruction = YES;
            if (self.dontCount == false) {
                [GameManager sharedGameManager].numOfTotalCells--;
            }
            
            
            if (exploded == true)
            {
                // Count number of destroyed cells for all time for achievement
                if ([GameState sharedInstance].bombsExploded < kAchievementBomberNum) {
                    [GameState sharedInstance].bombsExploded++;
                }
                PLAYSOUNDEFFECT(@"BOMBCELL_EXPLOSION");
            }
            else
            {
                [self stopAllActions];
                PLAYSOUNDEFFECT(@"CHILDCELL_DYING_1");
            }
            
            break;
        }
            
        case kStateConnecting:
            // Клетка уже в зоне действия сенсора ParentCell, но джойнта еще нет
            break;
            
        case kStateConnected:
        {
            // Нужно менять вид клетки. Это состояние принимается клеткой когда был создан джойнт
            if (!activated)
            {
                activated = YES;
                timerSound = PLAYSOUNDEFFECT(@"BOMBCELL_TIMER");
                [self runAction:[CCSequence actions:
                                 [CCAnimate actionWithAnimation:self.timerAnim],
                                 [CCCallFunc actionWithTarget:self selector:@selector(boom)],
                                 nil]];
            }
            break;
        }
            
        case kStateDisconnecting:
            // Клетка вышла из зоны действия сенсора, но джойнт еще не разорван
            break;
            
        case kStateIdle:
        {
            // Меняется внешний вид клетки на обычный. В этом состояний объект может продолжать двигаться по инерции,
            // но на нее уже не влияет игрок.
            break;
        }
            
        case kStateBeforeSoul:
        {
            [self stopAllActions];
            STOPSOUNDEFFECT(timerSound);
            self.markedForDestruction = YES;
            if (self.dontCount == false) {
                [GameManager sharedGameManager].numOfTotalCells--;
                [GameManager sharedGameManager].numOfSavedCells++;
            }
            break;
        }
            
        case kStateSoul:
        {
            // Клетка ударилась об выход и должна уничтожить физ тело и сменить спрайт и дрыгаться внутри выхода
            [self setCharacterHealth:0];
            
            PLAYSOUNDEFFECT(@"CHILDCELL_SOUL_1");
            
            // 2. Двигаем мертвые клетки (души) в центр выхода
            exitCellSprite = (GameCharacter*) [[self parent] getChildByTag:kExitCellSpriteTagValue];
            id moveToMouth = [CCMoveTo actionWithDuration:0.2 position:exitCellSprite.position];
            id scaleDown = [CCScaleTo actionWithDuration:0.2 scale:0];
            id fadeOut = [CCFadeOut actionWithDuration:0.2];
            id spawnScaleFade = [CCSpawn actions:moveToMouth, fadeOut, scaleDown, nil];
            [self runAction:spawnScaleFade];
            
            break;
        }
            
        case kStateDead:
        {
            if (exploded)
            {
                [[[self parent] parent] runAction:[CCStopGrid action]];
                [self removeCellSprite];
            }
            else
            {
                float travelTime = CCRANDOM_0_1() + 1;
                float rotateTime = CCRANDOM_0_1() * 2;
                float rotateAngle = 360;
                if (CCRANDOM_0_1() <= 0.5f) rotateAngle *= -1;
                CGRect cellBB = [self adjustedBoudingBox];
                int yRandPosAtSceen = cellBB.origin.y + random() % (int)cellBB.size.height;
                int xRandPosAtSceen = cellBB.origin.x + random() % (int)cellBB.size.width;
                
                // Change sprite frame to random RedCell particle. Уменьшаем клетку в размере
                [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"food_fish_stale.png"]];
                
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
            }
            break;
        }
            
        default:
            break;
    }
}

- (void) activateWaterShieldsWithBatchNode:(CCSpriteBatchNode *)wsBatchNode
{
    return;
}

- (void)dealloc
{
    [_timerAnim release];
    [_boomAnim release];
    [super dealloc];
}

@end
