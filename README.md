# CircularProgress
A Swift Circular Progress View with numerics, ticks marks and custom color configuration.

# Example #1

![Example #1](Example-1a.png)

Overiding the behavoir of the CirclarCountProgressView

```
class CircularView: CirclarCountProgressView{
    
    override var strokeWidth: CGFloat { get {return 10.0} }
    override var marginWidth: CGFloat { get {return 10.0}}
    override var animationDuration: TimeInterval { get {return 8.0}}
    
    override var trackColor: CGColor { get {return UIColor.clear.cgColor} }
    override var progressColor: CGColor { get {return UIColor.red.cgColor} }
    override var fillColor: CGColor { get {return UIColor.clear.cgColor} }
    override var activeFillColor: CGColor { get {return UIColor.clear.cgColor}}
    override var textColor: CGColor { get {return UIColor.clear.cgColor} }
    
    override var tickCount: Int {get {return 0} }
    override var tickColor: UIColor { get {return UIColor.black}}
    override var tickWidth: CGFloat { get {return 2.0 }}

}
```
