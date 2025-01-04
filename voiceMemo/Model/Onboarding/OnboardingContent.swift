//
//  OnboardingContent.swift
//  voiceMemo
//

import Foundation

struct OnboardingContent: Hashable { // 추후 탭뷰에서 사용되기 때문
    var imageFileName: String
    var title: String
    var subTitle: String
    
    init(imageFileName: String, title: String, subTitle: String) { // 초기 값을 줄 수 있고 추후에 여러 이니결라이저가 생길 수 있기 때문 -> 이걸 만들면 이거밖에 못쓰던가?
        self.imageFileName = imageFileName
        self.title = title
        self.subTitle = subTitle
    }
}
