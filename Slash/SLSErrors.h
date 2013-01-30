//
//  SLSErrors.h
//  Slash
//
//  Created by Chris Devereux on 29/01/2013.
//  Copyright (c) 2013 ChrisDevereux. All rights reserved.
//

typedef enum {
    kSLSSyntaxError = 1,
    kSLSUnknownTagError
} SLSErrorCode;

OBJC_EXTERN NSString * const SLSErrorDomain;
