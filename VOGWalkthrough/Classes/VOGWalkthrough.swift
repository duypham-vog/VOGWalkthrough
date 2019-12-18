
import Foundation
import UIKit

extension Notification.Name {
    static let VOGWalkthroughDownloaded = Notification.Name("walkthroughDownloaded")
    static let VOGWalkthroughStepDismissed = Notification.Name("walkthroughStepDismissed")
}

public struct VOGWalkthroughColorConfig{
    public var title:UIColor!
    public var content:UIColor!
    public var icon:UIColor!
    public var background:UIColor!
    
    public init() {
        title = .black
        content = .black
        icon = .black
        background = UIColor.lightGray
    }
}

public struct VOGWalkthroughConfig{
    public var url:String = "" // URL to get list of walkthrough
    public var color:VOGWalkthroughColorConfig = VOGWalkthroughColorConfig()
    public var outsidePadding: CGFloat = 20
    public var insidePadding: CGFloat = 20
    public var font: UIFont = UIFont.systemFont(ofSize: 15)
    public var tapFont: UIFont = UIFont.systemFont(ofSize: 13)
    public var textSize: CGFloat = 17
    public var delay: Double = 0.5
    public var iconSize: CGSize = CGSize(width: 20, height: 20)
    
    public init(){
        
    }
}

class VOGAppStateWalkthrough {
    class func getfirstLoadApp() -> Bool? {
        return UserDefaults.standard.bool(forKey: "___FirstLoadApp")
    }
    
    class func setfirstLoadApp(value:Bool){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey:"___FirstLoadApp")
        defaults.synchronize()
    }
    
    class func getWalkthroughComplete(for screenId: String) -> String?{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "______\(screenId)")
    }
    
    class func setWalkthroughComplete(for screenId: String) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "______\(screenId)")
        defaults.synchronize()
    }
}

public class VOGWalkthrough {
    
    var config = VOGWalkthroughConfig()
    
    let TAG = 170113
    
    public static var shared = VOGWalkthrough()
    
    private var helperView = UIView()
    private var gesture: UITapGestureRecognizer?
    private var direction: Int = 0
    private let iconPadding: CGFloat = 30
    
    var viewBG:UIView!
    
