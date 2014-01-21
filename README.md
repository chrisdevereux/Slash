Slash
===== 
[![Build Status](https://travis-ci.org/chrisdevereux/Slash.png?branch=master)](https://travis-ci.org/chrisdevereux/Slash)

Slash is a **simple**, **extensible** markup language for styling NSAttributedStrings. The language is similar in appearance to HTML, however the meaning of each tag is user-defined.


Usage
-----
The first paragraph of this readme might be expressed in Slash using the markup:

````html
<h1>Slash</h1>
Slash is a <strong>simple</strong>, <strong>extensible</strong> markup language 
that simplifies the creation of NSAttributedStrings. The language is similar in 
appearance to HTML, however the meaning of each tag is user-defined.
````

We can create a new NSAttributedString from this markup with:

````objective-c    
NSAttributedString *myAttributedString = [SLSMarkupParser attributedStringWithMarkup:markup error:NULL];
````

The resulting string will be formatted much as if you'd dropped the equivalent HTML into a browser.

On OS X and iOS 6.0 onwards, Slash provides the following tags:

* h1
* h2
* h3
* h4
* h5
* h6
* em
* strong

To customize the appearance of these tags, define additional tags, or use a completely different set of tags, pass in a dictionary defining an attributes dictionary for each tag.

 ```objective-c
NSDictionary *style = @{
    @"$default" : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue" size:14]},
    @"strong"   : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]},
    @"em"       : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Italic" size:14]},
    @"h1"       : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:48]},
    @"h2"       : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:36]},
    @"h3"       : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:32]},
    @"h4"       : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:24]},
    @"h5"       : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:18]},
    @"h6"       : @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Medium" size:16]}
};

NSAttributedString *myAttributedString = [SLSMarkupParser attributedStringWithMarkup:markup style:style error:NULL];
````

When a piece of text belongs to multiple elements, the attributes applied will be the union of each tag's dictionary, with the innermost elements' attributes taking priority. For a list of attributes supported by the Cocoa/Cocoa Touch text rendering system, see the documentation for [iOS][1] or [OSX][2].

Note that the linked attributes are only supported on iOS from 6.0 onwards.

[1]: http://developer.apple.com/library/ios/#Documentation/UIKit/Reference/NSAttributedString_UIKit_Additions/Reference/Reference.html
[2]: https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/AttributedStrings/Articles/standardAttributes.html#//apple_ref/doc/uid/TP40004903-SW2


Installation
------------

### Using CocoaPods

* Add `pod 'slash'` to your podfile
* `#import <Slash/Slash.h>`

### As an Xcode Subproject

    
 


    git clone https://github.com/chrisdevereux/Slash.git

* Add Slash.xcodeproj as a child project
* Add Slash-iOS or Slash-OSX as a project dependency
* Link with libSlash-iOS.a or libSlash-OSX.a
* Add `$(BUILT_PRODUCTS_DIR)/include` to your project's header search paths (if it isn't already there)
* `#import <Slash/Slash.h>`


Requirements
------------

iOS 4.3 or OS X 10.6 (64 bit) upwards.

Attributed string handling is limited prior to iOS 6, and certain features of Slash require iOS 6. Be sure to check the header documentation if you are targeting earlier. You will also need to use a custom view (such as [NIAttributedLabel][3] or [TTTAttributedLabel][4]) to display the strings, and the format required of the attribute dictionaries in your style will be defined by that view.

[3]: http://docs.nimbuskit.info/NimbusAttributedLabel.html
[4]: https://github.com/mattt/TTTAttributedLabel


Performance
------------

Constructing a 200 character attributed string with 5 tagged sections takes approximately 0.5ms on an iPad 3rd gen when built in release mode. If you are parsing large strings, consider doing so on a background queue.


License
-------

Slash is released under an MIT license.


Contact
-------
Chris Devereux

devereux.chris@gmail.com
