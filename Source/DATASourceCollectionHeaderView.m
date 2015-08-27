#import "DATASourceCollectionHeaderView.h"

NSString * const DATASourceCollectionHeaderViewIdentifier = @"DATASourceCollectionHeaderViewIdentifier";

@interface DATASourceCollectionHeaderView()

@property (nonatomic) UILabel *titleLabel;

@end

@implementation DATASourceCollectionHeaderView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self addSubview:self.titleLabel];
    }

    return self;
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat margin = 0.0;
        CGRect frame = CGRectMake(margin, 0.0, self.frame.size.width - (margin * 2.0), self.frame.size.height);
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        _titleLabel.font = [UIFont systemFontOfSize:18.0];
    }

    return _titleLabel;
}

#pragma mark - Public methods

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
