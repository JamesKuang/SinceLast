//
//  SVGProcessor.swift
//  SinceLast
//
//  Created by James Kuang on 5/24/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import Kingfisher
import PocketSVG

struct SVGProcessor: ImageProcessor {
    let size: CGSize
    let identifier = "com.sincelast.svg"

    init(size: CGSize = CGSize(width: 32.0, height: 32.0)) {
        self.size = size
    }

    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            return generateSVGImage(data: data, size: size) ?? DefaultImageProcessor().process(item: item, options: options)
        }
    }

    private func generateSVGImage(data: Data, size: CGSize) -> UIImage? {
        guard let svgString = String(data: data, encoding: .utf8) else { return nil }
        let svgLayer = SVGLayer(svgSource: svgString)
        svgLayer.frame = CGRect(origin: .zero, size: size)
        return snapshotImage(for: svgLayer)
    }

    private func snapshotImage(for layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

struct SVGCacheSerializer: CacheSerializer {
    func data(with image: Image, original: Data?) -> Data? {
        return original
    }

    func image(with data: Data, options: KingfisherOptionsInfo?) -> Image? {
        let processor = SVGProcessor()
        let opt: KingfisherOptionsInfo = options ?? KingfisherOptionsInfo()
        return processor.process(item: ImageProcessItem.data(data), options: opt)
    }
}
