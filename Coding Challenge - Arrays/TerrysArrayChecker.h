//
//  TerrysArrayChecker.h
//  Coding Challenge - Arrays
//
//  Created by Aditya Narayan on 10/3/14.
//  Copyright (c) 2014 NM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TerrysArrayChecker : NSObject


- (BOOL) isThisArraySorted:(NSMutableArray *) someArray;

- (void) sortAscending:(NSMutableArray *) someArray;

- (void) sortDescending:(NSMutableArray *) someArray;


@end
