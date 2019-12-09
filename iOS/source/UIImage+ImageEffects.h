#import <UIKit/UIKit.h>

@interface UIImage (ImageEffects)

@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *applyLightEffect;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *applyExtraLightEffect;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end

