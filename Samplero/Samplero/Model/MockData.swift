//
//  MockData.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import Foundation


#if DEBUG
struct MockData {

    static var sampleList: [Sample] = [
        Sample(id: 0,
               matName: "화이트마블",
               imageName: "WhiteMarble",
               matPrice: 12_000,
               samplePrice: 5_000,
               material: "TPU",
               thickness: 4,
               size: CGSize(width: 120, height: 120),
               maker: "봄봄매트"),
        Sample(id: 1,
               matName: "코지베이비",
               imageName: "CozyBaby",
               matPrice: 11_000,
               samplePrice: 5_000,
               material: "TPU",
               thickness: 3,
               size: CGSize(width: 130, height: 130),
               maker: "알집매트"),
        Sample(id: 2,
               matName: "코지그레이",
               imageName: "CozyGray",
               matPrice: 13_000,
               samplePrice: 5_000,
               material: "TPU",
               thickness: 5,
               size: CGSize(width: 150, height: 150),
               maker: "매트매트"),
        Sample(id: 3,
               matName: "간장브라운",
               imageName: "SoyBrown",
               matPrice: 15_000,
               samplePrice: 5_000,
               material: "TPU",
               thickness: 2.5,
               size: CGSize(width: 200, height: 200),
               maker: "밀리매트")

    ]
}
#endif
