//
//  TKStateSpec.m
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

#import "Kiwi.h"
#import "TKState.h"

SPEC_BEGIN(TKStateSpec)

describe(@"stateWithName:entryBlock:exitBlock:", ^{
    context(@"when called with a `nil` name", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [TKState stateWithName:nil];
            }) should] raiseWithName:NSInvalidArgumentException];
        });
    });
    
    context(@"when called with a blank name", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [TKState stateWithName:@""];
            }) should] raiseWithName:NSInvalidArgumentException];
        });
    });
});

describe(@"isEqual:", ^{
    __block TKState *stateA0 = [TKState stateWithName:@"A"];
    __block TKState *stateA1 = [TKState stateWithName:@"A"];
    __block TKState *copiedStateA = [stateA0 copy];
    __block TKState *stateB = [TKState stateWithName:@"B"];

    context(@"when compared to state with same name", ^{
        it(@"returns YES", ^{
            [[theValue([stateA0 isEqual:stateA0]) should] beTrue];
            [[theValue([stateA0 isEqual:stateA1]) should] beTrue];
            [[theValue([stateA1 isEqual:stateA0]) should] beTrue];
            [[theValue([stateA0 isEqual:copiedStateA]) should] beTrue];
            [[theValue([stateA1 isEqual:copiedStateA]) should] beTrue];
        });
    });
    
    context(@"when compared to another state", ^{
        it(@"returns NO", ^{
            [[theValue([stateA0 isEqual:stateB]) should] beFalse];
            [[theValue([stateA1 isEqual:stateB]) should] beFalse];
            [[theValue([copiedStateA isEqual:stateB]) should] beFalse];
        });
    });
});



SPEC_END
