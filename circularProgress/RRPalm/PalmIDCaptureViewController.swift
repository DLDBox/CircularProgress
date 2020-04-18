//
//  PalmIDCaptureViewController.swift
//  GMI
//

import Foundation

/* Red rock Palm implementation
 */
class PalmIDCaptureViewController: CaptureFlowViewController {
    
    //
    //MARK:- CaptureViewFlowControllerProtocol section
    //
    override var captureType: String { return "palm" }
    override var name: String { return StoryboardScene.PalmCapture.storyboardName}
    override var bioType: String { return "141" }
    override var memeType: String { return "text" }
    override var algoCode: String { return "rrpalm" }
    override var segueName: String { return StoryboardSegue.InteractionManager.palmCaptureSegue.rawValue }
    override var tutorialResource: (UIStoryboard?, [String] ) {
        return (StoryboardScene.PalmCaptureTutorial.storyboard,[StoryboardScene.PalmCaptureTutorial.palmTut1.identifier
                                                                  ,StoryboardScene.PalmCaptureTutorial.palmTut2.identifier
                                                                  ,StoryboardScene.PalmCaptureTutorial.palmTut3.identifier
                                                                  ,StoryboardScene.PalmCaptureTutorial.palmTut4.identifier
                                                                   ]) }
    
    override var unwindSegueName: String { return StoryboardSegue.PalmCapture.exitOverlayFromPalm.rawValue }

    //
    //MARK:- Initialization section
    //
    required init( nibName: String?, device: GMI.DeviceProtocol?, testDevice: GMI.DeviceProtocol?, captureable: GMI.Captureable? ) {
        super.init(nibName: nibName, device: device ?? GMI.RRPalmCameraDevice(),testDevice: testDevice ?? GMI.TestCameraDevice(), captureable: captureable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
    }
    
    required init() {
        super.init()
    }
    
    //
    //MARK:- View LifeCycle section
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewControllers()
    }
    
    //
    //MARK:- Implementation section
    //
    override func startCapture() -> Bool {
        return true
    }
    
    override func stopCapture() -> Void {
    }
    
    
    @IBAction override func onCancel(_ sender: Any) {
        super.onCancel(sender)
    }
    
    //
    //MARK:- Helper section
    //
    
    func setupViewControllers() {
        
        if let captureable = self.captureable {
            if captureable.isEnroll {
                
            } else if captureable.isVerify {
                
            } else {
                log.error( "No capture modality is set" )
            }
        } else {
            log.error( "No captureabletype provided" )
        }
        
    }
}