    private var walkthroughData: [VOGWalkthroughs] = [] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.VOGWalkthroughDownloaded, object: nil)
            print("Posting notification for VOGWalkthrough downloaded")
        }
    }
    private var currentScreenId: String = ""
    private var currentStepId: Int = 0
    private var currentSteps: [VOGWalkthroughSteps] = []
    
    private enum Position: Int {
        case fromLeft = 0
        case fromRight = 1
        case top = 2
        case bottom = 3
    }
    
    public struct ViewDetails {
        var viewId: Int
        var viewText: String
        var direction: String
        var firstRun: Bool = true
        
        init(viewId: Int, viewText: String, direction: String) {
            self.viewId = viewId
            self.viewText = viewText
            self.direction = direction
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(showNextVOGWalkthroughStep), name: Notification.Name.VOGWalkthroughStepDismissed, object: nil)
    }
    
    public func setConfig(config:VOGWalkthroughConfig){
        self.config = config
        #if DEBUG
        loadVOGWalkthrough()
        #else
        if VOGAppStateWalkthrough.getfirstLoadApp() == false {
            print("firstLoadApp")
            loadVOGWalkthrough()
        }
        #endif
        VOGAppStateWalkthrough.setfirstLoadApp(value: true)
    }
    
    func setupSteps(_ data: [VOGWalkthroughs]) {
        var updatedSteps: [VOGWalkthroughs] = []
        // Need to fix the stepIds
        for screen in data {
            var newScreen = VOGWalkthroughs(id: screen.id, name: screen.name, steps: screen.steps, walkthroughPlatformScreens: screen.walkthroughPlatformScreens, walkthroughPlatformScreenIdList: screen.walkthroughPlatformScreenIdList)
            
            for (i, step) in screen.steps.enumerated() {
                print("setupSteps: step \(i) for \(screen.id) is \(step.content)")
                
                let newStep = VOGWalkthroughSteps(id: i, stepType: step.stepType, position: step.position, content: step.content)
                newScreen.steps.append(newStep)
            }
            updatedSteps.append(newScreen)
        }
        
        self.walkthroughData = updatedSteps
         //        NotificationCenter.default.post(name: Notification.Name.VOGWalkthroughDownloaded, object: nil)
        //        print("Posting notification for VOGWalkthrough downloaded from setupSteps")
    }
    
    func show<T>(on controller: T) {
        
    }
    
    public func showStep(_ sId: Int? = nil, on controller: UIViewController, screenId: String) {

        if VOGAppStateWalkthrough.getWalkthroughComplete(for: screenId) != nil {
            //            return
        }
        
        self.viewController = controller
        self.screenId = screenId
        
        if self.walkthroughData.count > 0 {
            if let tv = self.viewController?.tabBarController {
                if viewBG == nil {
                    viewBG = UIView(frame: (tv.view.frame))
                    viewBG.backgroundColor = .clear
                    tv.view.addSubview(viewBG)
                }else{
                    if !(tv.view.subviews.contains(viewBG!)){
                        tv.view.addSubview(viewBG)
                    }
                }
            }else if let nv = self.viewController?.navigationController {
                if viewBG == nil {
                    viewBG = UIView(frame: (nv.view.frame))
                    viewBG.backgroundColor = .clear
                    nv.view.addSubview(viewBG)
                }else{
                    if !(nv.view.subviews.contains(viewBG!)){
                        nv.view.addSubview(viewBG)
                    }
                }
            }else{
                if viewBG == nil {
                    viewBG = UIView(frame: (self.viewController?.view.frame)!)
                    viewBG.backgroundColor = UIColor.red.withAlphaComponent(0.25)
                    self.viewController?.view.addSubview(viewBG)
                }else{
                    if !(self.viewController?.view.subviews.contains(viewBG!))!{
                        self.viewController?.view.addSubview(viewBG)
                    }
                }
            }
        }
        
        
        
        if let screen = walkthroughData.filter({ $0.walkthroughPlatformScreens.first!.viewOrActivityName == screenId }).first {
            let steps = screen.steps
            currentSteps = steps

            var stepID = sId
            if sId == nil {
                stepID = steps.first?.id ?? 0
            }

            print("VOGWalkthrough: showStep \(stepID!) for screenId \(screenId)")
            currentStepId = stepID!
            currentScreenId = screenId
            print("VOGWalkthrough: VOGWalkthroughData is \(walkthroughData)")

            if let step = steps.filter({ $0.id == stepID }).first {
                print("showStep: step is \(step)")
                direction = step.position.id
                setupHelperView(for: step)
//                controller.view.addSubview(helperView)
                self.viewBG.addSubview(helperView)
                switch step.position.id {
                case Position.bottom.rawValue:
                    animateFromBottom()
                case Position.top.rawValue:
                    animateFromTop()
                case Position.fromRight.rawValue:
                    animateFromRight()
                case Position.fromLeft.rawValue:
                    animateFromLeft()
                default:
                    animateFromTop()
                }
            }
        }
    }
    
    @objc func showNextVOGWalkthroughStep(){
        showNextStep(forScreenId: self.screenId!, on: self.viewController!)
    }
    
    var viewController:UIViewController?
    var screenId:String?
    
    func showNextStep(forScreenId: String, on controller: UIViewController) {
        
        print("VOGWalkthrough: showNextStep for \(forScreenId)")
        print("VOGWalkthrough: showNextStep for currentStepId \(currentStepId)")
        print("VOGWalkthrough: currentSteps count is \(currentSteps.count)")
        
        if let currentIndex = currentSteps.firstIndex(where: { $0.id == currentStepId }) {
            print("VOGWalkthrough: currentIndex: \(currentIndex)")
            if currentIndex < (currentSteps.count - 1) {
                let nextId = currentSteps[currentIndex + 1].id
                showStep(nextId, on: controller, screenId: currentScreenId)
            } else if currentIndex == 1 && currentSteps.count == 2 {
                VOGAppStateWalkthrough.setWalkthroughComplete(for: forScreenId)
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(removeHelpView), userInfo: nil, repeats: false)
            } else {
                VOGAppStateWalkthrough.setWalkthroughComplete(for: forScreenId)
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(removeHelpView), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func removeHelpView(){
        self.viewController?.view.subviews.forEach({
            if $0.tag == TAG {
                $0.removeFromSuperview()
            }
        })
        
        if viewBG != nil {
            viewBG.removeFromSuperview()
        }
    }
    
    private func animateFromTop() {
        UIView.animate(withDuration: 0.5, delay: self.config.delay, options: [.curveEaseOut], animations: {
            self.helperView.center.y += UIScreen.main.bounds.height
        }, completion: nil)
    }
    
    private func animateFromBottom() {
        UIView.animate(withDuration: 0.5, delay: self.config.delay, options: [.curveEaseOut], animations: {
            self.helperView.center.y -= UIScreen.main.bounds.height
        }, completion: nil)
    }
    
    private func animateFromLeft() {
        UIView.animate(withDuration: 0.5, delay: self.config.delay, options: [.curveEaseOut], animations: {
            self.helperView.center.x += UIScreen.main.bounds.width
        }, completion: nil)
    }
    
    private func animateFromRight() {
        UIView.animate(withDuration: 0.5, delay: self.config.delay, options: [.curveEaseOut], animations: {
            self.helperView.center.x -= UIScreen.main.bounds.width
        }, completion: nil)
    }
    
    private func setupHelperView(for step: VOGWalkthroughSteps) {
        let screenMinX = UIScreen.main.bounds.minX
        let screenMinY = UIScreen.main.bounds.minY
        let screenMaxY = UIScreen.main.bounds.maxY
        let screenCenterY = UIScreen.main.bounds.midY
        let screenWidth = UIScreen.main.bounds.width
        let outsidePadding = self.config.outsidePadding
        let insidePadding = self.config.insidePadding
        let backgroundColor = self.config.color.background
        let textColor = self.config.color.content
        let font = self.config.font
        helperView.layer.borderColor = UIColor.black.cgColor
        helperView.layer.borderWidth = 1
        let startX = screenMinX + outsidePadding
        let viewWidth = screenWidth - (outsidePadding * 2)
        
        //let text = step.content.convertToHTMLWithSystemFont(ofSize: 15)
        let noParaOpenText = step.content.replacingOccurrences(of: "<p>", with: "")
        let noParaClosedText = noParaOpenText.replacingOccurrences(of: "</p>", with: "")
        let noSpaceText = noParaClosedText.replacingOccurrences(of: "&nbsp;", with: " ")
        let noBoldOpenText = noSpaceText.replacingOccurrences(of: "<strong>", with: "")
        let noBoldClosedText = noBoldOpenText.replacingOccurrences(of: "</strong>", with: "")
        let noItalOpenText = noBoldClosedText.replacingOccurrences(of: "<em>", with: "")
        let noItalClosedText = noItalOpenText.replacingOccurrences(of: "</em>", with: "")
        let noUnderOpenText = noItalClosedText.replacingOccurrences(of: "<u>", with: "")
        let noUnderClosedText = noUnderOpenText.replacingOccurrences(of: "</u>", with: "")
        let noH1OpenText = noUnderClosedText.replacingOccurrences(of: "<h1>", with: "")
        let noH1ClosedText = noH1OpenText.replacingOccurrences(of: "</h1>", with: "")
        let noH2OpenText = noH1ClosedText.replacingOccurrences(of: "<h2>", with: "")
        let noH2ClosedText = noH2OpenText.replacingOccurrences(of: "</h2>", with: "")
        let noH3OpenText = noH2ClosedText.replacingOccurrences(of: "<h3>", with: "")
        let noH3ClosedText = noH3OpenText.replacingOccurrences(of: "</h3>", with: "")
        let text = noH3ClosedText.replacingOccurrences(of: "</p>", with: "")
        
        //        let viewHeight = step.content.heightForText(.systemFont(ofSize: 15), width: viewWidth) + options.iconSize.height + 40
        
        let viewHeight = calculateViewHeight(from: text, viewWidth: viewWidth, padding: insidePadding) + self.config.iconSize.height + 20
        print("viewHeight is \(viewHeight)")
        
        //let labelHeight = step.content.heightForText(.systemFont(ofSize: 17), width: viewWidth)
        let labelHeight = calculateViewHeight(from: step.content, with: .systemFont(ofSize: 17), viewWidth: viewWidth, padding: 0)
        
        //        let labelHeight = calculateViewHeight(from: text, viewWidth: viewWidth, padding: insidePadding)
        let tapLabelHeight = calculateViewHeight(from: "Tap to dismiss", with: self.config.tapFont, viewWidth: viewWidth, padding: insidePadding)
        
        var frame = CGRect.zero
        
        switch step.position.id {
        case Position.top.rawValue:
            print("Setting frame using Position Top")
            frame = CGRect(x: startX, y: screenMinY + outsidePadding + 50, width: viewWidth, height: viewHeight)
        //            frame = CGRect(x: startX, y: screenMinY + outsidePadding + 50 + 100, width: viewWidth, height: viewHeight)
        case Position.bottom.rawValue:
            print("Setting frame using Position Bottom")
            frame = CGRect(x: startX, y: screenMaxY - outsidePadding - 50 - 100, width: viewWidth, height: viewHeight)
        case Position.fromLeft.rawValue:
            frame = CGRect(x: startX, y: screenCenterY - (viewHeight / 2), width: viewWidth, height: viewHeight)
        case Position.fromRight.rawValue:
            frame = CGRect(x: startX, y: screenCenterY - (viewHeight / 2), width: viewWidth, height: viewHeight)
        default:
            break
        }
        
        helperView = UIView(frame: frame)
        helperView.backgroundColor = backgroundColor
        helperView.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            helperView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        let iconView = UIImageView()
        print("Options.iconSize: \(self.config.iconSize)")
        iconView.frame = CGRect(x: 5, y: 5, width: self.config.iconSize.width, height: self.config.iconSize.height)
        //        iconView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        iconView.image = UIImage(named: "question-circle")
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = self.config.color.icon
        
        helperView.addSubview(iconView)
        
        let tapLabel = UILabel()
        tapLabel.frame = CGRect(x: insidePadding / 2, y: 5, width: helperView.bounds.width - insidePadding, height: tapLabelHeight)
        tapLabel.textColor = self.config.color.title
        tapLabel.font = self.config.tapFont
        tapLabel.textAlignment = .center
        tapLabel.text = "Tap to dismiss"
        
        helperView.addSubview(tapLabel)
        
        let label = UILabel()
        label.frame = CGRect(x: insidePadding / 2, y: iconView.bounds.maxY + 5, width: helperView.bounds.width - insidePadding, height: labelHeight)
        label.textColor = textColor
        label.font = font
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = text
        //        label.attributedText = text
        //        label.layer.borderColor = UIColor.green.cgColor
        //        label.layer.borderWidth = 1
        
        helperView.addSubview(label)
        addGestureRecognizer(to: helperView)
        
        switch step.position.id {
        case Position.top.rawValue:
            helperView.center.y -= UIScreen.main.bounds.height
        case Position.bottom.rawValue:
            helperView.center.y += UIScreen.main.bounds.height
        case Position.fromRight.rawValue:
            helperView.center.x += UIScreen.main.bounds.width
        case Position.fromLeft.rawValue:
            helperView.center.x -= UIScreen.main.bounds.width
        default:
            helperView.center.y -= UIScreen.main.bounds.height
        }
        
        helperView.tag = TAG
    }
    
    private func addGestureRecognizer(to view: UIView) {
        self.gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        view.addGestureRecognizer(gesture!)
    }
    
    @objc private func dismissView(_ sender: UITapGestureRecognizer) {
        switch direction {
        case Position.top.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.helperView.center.y -= UIScreen.main.bounds.height
            })
        case Position.bottom.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.helperView.center.y += UIScreen.main.bounds.height
            })
        case Position.fromRight.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.helperView.center.x += UIScreen.main.bounds.width
            })
        case Position.fromLeft.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.helperView.center.x -= UIScreen.main.bounds.width
            })
        default:
            UIView.animate(withDuration: 0.5, animations: {
                self.helperView.center.y -= UIScreen.main.bounds.height
            })
        }
        direction = 0
        NotificationCenter.default.post(name: Notification.Name.VOGWalkthroughStepDismissed, object: nil)
        print("Posting VOGWalkthrough step dismissed")
    }
    
    private func calculateViewHeight(from text: String, viewWidth: CGFloat, padding: CGFloat) -> CGFloat {
        let textTextContent = text
        let width: CGFloat = viewWidth - (padding * 2)
        let textStyle = NSMutableParagraphStyle()
        let textFontAttributes = [
            .font: self.config.font,
            .foregroundColor: UIColor.white,
            .paragraphStyle: textStyle,
            ] as [NSAttributedString.Key: Any]
        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        let returnHeight = textTextHeight // + iconPadding
        debugPrint("DEBUG: return height = \(returnHeight)")
        return returnHeight
    }
    
    private func calculateViewHeight(from text: String, with font: UIFont, viewWidth: CGFloat, padding: CGFloat) -> CGFloat {
        let textTextContent = text
        let width: CGFloat = viewWidth - (padding * 2)
        let textStyle = NSMutableParagraphStyle()
        let textFontAttributes = [
            .font: font,
            .foregroundColor: UIColor.white,
            .paragraphStyle: textStyle,
            ] as [NSAttributedString.Key: Any]
        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        let returnHeight = textTextHeight // + iconPadding
        debugPrint("DEBUG: return height = \(returnHeight)")
        return returnHeight
    }
    
    //MARK: - ENDPOINT
    
    public func loadVOGWalkthrough(){
        self.walkthroughData  = []
        let semaphore = DispatchSemaphore(value: 0)

        var request = URLRequest(url: URL(string: self.config.url)!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let completionHandler = {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Do something
            if data != nil {
                let completionResponse = self.decode(item: VOGWalkthroughGetResponse.self, data: data!)
                self.walkthroughData = completionResponse.0?.data ?? []
            }
            semaphore.signal()
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
        semaphore.wait()

    }

    // MARK: - Decoder
    fileprivate func newJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }
    
    func decode<T: Codable>(item: T.Type, data: Data) -> (T?, Error?){
        do {
            let returnObject = try newJSONDecoder().decode(item.self, from: data)
            return (returnObject, nil)
        } catch let error {
            return (nil, error)
        }
        
    }
}

