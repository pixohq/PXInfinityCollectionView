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
    
    CGFloat contentWidth = scrollView.contentSize.width;
    CGFloat cellWidth = scrollView.bounds.size.width;
    CGPoint contentOffset = scrollView.contentOffset;
    
    if (contentWidth < cellWidth) return;
    
    if (scrollView.contentOffset.x <= 0.f) {
        [scrollView setContentOffset:CGPointMake(contentWidth - (cellWidth * 2.f) + contentOffset.x, contentOffset.y)
                            animated:NO];
    } else if (scrollView.contentOffset.x + cellWidth >= scrollView.contentSize.width) {
        [scrollView setContentOffset:CGPointMake((cellWidth * 2.f) + contentOffset.x - contentWidth, contentOffset.y)
                            animated:NO];
    }
}

@implementation UIView (Swizzle)

+ (void)load {
    swizzle(NSClassFromString(@"_UICollectionViewOrthogonalScrollerSectionController"), @selector(scrollViewDidScroll:), (IMP)&custom_UICollectionViewOrthogonalScrollerSectionController_scrollViewDidScroll, (IMP *)&original_UICollectionViewOrthogonalScrollerSectionController_scrollViewDidScroll);
}

@end
