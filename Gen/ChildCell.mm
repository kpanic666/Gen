//
//  ChildCell.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ChildCell.h"
#import "GameManager.h"
#import "GameState.h"
#import "GB2ShapeCache.h"

@implementation ChildCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    bodyDef.linearDamping = 0.1f;
    bodyDef.allowSleep = FALSE;
	body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    // add the fixture definitions to the body
	[[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:[self foodTextureName]];
    [self setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:[self foodTextureName]]];
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

            [self removeFromParentAndCleanup:YES];
        }
    }
    
    if (characterState == kStateBubbling)
    {
        int i = 0;
        
        // Уничтожаем все джойнты кроме RevoluteJoint
        for (b2JointEdge *edge = body->GetJointList(); edge; edge = edge->next)
        {
            if (edge->joint->GetUserData() != @"BubbleJoint") {
                world->DestroyJoint(edge->joint);
            }
            else
            {
                i++;
            }
        }
        
        if (i>0) {
            [self changeState:kStateBubbled];
        }
    }
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        _dontCount = false;
        // Выбираем рэндомную текстуру еды для объекта и сохраняем в глобальную переменную для дальнейшего использования
        NSString *foodNames[] = {
            @"food_apple",
            @"food_bigmac",
            @"food_cake",
            @"food_fish",
            @"food_fry",
            @"food_hotdog",
            @"food_weed",
            @"food_chicken"
        };
        [self setFoodTextureName:foodNames[rand()%8]];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[self foodTextureName] stringByAppendingString:@".png"]]];
        [self setPosition:location];
        gameObjectType = kChildCellType;
        characterState = kStateSpawning;
        characterHealth = kChildCellHealth;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void) removeCellSprite {
    
    [self setIsActive:FALSE];
    [self removeFromParentAndCleanup:YES];
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
            if (_dontCount == false) {
                [GameManager sharedGameManager].numOfTotalCells--;
            }
            
            // Count number of destroyed cells for all time for achievement
            if ([GameState sharedInstance].cellsKilled < kAchievementCellDestroyerNum) {
                [GameState sharedInstance].cellsKilled++;
            }
        
            PLAYSOUNDEFFECT(@"CHILDCELL_DYING_1");
            break;
        }
            
        case kStateConnecting:
            // Клетка уже в зоне действия сенсора ParentCell, но джойнта еще нет
            break;
            
        case kStateConnected:
        {
            // Нужно менять вид клетки. Это состояние принимается клеткой когда был создан джойнт
            PLAYSOUNDEFFECT(@"CHILDCELL_CONNECTED");
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[self foodTextureName] stringByAppendingString:@"_prsd.png"]]];
            break;
        }
            
        case kStateDisconnecting:
            // Клетка вышла из зоны действия сенсора, но джойнт еще не разорван
            break;
            
        case kStateIdle:
        {
            // Меняется внешний вид клетки на обычный. В этом состояний объект может продолжать двигаться по инерции,
            // но на нее уже не влияет игрок.
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[self foodTextureName] stringByAppendingString:@".png"]]];
            
            // Если настройки фильтрации коллизий остались после пузыря, то меняем их на исходные и останавливаем ячейку
            b2Fixture *childFixture = body->GetFixtureList();
            b2Filter childFilter = childFixture->GetFilterData();
            if (childFilter.categoryBits == kBubbledChildCellFilterCategory)
            {
                childFilter.categoryBits = kChildCellFilterCategory;
                childFilter.maskBits = 0xFFFF ^ kBubbledChildCellFilterCategory;
                childFixture->SetFilterData(childFilter);
                
                // Останавливаем ускорение ячейки
                body->SetLinearVelocity(b2Vec2_zero);
                body->SetAngularVelocity(0);
            }
            break;
        }
            
        case kStateBeforeSoul:
        {
            self.markedForDestruction = YES;
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[self foodTextureName] stringByAppendingString:@".png"]]];
            if (_dontCount == false) {
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
            float travelTime = CCRANDOM_0_1() + 1;
            float rotateTime = CCRANDOM_0_1() * 2;
            float rotateAngle = 360;
            if (CCRANDOM_0_1() <= 0.5f) rotateAngle *= -1;
            CGRect cellBB = [self adjustedBoudingBox];
            int yRandPosAtSceen = cellBB.origin.y + random() % (int)cellBB.size.height;
            int xRandPosAtSceen = cellBB.origin.x + random() % (int)cellBB.size.width;
            
            // Change sprite frame to stale frame for apropriate food
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[self foodTextureName] stringByAppendingString:@"_stale.png"]]];
            
            
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
            
        case kStateBubbling:
        {
            // Останавливаем ускорение ячейки
            body->SetLinearVelocity(b2Vec2_zero);
            body->SetAngularVelocity(0);
            
            // Меняем фильтры столкновений, чтобы ячейки сталкивались только с красными стенами
            b2Fixture *childFixture = body->GetFixtureList();
            b2Filter childFilter = childFixture->GetFilterData();
            childFilter.categoryBits = kBubbledChildCellFilterCategory;
            childFilter.maskBits = kRedCellFilterCategory;
            childFixture->SetFilterData(childFilter);
            
            break;
        }
            
        case kStateBubbled:
        {
            
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
