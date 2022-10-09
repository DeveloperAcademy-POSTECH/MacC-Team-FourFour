//
//  MockData.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import Foundation



struct MockData {

    static var sampleList: [Sample] = [
        Sample(matName: "화이트마블",
               imageName: "WhiteMarble",
               matPrice: "12,000원",
               samplePrice: "5,000원",
               material: "TPU",
               thickness: "4cm",
               size: "120x120",
               maker: "봄봄매트"),
        Sample(matName: "코지베이비",
               imageName: "CozyBaby",
               matPrice: "11,000원",
               samplePrice: "5,000원",
               material: "TPU",
               thickness: "3cm",
               size: "120x150",
               maker: "알집매트"),
        Sample(matName: "코지그레이",
               imageName: "CozyGray",
               matPrice: "13,000원",
               samplePrice: "5,000원",
               material: "TPU",
               thickness: "5cm",
               size: "150x120",
               maker: "매트매트"),
        Sample(matName: "간장브라운",
               imageName: "SoyBrown",
               matPrice: "15,000원",
               samplePrice: "5,000원",
               material: "TPU",
               thickness: "2.5cm",
               size: "200x200",
               maker: "밀리매트")

    ]
}
