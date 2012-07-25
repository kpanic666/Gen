//
//  BobmCell.m
//  Gen
//
//  Created by Andrey Korikov on 20.07.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "BombCell.h"
#import "SimpleQueryCallback.h"

#define kBombTimer 3.0
#define kBombRadius 4
#define kBombPower 3

@implementation BombCell

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super initWithWorld:theWorld atLocation:location])) {
        gameObjectType = kEnemyTypeBomb;
    }
    return self;
}

- (void)boom
{
//    // B2Query Settings
//    b2AABB aabb;
//    b2Vec2 delta = b2Vec2([self contentSize].width * kBombRadius / PTM_RATIO, [self contentSize].height * kBombRadius / PTM_RATIO);
//    b2Vec2 bodyB2Pos = body->GetPosition();
//    
//    aabb.lowerBound = bodyB2Pos - delta;
//    aabb.upperBound = bodyB2Pos + delta;
//    SimpleQueryCallback callback(bodyB2Pos, NULL);
//    world->QueryAABB(&callback, aabb);
//    
//    if (callback.fixtureFound)
//    {
//    }
    
    // Prepare input for distance query.
	b2SimplexCache cache;
	cache.count = 0;
	b2DistanceInput distanceInput;
    b2DistanceOutput distanceOutput;
    b2DistanceProxy bombProxy;
    bombProxy.Set(body->GetFixtureList()->GetShape(), 0);
	distanceInput.proxyA = bombProxy;
    distanceInput.transformA = body->GetTransform();
	distanceInput.useRadii = false;
    
    for (b2Body *b = world->GetBodyList(); b != NULL; b = b->GetNext())
    {
        if (b->GetUserData() != NULL && b->GetType() == b2_dynamicBody)
        {
            b2DistanceProxy targetProxy;
            targetProxy.Set(b->GetFixtureList()->GetShape(), 0);
            distanceInput.proxyB = targetProxy;
            distanceInput.transformB = b->GetTransform();
            
            // Get the distance between shapes. We can also use the results
            // to get a separating axis.
            b2Distance(&distanceOutput, &cache, &distanceInput);
            
            if (distanceOutput.distance <= 300) {
                b2Vec2 detonationVector = b2Vec2(1,33);
                b->ApplyLinearImpulse(detonationVector, distanceOutput.pointB);
            }
        }
    }
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
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bombcell_activated.png"]];
            [self scheduleOnce:@selector(boom) delay:kBombTimer];
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


@end
