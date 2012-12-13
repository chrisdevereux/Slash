Slash
=====

Slash is a **simple**, **extensible** markup language that eases the creation of NSAttributedStrings. The language is similar in appearance to HTML, *however* the meaning of each tag is user-defined.


Usage
-----
The first paragraph of this readme, with its gratutious formatting, might be expressed in Slash using the markup:

````html
<h1>Slash</h1>
Slash is a <strong>simple</strong>, <strong>extensible</strong> markup language that simplifies the creation of NSAttributedStrings. The language is similar in appearance to HTML, <emph>however</emph> the meaning of each tag is user-defined.
````

We can create a new NSAttributedString from this markup with the oneliner:

````objective-c    
NSAttributedString* myAttributedString = [SLSMarkupParser attributedStringFromMarkup:markup error:NULL];
````

The resulting string will be formatted much as if you'd dropped the equivalent HTML into a browser.

By default, Slash provides the following tags:

* h1
* h2
* h3
* h4
* h5
* h6
* emph
* strong

To customize the appearance of these tags, define additional tags, or use a completely different set of tags, pass in a dictionary defining an attributes dictionary for each tag.

 ```objective-c
NSDictionary *tagDefinitions = @{
    @"$default" : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue" size:14]},
    @"strong"   : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Bold" size:14]},
    @"emph"     : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Italic" size:14]},
    @"h1"       : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Medium" size:48]},
    @"h2"       : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Medium" size:36]},
    @"h3"       : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Medium" size:32]},
    @"h4"       : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Medium" size:24]},
    @"h5"       : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Medium" size:18]},
    @"h6"       : @{NSFontAttributeName  : [UILabel fontWithName:@"HelveticaNeue-Medium" size:16]}

NSAttributedString* myAttributedString = [SLSMarkupParser attributedStringFromMarkup:markup withTagDefinitions:tagDefinitions error:NULL];
};
````

When a piece of text belongs to multiple elements, the attributes applied will be the union of each tag's dictionary. You can provide whatever attributes you want. For a list of attributes supported by the Cocoa/Cocoa Touch text rendering system, see the documentation for [iOS][1] or [OSX][2].

[1]: http://developer.apple.com/library/ios/#Documentation/UIKit/Reference/NSAttributedString_UIKit_Additions/Reference/Reference.html
[2]: https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/AttributedStrings/Articles/standardAttributes.html#//apple_ref/doc/uid/TP40004903-SW2


Installation
------------

    git checkout https://github.com/chrisdevereux/Slash.git

* Add Slash.xcodeproj as a child project
* Add Slash-iOS or Slash-OSX as a project dependency
* Link with libSlash-iOS.a or libSlash-OSX.a
* Add to your project's header search paths


License
-------

Slash is released under the MIT license.


Contact
-------
Chris Devereux

devereux.chris@gmail.com
