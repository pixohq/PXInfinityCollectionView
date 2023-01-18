//
//  UIView+swizzle.m
//  PXInfinityCollectionView
//
//  Created by Jinwoo Kim on 12/26/22.
//

#import "UIView+swizzle.h"
#import "swizzle.h"
#import <objc/message.h>

void (*original_UICollectionViewOrthogonalScrollerSectionController_scrollViewDidScroll)(id controller, SEL cmd, UIScrollView *scrollView);
void custom_UICollectionViewOrthogonalScrollerSectionController_scrollViewDidScroll(id controller, SEL cmd, UIScrollView *scrollView) {
    original_UICollectionViewOrthogonalScrollerSectionController_scrollViewDidScroll(controller, cmd, scrollView);
    
}

@implementation UIView (Swizzle)

+ (void)load {
    
}

@end
