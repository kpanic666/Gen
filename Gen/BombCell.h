//
//  BobmCell.h
//  Gen
//  Как обычная ячейка, только взрывается через промежуток времени после активации и раскидывает другие ячейки
//  Created by Andrey Korikov on 20.07.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ChildCell.h"

@interface BombCell : ChildCell
{
    BOOL activated;
}

@end