extension UIView {
    func getAllSubviews() -> [UIView] {
        var all = [UIView]()
        func getSubview(view: UIView) {
            all.append(view)
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

struct VOGWalkthroughPlatformScreens: Codable {
    var id:Int
    var platformType:VOGWalkthroughPlatformTypes
    var viewOrActivityName:String
    var imagePath:String
}

struct VOGWalkthroughPlatformTypes: Codable {
    var id:Int
    var name:String
}

struct VOGWalkthroughTypes: Codable {
    var id:Int
    var name:String
}

struct VOGWalkthroughPositions: Codable {
    var id:Int
    var name:String
}

struct VOGWalkthroughSteps: Codable {
    var id:Int
    var stepType:VOGWalkthroughTypes
    var position:VOGWalkthroughPositions
    var content:String
    var index:Int?
}

struct VOGWalkthroughs: Codable {
    var id:Int
    var name:String
    var steps:[VOGWalkthroughSteps]
    var walkthroughPlatformScreens:[VOGWalkthroughPlatformScreens]
    var walkthroughPlatformScreenIdList:[Int]
}

struct VOGWalkthroughGetResponse: Codable {
    var data: [VOGWalkthroughs]
    let code: String
    let message: String
    let exceptionName: String?
    let stackTrace: String?
}
