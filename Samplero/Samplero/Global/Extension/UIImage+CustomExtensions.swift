import UIKit
//
extension UIImage {
    class func imageFromColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1), scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    //
    func resizedImage(for size: CGSize) -> UIImage? {
        let image = self.cgImage
        print(size)
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: image!.bitsPerComponent,
                                bytesPerRow: Int(size.width),
                                space: image?.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: image!.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(image!, in: CGRect(origin: .zero, size: size))
        
        guard let scaledImage = context?.makeImage() else { return nil }
        
        return UIImage(cgImage: scaledImage)
    }
}
