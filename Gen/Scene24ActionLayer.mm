//
//  Scene24ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene24ActionLayer.h"

@interface Scene24ActionLayer()
{
    id cellsArray[2][2];
}
@end

@implementation Scene24ActionLayer

- (void)makeCubeWithDimention:(int)dim offset:(float)offset atPos:(CGPoint)startPos
{
    // Создаем куб и заполняем массив для дальнейшего связывания ячеек джойнтами
    for (int r=0; r < dim; r++)
    {
        for (int c=0; c < dim; c++)
        {
            cellsArray[c][r] = [self createChildCellAtLocation:ccpAdd(startPos, ccp(offset * c, -offset * r))];
        }
    }
    
    // Соединяем элементы куба между собой RevoluteJoint'ами
    b2DistanceJointDef disJointDef;
    disJointDef.localAnchorA.SetZero();
    disJointDef.localAnchorB.SetZero();
    for (int r=0; r < dim; r++)
    {
        for (int c=0; c < dim; c++)
        {
            // Соединяем ячейку с предыдущей в ряду
            if (c > 0)
            {
                ChildCell *tempCell = (ChildCell*)cellsArray[c-1][r];
                disJointDef.bodyA = tempCell.body;
                tempCell = (ChildCell*)cellsArray[c][r];
                disJointDef.bodyB = tempCell.body;
                disJointDef.length = offset / PTM_RATIO;
                world->CreateJoint(&disJointDef);
            }
            // Соединяем ячейку с предыдущей в столбце
            if (r > 0)
            {
                ChildCell *tempCell = (ChildCell*)cellsArray[c][r-1];
                disJointDef.bodyA = tempCell.body;
                tempCell = (ChildCell*)cellsArray[c][r];
                disJointDef.bodyB = tempCell.body;
                disJointDef.length = offset / PTM_RATIO;
                world->CreateJoint(&disJointDef);
            }
            // Соединяем ячейки по диагонали для прочности.
            if (c > 0 && r > 0)
            {
                ChildCell *tempCell = (ChildCell*)cellsArray[c-1][r-1];
                disJointDef.bodyA = tempCell.body;
                tempCell = (ChildCell*)cellsArray[c][r];
                disJointDef.bodyB = tempCell.body;
                // Вычисляем длину гиппотенузы
                disJointDef.length = sqrtf(2 * offset * offset) / PTM_RATIO;
                world->CreateJoint(&disJointDef);
            }
        }
    }
}

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background2.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ChildCells
        float offset = 25; // Расстояние между элементами куба (между ячейками)
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offset *= 2;
        }
        cellPos = [Helper convertPosition:ccp(50, 46)]; // Top left corner of Cube
        [self makeCubeWithDimention:2 offset:offset atPos:cellPos];
        ChildCell *leftTopCell = (ChildCell*)cellsArray[1][1];
        cellPos = [Helper convertPosition:ccp(50, 362)]; // Top left corner of Cube
        [self makeCubeWithDimention:2 offset:offset atPos:cellPos];
        ChildCell *leftBottomCell = (ChildCell*)cellsArray[1][0];
        cellPos = [Helper convertPosition:ccp(532, 46)]; // Top left corner of Cube
        [self makeCubeWithDimention:2 offset:offset atPos:cellPos];
        ChildCell *rightTopCell = (ChildCell*)cellsArray[0][1];
        cellPos = [Helper convertPosition:ccp(532, 362)]; // Top left corner of Cube
        [self makeCubeWithDimention:2 offset:offset atPos:cellPos];
        ChildCell *rightBottomCell = (ChildCell*)cellsArray[0][0];
        
        // Связываем вместе малькие кубы по 4 ячейки
        float longSide = offset * 8 / PTM_RATIO;
        float shortSide = offset * 6 / PTM_RATIO;
        b2DistanceJointDef disJointDef;
        disJointDef.localAnchorA.SetZero();
        disJointDef.localAnchorB.SetZero();
        // Left side
        disJointDef.length = shortSide;
        disJointDef.bodyA = leftTopCell.body;
        disJointDef.bodyB = leftBottomCell.body;
        world->CreateJoint(&disJointDef);
        // Right
        disJointDef.bodyA = rightBottomCell.body;
        disJointDef.bodyB = rightTopCell.body;
        world->CreateJoint(&disJointDef);
        // Bottom
        disJointDef.length = longSide;
        disJointDef.bodyA = leftBottomCell.body;
        disJointDef.bodyB = rightBottomCell.body;
        world->CreateJoint(&disJointDef);
        // Top
        disJointDef.bodyA = rightTopCell.body;
        disJointDef.bodyB = leftTopCell.body;
        world->CreateJoint(&disJointDef);
        // Гиппотенуза
        disJointDef.length = sqrtf(shortSide*shortSide + longSide*longSide);
        disJointDef.bodyA = leftTopCell.body;
        disJointDef.bodyB = rightBottomCell.body;
        world->CreateJoint(&disJointDef);
        
        [[GameManager sharedGameManager] setNumOfMaxCells:[GameManager sharedGameManager].numOfTotalCells];
    }
    return self;
}

@end
