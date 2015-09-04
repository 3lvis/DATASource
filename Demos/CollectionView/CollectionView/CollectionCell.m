#import "CollectionCell.h"

NSString * const CollectionCellIdentifier = @"CollectionCellIdentifier";

@interface CollectionCell ()

@property (nonatomic) UILabel *textLabel;

@end

@implementation CollectionCell

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }

    return _textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.textLabel];
        self.contentView.layer.borderWidth = 1.0;
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }

    return self;
}

- (void)updateWithText:(NSString *)text {
    self.textLabel.text = text;
}

@end
