//
// Copyright 2017 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

@objc
protocol HorizontalColorPickerDelegate: class {
    @objc optional func horizontalColorPicker(_ horizontalColorPicker:HorizontalColorPicker, didUpdateSelectedColor color: UIColor)
}

@IBDesignable
class HorizontalColorPicker: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet private var collectionView: UICollectionView!
    
    private var nibView:UIView!
    private var onlyOnce = true
    private var colors : [UIColor] = HorizontalColorPicker.someColors()
    private var selectedIndexPath : IndexPath?
    private var itemSize = CGSize(width: 12, height: 25)
    
    weak var delegate: HorizontalColorPickerDelegate?
    var selectedColor : UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clear
        
        self.nibView = self.loadViewFromNib()
        self.nibView.frame = self.bounds
        nibView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, .flexibleWidth]
        self.addSubview(self.nibView)
        
        self.nibView.layer.cornerRadius = 5
        self.nibView.layer.borderColor = UIColor.lightGray.cgColor
        self.nibView.layer.borderWidth = 1
        
        self.collectionView.layer.cornerRadius = 5
        
        // Collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = self.itemSize
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        self.collectionView.collectionViewLayout = layout
        self.collectionView.register(HorizontalColorPickerCell.self, forCellWithReuseIdentifier: "HorizontalColorPickerCell")
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HorizontalColorPicker", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalColorPickerCell", for: indexPath) as! HorizontalColorPickerCell
        cell.color = colors[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == self.selectedIndexPath {
            return CGSize(width: self.itemSize.width * 3, height: self.itemSize.height)
        }
        else {
            return self.itemSize
        }
    }
    
    //MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        // Set selected color and indexPath
        self.selectedColor = colors[indexPath.row]
        self.selectedIndexPath = indexPath
        
        // Update selection
        self.collectionView.performBatchUpdates(nil, completion: nil)
        
        // Fire delegate
        self.delegate?.horizontalColorPicker?(self, didUpdateSelectedColor: self.selectedColor!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.selectedColor = nil
        self.selectedIndexPath = nil
    }
    
    //MARK: - Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - Helper Function
    
    private static func someColors() -> [UIColor]{
        
        var colors = [UIColor]()
        
        let hSteps = 10
        let hStart = CGFloat(0.0)
        let hStepVal = (1.0 - hStart) / CGFloat(hSteps)
        
        let sSteps = 1
        let sStart = CGFloat(0.5)
        let sStepVal = (1.0 - sStart) / CGFloat(sSteps)
        
        let bSteps = 10
        let bStart = CGFloat(0.25)
        let bStepVal = (1.0 - bStart) / CGFloat(bSteps)
        
        // Add white to black colors
        for b in 0 ..< bSteps{
            let bVal = 1.0 - (0.1 * CGFloat(b))
            colors.append(UIColor(hue: 0, saturation: 0, brightness: bVal, alpha: 1.0))
        }
        
        // Add colors: red, pink, purple, blue, green, orange
        for h in 0 ..< hSteps{
            
            // Color order: red, pink, purple, blue, green, orange
            let hVal = 1.0 - (hStepVal * CGFloat(h))
            
            for s in 0 ..< sSteps{
                let sVal = 1.0 - (sStepVal * CGFloat(s))
                
                for b in 0 ..< bSteps{
                    let bVal = 1.0 - (bStepVal * CGFloat(b))
                    colors.append(UIColor(hue: hVal, saturation: sVal, brightness: bVal, alpha: 1.0))
                }
            }
        }
        
        return colors
    }
}


class HorizontalColorPickerCell: UICollectionViewCell {
    
    var colorView : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        //
        // Initialize and add color view
        self.colorView = UIView(frame: self.contentView.bounds)
        self.colorView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.contentView.addSubview(self.colorView)
    }
    
    override var isSelected: Bool{
        didSet{
            if isSelected{
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 2
            }
            else{
                layer.borderColor = nil
                layer.borderWidth = 0.0
            }
        }
    }
    
    var color : UIColor?{
        didSet{
            self.colorView.backgroundColor = color
        }
    }
}
