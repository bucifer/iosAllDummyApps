//
//  TerryNumberChecker.h
//  PrimePerfectSquare
//
//  Created by Aditya Narayan on 10/6/14.
//  Copyright (c) 2014 NM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TerryNumberChecker : NSObject

- (BOOL) isItPrime:(int)num;
- (BOOL) isItPerfectSquare:(int)num;

- (int) myFactorial:(int)num;
- (int) sumOfFirstN:(int)N;
- (double) fibonacci: (long)n cacheArray:(double[])myCacheArray;

- (void) reverseArrayWithRecursion:(NSMutableArray *)someArray startIndex:(int)first endIndex:(int)end;



@end
