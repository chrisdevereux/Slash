//
//  SLSMarkupParser.m
//  Slash
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 Chris Devereux. All rights reserved.
//

#import "SLSMarkupParser.h"
#import "SLSTagParser.h"
#import "SLSTaggedRange.h"
#import "SLSErrors.h"

#import <CoreText/CoreText.h>
#import <dlfcn.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define SUPPORTS_STANDARD_ATTRIBUTES (dlsym(RTLD_DEFAULT, "NSFontAttributeName") != NULL)
#define BRIDGED_CT_FONT (NSClassFromString(@"UIFontDescriptor") != NULL)
#define FONT_CLASS UIFont
#define COLOR_CLASS UIColor

#else
#import <AppKit/AppKit.h>
#define SUPPORTS_STANDARD_ATTRIBUTES YES
#define BRIDGED_CT_FONT YES
#define FONT_CLASS NSFont
#define COLOR_CLASS NSColor

#endif

#define SetError(ptr, val) if (ptr){ *(ptr) = (val); }

static FONT_CLASS *
LookupFont(CGFloat pointSize, NSString *fontName, NSString *familyName, CTFontSymbolicTraits symbolicTraits)
{
    // https://github.com/chrisdevereux/Slash/issues/8
    // Font lookup via font name is unsafe on iOS versions > 7.
    // UIFont lookup via font descriptor is availible on iOS versions < 7.
    //
    // In order to safely lookup default fonts, use CTFontDescriptor where CTFont is bridged with UIFont,
    // otherwise fall back to lookup via font name.
    
    if (BRIDGED_CT_FONT) {
        NSDictionary *traits = @{(__bridge id)kCTFontSymbolicTrait: @(symbolicTraits)};
        NSDictionary *attributes = @{(__bridge id)kCTFontFamilyNameAttribute: familyName, (__bridge id)kCTFontTraitsAttribute: traits};
        
        CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes((__bridge void *)attributes);
        FONT_CLASS *font = CFBridgingRelease(CTFontCreateWithFontDescriptor(descriptor, pointSize, NULL));
        CFRelease(descriptor);
        
        return font;
    } else {
        return [FONT_CLASS fontWithName:fontName size:pointSize];
    }
}


@implementation SLSMarkupParser {
    NSDictionary *_styleDictionary;
}


+ (NSDictionary *)defaultAttributes
{
    static NSDictionary *attributes;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (SUPPORTS_STANDARD_ATTRIBUTES) {
            attributes = @{
                NSFontAttributeName             : LookupFont(14, @"HelveticaNeue", @"Helvetica Neue", 0),
                NSForegroundColorAttributeName  : [COLOR_CLASS blackColor],
                NSKernAttributeName             : @0,
                NSParagraphStyleAttributeName   : [NSParagraphStyle defaultParagraphStyle],
                NSStrokeColorAttributeName      : [COLOR_CLASS blackColor],
                NSStrokeWidthAttributeName      : @0
            };
        } else {
            attributes = @{};
        }
    });

    return attributes;
}


+ (NSDictionary *)defaultStyle
{
    static NSDictionary *style;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!SUPPORTS_STANDARD_ATTRIBUTES) {
            NSLog(@"Warning: [SLSMarkupParser defaultStyle] is only supported on iOS versions >= 6.0. You should provide a dictionary of Core Text attributes suitable for your custom text view.");
            return;
        }
        
        style = @{
            @"$default" : [self defaultAttributes],
            @"strong"   : @{NSFontAttributeName  : LookupFont(14, @"HelveticaNeue-Bold", @"Helvetica Neue", kCTFontTraitBold)},
            @"em"       : @{NSFontAttributeName  : LookupFont(14, @"HelveticaNeue-Italic", @"Helvetica Neue", kCTFontTraitItalic)},
            @"emph"     : @{NSFontAttributeName  : LookupFont(14, @"HelveticaNeue-Italic", @"Helvetica Neue", kCTFontTraitItalic)},
            @"h1"       : @{NSFontAttributeName  : LookupFont(48, @"HelveticaNeue-Italic", @"Helvetica Neue", 0)},
            @"h2"       : @{NSFontAttributeName  : LookupFont(36, @"HelveticaNeue-Italic", @"Helvetica Neue", 0)},
            @"h3"       : @{NSFontAttributeName  : LookupFont(32, @"HelveticaNeue-Italic", @"Helvetica Neue", 0)},
            @"h4"       : @{NSFontAttributeName  : LookupFont(24, @"HelveticaNeue-Italic", @"Helvetica Neue", 0)},
            @"h5"       : @{NSFontAttributeName  : LookupFont(18, @"HelveticaNeue-Italic", @"Helvetica Neue", 0)},
            @"h6"       : @{NSFontAttributeName  : LookupFont(16, @"HelveticaNeue-Italic", @"Helvetica Neue", 0)}
        };
    });
    
    return style;
}


