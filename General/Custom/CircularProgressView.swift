//
//  CircularProgressView.swift
//  General
//
//  Created by Dũng/Verny/서비스개발팀 on 14/03/2024.
//

import Foundation

public final class CircularProgressView: UIView {
    public var color: UIColor? = .gray {
        didSet { self.setNeedsDisplay() }
    }

    public var progress: CGFloat = 0 {
        didSet { self.setNeedsDisplay() }
    }
    
    public var ringWidth: CGFloat = 5
    public var linecap: CAShapeLayerLineCap = .round

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayers()
    }

    private func setupLayers() {
        self.backgroundMask.lineWidth = self.ringWidth
        self.backgroundMask.fillColor = nil
        self.backgroundMask.strokeColor = UIColor.black.cgColor
        self.layer.mask = self.backgroundMask

        self.progressLayer.lineWidth = self.ringWidth
        self.progressLayer.fillColor = nil
        self.layer.addSublayer(self.progressLayer)
        self.layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)
    }

    public override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: self.ringWidth / 2, dy: self.ringWidth / 2))
        self.backgroundMask.path = circlePath.cgPath
        self.backgroundMask.lineWidth = ringWidth

        self.progressLayer.path = circlePath.cgPath
        self.progressLayer.lineWidth = ringWidth
        self.progressLayer.lineCap = linecap
        self.progressLayer.strokeStart = 0
        self.progressLayer.strokeEnd = progress
        self.progressLayer.strokeColor = color?.cgColor
    }
}
