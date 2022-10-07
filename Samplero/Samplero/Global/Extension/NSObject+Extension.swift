//
//  NSObject+Extension.swift
//  HelloRxSwift
//
//  Created by Minkyeong Ko on 2022/10/06.
//

import Foundation

extension NSObject {    // NSObjet는 모든 클래스의 부모 클래스
    static var className: String {  // 클래스의 이름을 바로 String으로 출력
        return String(describing: self)
    }
}
