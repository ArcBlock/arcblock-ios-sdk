//
//  UIView+KVBinding.m
//  PixoClub
//
//  Created by Robert Mao on 1/7/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import "UIView+KVBinding.h"
#import <objc/runtime.h>

static char const * const UndefinedObjectsDictKey = "UndefinedObjectsDict";

@implementation UIView (KVBinding)

+ (UIView*) viewFromNib:(NSString*)nibName
{
    if (nibName != nil) {
        UIView* view =  [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] lastObject];
        
        if ([view isKindOfClass:[UIView class]])
            return view;
    }
    return nil;
}

#pragma mark - Overrides

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    // see if the UndefinedObjects dictionary exists, if not, create it
    NSMutableDictionary *undefinedDict = nil;
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
    }
    else {
        undefinedDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, UndefinedObjectsDictKey, undefinedDict, OBJC_ASSOCIATION_RETAIN);
    }
    [undefinedDict setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key {
    
    NSMutableDictionary *undefinedDict = nil;
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
        return [undefinedDict valueForKey:key];
    }
    else {
        return nil;
    }
}

#pragma mark - Public Methods

- (void)bindWithObject:(id)obj {
    
    // first check ourselves for any bindable properties. Then process our
    // children.
    NSArray *undefinedKeys = [self undefinedKeys];
    if ( undefinedKeys ) {
        for ( NSString *key in undefinedKeys ) {
            // only bind things that start with the lowercase bind string
            if ( ( [key length] > 4 ) && [[key substringToIndex:4] isEqualToString:@"bind"] ) {
                
                NSString *keyToBind = [key substringFromIndex:4];
                NSString *keyValue = [self valueForKey:key];
                
                id value = nil;
                
                if ([keyValue componentsSeparatedByString:@","].count > 1) { // value to bind is a string composed by multiple values in obj
                    value = [self getFormattedStringWithKey:keyValue inObject:obj];
                }
                else {
                    value = [self getValueWithKey:keyValue inObject:obj];
                }
                
                // Value could be NSNull returned from object model, we also treat it as nil
                if ((value != nil) && (value != [NSNull null]) && [value isKindOfClass:[NSObject class]]) {
                    [self setValue:value forKey:keyToBind];
                }
                else {
                    //NSLog(@"Binding Error: %@ don't have value for key:%@", obj, keyValue);
                    [self setValue:nil forKey:keyToBind];
                }
            }
        }
    }
    
    for ( UIView *subview in [self subviews] ) {
        [subview bindWithObject:obj];
    }
}

- (id)getValueWithKey:(NSString*)key inObject:(id)object
{
    NSArray *paths = [key componentsSeparatedByString:@"."];
    id value = object;
    for (NSString *path in paths) {
        if ([value isKindOfClass:[NSDictionary class]] || [value respondsToSelector:NSSelectorFromString(path)]) {
            value = [value valueForKey:path];
        }
        else {
            break;
        }
    }
    return value == object ? nil : value;
}

- (NSString*)getFormattedStringWithKey:(NSString*)key inObject:(id)object
{
    NSMutableString *value;
    NSMutableArray *components = [NSMutableArray arrayWithArray:[key componentsSeparatedByString:@","]];
    
    NSString *format = components[0];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%@" options:NSRegularExpressionCaseInsensitive error:&error];
    NSInteger numberOfPlaceholders = [regex numberOfMatchesInString:format options:0 range:NSMakeRange(0, format.length)];
    
    [components removeObjectAtIndex:0];
    
    if (numberOfPlaceholders && components.count && numberOfPlaceholders == components.count) {
        value = [NSMutableString stringWithString:format];
        for (int i = 0; i < components.count; i++) {
            NSRange range = [value rangeOfString:@"%@"];
            id component = [self getValueWithKey:components[i] inObject:object];
            if ([component isKindOfClass:[NSString class]]) {
                [value replaceCharactersInRange:range withString:component];
            }
            else if ([component respondsToSelector:@selector(stringValue)]){
                [value replaceCharactersInRange:range withString:[component stringValue]];
            }
            else {
                [value replaceCharactersInRange:range withString:@""];
            }
        }
    }
    return value;
}

#pragma mark - Private Methods
- (NSArray *)undefinedKeys {
    
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        NSDictionary *undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
        return [undefinedDict allKeys];
    }
    else {
        return nil;
    }
}

@end

@implementation UIBarButtonItem (KVBinding)

#pragma mark - Overrides

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    // see if the UndefinedObjects dictionary exists, if not, create it
    NSMutableDictionary *undefinedDict = nil;
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
    }
    else {
        undefinedDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, UndefinedObjectsDictKey, undefinedDict, OBJC_ASSOCIATION_RETAIN);
    }
    [undefinedDict setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key {
    
    NSMutableDictionary *undefinedDict = nil;
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
        return [undefinedDict valueForKey:key];
    }
    else {
        return nil;
    }
}


#pragma mark - Private Methods
- (NSArray *)undefinedKeys {
    
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        NSDictionary *undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
        return [undefinedDict allKeys];
    }
    else {
        return nil;
    }
}

@end
