#import "DATASourceCollectionHeaderView.h"

NSString * const DATASourceCollectionHeaderViewIdentifier = @"DATASourceCollectionHeaderViewIdentifier";

@interface DATASourceCollectionHeaderView()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *separatorView;

@end

@implementation DATASourceCollectionHeaderView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.separatorView];
    }

    return self;
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat margin = 0.0;
        CGRect frame = CGRectMake(margin, 0.0, self.frame.size.width - (margin * 2.0), self.frame.size.height - 2.0);
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        _titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
    }

    return _titleLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 10.0, self.frame.size.width, 1.0)];
        _separatorView.backgroundColor = [UIColor blackColor];
    }

    return _separatorView;
}

#pragma mark - Public methods

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