+ (NSDictionary *)styleDictionaryByApplyingDefaultAttributes:(NSDictionary *)defaultAttributes toDictionary:(NSDictionary *)userStyle
{
    NSMutableDictionary *defaultTagStyle = [defaultAttributes mutableCopy];
    [defaultTagStyle setValuesForKeysWithDictionary:[userStyle objectForKey:@"$default"]];
    
    NSMutableDictionary *result = [userStyle mutableCopy];
    [result setObject:defaultTagStyle forKey:@"$default"];
    
    return result;
}


+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)string style:(NSDictionary *)style error:(NSError **)error
{
    if (!string || [string length] == 0) {
        return [[NSAttributedString alloc] init];
    }
    
    // Workaround for bug in UITextField. See: https://github.com/chrisdevereux/Slash/issues/4s
    NSDictionary *styleWithDefaults = [self styleDictionaryByApplyingDefaultAttributes:[self defaultAttributes] toDictionary:style];
    
    SLSMarkupParser *parser = [[self alloc] initWithTagDictionary:styleWithDefaults];
    
    return [parser parseMarkup:string error:error];
}


+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)string error:(NSError **)error
{
    return [self attributedStringWithMarkup:string style:[self defaultStyle] error:error];
}




- (id)initWithTagDictionary:(NSDictionary *)tagDict
{
    self = [super init];
    if (!self)
        return nil;
    
    _styleDictionary = [tagDict copy];
    
    return self;
}


- (NSAttributedString *)parseMarkup:(NSString *)markup error:(NSError **)errorOut
{
    NSParameterAssert(markup);
    
    SLSTagParser *tagParser = [[SLSTagParser alloc] init];
    [tagParser parseMarkup:markup];
    
    if (tagParser.error) {
        SetError(errorOut, tagParser.error);
        return nil;
    }
    
    NSMutableAttributedString *styledText = tagParser.attributedString;

    if ([self applyTags:tagParser.taggedRanges toAttributedString:styledText error:errorOut]) {
        return styledText;
    } else {
        return nil;
    }
}


- (BOOL)applyTags:(NSArray *)tags toAttributedString:(NSMutableAttributedString *)styledText error:(NSError **)errorOut
{
    NSParameterAssert(tags);
    NSParameterAssert(styledText);
    NSAssert(_styleDictionary, @"Slash internal error: style dictionary should be defined");
    
    // Apply the default style to the whole string, then work inwards, applying the attributes defined for each tag
    // combined with the existing attributes.
    
    [styledText setAttributes:[_styleDictionary objectForKey:@"$default"] range:NSMakeRange(0, [styledText length])];
    
    for (SLSTaggedRange *tag in tags) {
        NSDictionary *tagAttributes = [_styleDictionary objectForKey:tag.tagName];
        
        if (!tagAttributes) {
            NSError *error = [NSError errorWithDomain:SLSErrorDomain code:kSLSUnknownTagError userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Unknown tag" , nil), tag.tagName]}];
            
            SetError(errorOut, error);
            return NO;
        }
        
        // Inner ranges are fully contained by by outer ranges, so assume attributes at
        // the beginning of the range apply to the entire range.
        
        [styledText addAttributes:tagAttributes range:tag.range];
    }
    
    return YES;
}

@end


NSString * const SLSErrorDomain = @"SLSErrorDomain";
