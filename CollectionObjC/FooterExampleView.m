#import "FooterExampleView.h"

NSString * const FooterExampleViewIdentifier = @"FooterExampleViewIdentifier";

@implementation FooterExampleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        sampleLabel.text = @"I'm a custom footer!";
        [self addSubview:sampleLabel];

        self.backgroundColor = [UIColor lightGrayColor];
    }

    return self;
}

@end
