//
//  TKEvent.m
//  TransitionKit
//
//  Created by Blake Watters on 3/17/13.
//  Copyright (c) 2013 Blake Watters. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TKEvent.h"
#import "TKState.h"

static NSString *TKDescribeStates(NSArray *states)
{
    NSMutableString *description = [NSMutableString string];
    [states enumerateObjectsUsingBlock:^(TKState *state, NSUInteger idx, BOOL *stop) {
        NSString *separator = @"";
        if (idx < [states count] - 1) separator = (idx == [states count] - 2) ? @" and " : @", ";
        [description appendFormat:@"'%@'%@", state.name, separator];
    }];
    return description;
}


@interface TKEvent ()

@property (nonatomic, copy) NSString *name;

/**
 key -> sourceStates
 value -> destinationState
 */
@property (nonatomic) NSMutableDictionary<TKState*, TKState*> *transitionMap;

@property (nonatomic, copy) BOOL (^shouldFireEventBlock)(TKEvent *, TKTransition *);
@property (nonatomic, copy) void (^willFireEventBlock)(TKEvent *, TKTransition *);
@property (nonatomic, copy) void (^didFireEventBlock)(TKEvent *, TKTransition *);

@end

@implementation TKEvent

- (instancetype)initWithName:(NSString *)name
{
    if (![name length]) [NSException raise:NSInvalidArgumentException format:@"The event name cannot be blank."];
    
    self = [super init];
    if (self)
    {
        _name = name;
        _transitionMap = NSMutableDictionary.dictionary;
    }
    return self;
}

+ (instancetype)eventWithName:(NSString *)name
{
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name transitioningFromStates:(NSArray<TKState*> *)sourceStates toState:(TKState *)destinationState
{
    self = [self initWithName:name];
    if (self)
    {
        [self addTransitionFromStates:sourceStates toState:destinationState];
    }
    return self;
}

+ (instancetype)eventWithName:(NSString *)name transitioningFromStates:(NSArray<TKState*> *)sourceStates toState:(TKState *)destinationState
{
    return [[self alloc] initWithName:name transitioningFromStates:sourceStates toState:destinationState];
}

- (void)addTransitionFromStates:(NSArray<TKState*> *)sourceStates toState:(TKState *)destinationState
{
    if (![sourceStates count]) [NSException raise:NSInvalidArgumentException format:@"The source states cannot be nil or blank."];
    if (!destinationState) [NSException raise:NSInvalidArgumentException format:@"The destination state cannot be nil."];
    
    for (TKState *sourceState in sourceStates)
    {
        if (![sourceState isKindOfClass:[TKState class]])
        {
            [NSException raise:NSInvalidArgumentException format:@"Expected a `TKState` object, instead got a `%@` (%@)", [sourceState class], sourceState];
        }
        
        // make sure the source state is not yet registered
        if ([self sourceStateWithName:sourceState.name])
        {
            [NSException raise:NSInvalidArgumentException format:@"A source state named `%@` is already registered for the event `%@`", sourceState.name, self.name];
        }
        
        _transitionMap[sourceState] = destinationState;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p '%@' transitions from %@ to %@>", NSStringFromClass([self class]), self, self.name, TKDescribeStates(self.sourceStates), TKDescribeStates(self.destinationStates)];
}

#pragma mark - Accessors

- (NSArray*)sourceStates
{
    return _transitionMap.allKeys;
}

- (NSArray*)destinationStates
{
    return [NSOrderedSet orderedSetWithArray:_transitionMap.allValues].array;
}

- (TKState *)destinationStateForSourceState:(TKState *)sourceState
{
    return _transitionMap[sourceState];
}

#pragma mark - Private methods

- (TKState *)sourceStateWithName:(NSString *)name
{
    return [self stateWithName:name inStates:_transitionMap.allKeys];
}

- (TKState *)destinationStateWithName:(NSString *)name
{
    return [self stateWithName:name inStates:_transitionMap.allValues];
}

- (TKState *)stateWithName:(NSString *)name inStates:(NSArray *)states
{
    for (TKState *state in states)
    {
        if ([state.name isEqualToString:name])
        {
            return state;
        }
    }
    return nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _transitionMap = [aDecoder decodeObjectForKey:@"transitionMap"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_transitionMap forKey:@"transitionMap"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    TKEvent *copiedEvent = [[[self class] allocWithZone:zone] init];
    copiedEvent.name = self.name;
    copiedEvent.transitionMap = self.transitionMap;
    copiedEvent.shouldFireEventBlock = self.shouldFireEventBlock;
    copiedEvent.willFireEventBlock = self.willFireEventBlock;
    copiedEvent.didFireEventBlock = self.didFireEventBlock;
    return copiedEvent;
}

@end
