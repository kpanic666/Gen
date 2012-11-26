//
//  BubbleCell.m
//  Gen
//
//  Created by Andrey Korikov on 14.08.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "BubbleCell.h"
#import "GameState.h"

@interface BubbleCell()
{
    float topBorder;
}

@end

@implementation BubbleCell

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    shape.m_radius = self.contentSize.width / 2 / PTM_RATIO;
    fixtureDef.shape = &shape;
    fixtureDef.isSensor = TRUE;
    fixtureDef.filter.categoryBits = kBubbleCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bubbleCell.png"]];
        topBorder = ([[CCDirector sharedDirector] winSize].height + self.contentSize.height) / PTM_RATIO;
        gameObjectType = kEnemyTypeBubble;
        characterState = kStateIdle;
        characterHealth = kChildCellHealth;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    if (characterState == kStateDead || characterState == kStateIdle) {
        return;
    }
    if ((characterState == kStateTakingDamage) && ([self numberOfRunningActions] > 0)) {
        return;
    }
    
    if (characterState == kStateTraveling) {
        // Если еще нет созданных джойнтов (поиманных ячеек), то притягиваем пойманную ячейку в центр пузыря и создаем джойнт
        if (![self wasUsed]) {
            [self connectChildCell];
        }
        
        // С постоянной силой двигаем пузырь вверх до верхней границы экрана. Если выходит за границу - уничтожаем
        if (body->GetPosition().y < topBorder)
        {
            float yForce = 1.0;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                yForce *= 2;
            }
            body->ApplyForceToCenter(b2Vec2(0,yForce));
        }
        else
        {
            [self changeState:kStateTakingDamage];
        }
    }
    
    if ([self numberOfRunningActions] == 0 && characterHealth <= 0) {
        [self changeState:kStateDead];
    }
}

- (void)connectChildCell
{
    // притягиваем пойманную ячейку в центр пузыря и создаем джойнт
    for (CCSprite *tempSprite in [[self parent] children]) {
        // Притягиваем детей к главному герою
        if ([tempSprite isKindOfClass:[Box2DSprite class]])
        {
            Box2DSprite *spriteObj = (Box2DSprite*)tempSprite;
            if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateBubbling)
            {
                [self setWasUsed:YES];
                
                // Change body type to dynamic body
                body->SetType(b2_dynamicBody);
                
                // Revolute Joint between ChildCell and BubbleCell Creation. Чтобы закрепить по центру
                b2RevoluteJointDef ropeJointDef;
                ropeJointDef.bodyA = body;
                ropeJointDef.bodyB = spriteObj.body;
                ropeJointDef.localAnchorA.SetZero();
                ropeJointDef.localAnchorB.SetZero();
                ropeJointDef.collideConnected = false;
                ropeJointDef.userData = @"BubbleJoint";
                world->CreateJoint(&ropeJointDef);
                
                return;
            }
        }
    }
}

- (void)removeBubbleSprite {
    [self setIsActive:FALSE];
    [self removeFromParentAndCleanup:YES];
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
            // Останавливаем ускорение
            body->SetLinearDamping(25);
            
            // Restore Physics state of connected ChildCells and stop them after destroying bubble
            for (b2JointEdge *edge = body->GetJointList(); edge; edge = edge->next)
            {
                Box2DSprite *childCell = (Box2DSprite*) edge->joint->GetBodyB()->GetUserData();
                if ([childCell gameObjectType] == kChildCellType) {
                    if (body->GetPosition().y < topBorder)
                    {
                        [childCell changeState:kStateIdle];
                    }
                    else
                    {
                        [childCell changeState:kStateTakingDamage];
                    }
                }
            }
            
            // Count number of destroyed cells for all time for achievement
            if ([GameState sharedInstance].bubblesPoped < kAchievementBubblepopperNum) {
                [GameState sharedInstance].bubblesPoped++;
            }
            
            characterHealth -= kRedCellDamage;
            // Destroy Physics body
            markedForDestruction = TRUE;
            
            break;
        }
            
        case kStateIdle:
            
            break;
            
        case kStateDead:
        {
            PLAYSOUNDEFFECT(@"BUBBLECELL_PRESSED");
            
            // Create particles when Bubble pop ups
            CCParticleSystemQuad *psPopUpBubble = [CCParticleSystemQuad particleWithFile:@"ps_popUpBubble.plist"];
            psPopUpBubble.position = self.position;
            [[[self parent] parent] addChild:psPopUpBubble z:5];
            
            CCSequence *dyingFade = [CCSequence actions:
                                     [CCHide action],
                                     [CCDelayTime actionWithDuration:1],
                                     [CCCallFunc actionWithTarget:self selector:@selector(removeBubbleSprite)],
                                     nil];
            [self runAction:dyingFade];
            break;
        }
            
        case kStateTraveling:
            // Когда один из ChildCell прикосается к пузырю, он входит в это состояние
            // И начинает лететь вверх увлекая за собой этот ChildCell
        {
            // Actions
            PLAYSOUNDEFFECT(@"BUBBLECELL");
            id scaleAction = [CCScaleBy actionWithDuration:0.4 scaleX:1.3 scaleY:0.8];
            id scaleSeqAction = [CCSequence actions:scaleAction, [scaleAction reverse], nil];
            [self runAction:[CCRepeatForever actionWithAction:scaleSeqAction]];
        }
            break;
            
        default:
            break;
    }
}

@end
