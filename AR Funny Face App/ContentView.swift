//
//  ContentView.swift
//  AR Funny Face App
//
//  Created by Shubham on 12/31/22.
//

import SwiftUI
import RealityKit
import ARKit

fileprivate var arView: ARView!
fileprivate var robot: Experience.GreenRobot!

struct ContentView : View {
    // MARK: - Properties
    let sceneCount = 3
    
    @State var propId: Int = 0
    
    var body: some View {
        ZStack {
            ARViewController(propId: $propId).edgesIgnoringSafeArea(.all)
            
            Group {
                HStack {
                    Spacer()
                    
                    // Left Button
                    Button(action: {
                        self.propId = self.propId <= 0 ? 0 : self.propId - 1
                        print(propId)
                    }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 44.0))
                    }
                    
                    Spacer()
                    
                    // Screen shot button
                    Button(action: {
                        self.takeScreenShot()
                    }) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 72.0))
                        //                        .border(.red, width: 2.0)
                    }
                    
                    Spacer()
                    
                    // Right Button
                    Button(action: {
                        self.propId = self.propId >= sceneCount ? sceneCount : self.propId + 1
                        print(propId)
                    }) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 44.0))
                    }
                    
                    Spacer()
                    
                }
            }
            .padding(.bottom)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
    
    
    // MARK: - Helper Functions
    func takeScreenShot() {
        arView.snapshot(saveToHDR: false) { image in
            guard let data = image?.pngData() else { return }
            
            let compressedImage = UIImage(data: data)
            
            if let compressedImage = compressedImage {
                UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil)
            }
            else {
                print("DEBUG:: IMAGE NOT SAVED")
            }
        }
    }
}

struct ARViewController: UIViewRepresentable {
    // MARK: - Properties
    @Binding var propId: Int
    
    func makeUIView(context: Context) -> ARView {
        arView = ARView(frame: .zero)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        configureAll(uiView: uiView)
    }
    
    // MARK: - Helper Functions
    func configureAll(uiView: ARView) {
        robot = nil
        configureARExperience(uiView: uiView)
        switchingMultipleScenes(uiView: uiView)
    }
    
    func configureARExperience(uiView: ARView) {
        // Configuration Intialisation
        let arConfiguration = ARFaceTrackingConfiguration()
        
        // Session Intialisation
        uiView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func switchingMultipleScenes(uiView: ARView) {
        switch propId {
        case 0:
            // Eyes
            let arAnchor  = try! Experience.loadEyes()
            uiView.scene.anchors.append(arAnchor)
            arAnchor.scene?.anchors.removeAll()
            break
        case 1:
            // Glasses
            let arAnchor  = try! Experience.loadGlasses()
            uiView.scene.anchors.append(arAnchor)
            arAnchor.scene?.anchors.removeAll()
            break
        case 2:
            // Mustache
            let arAnchor  = try! Experience.loadMustache()
            uiView.scene.anchors.append(arAnchor)
            arAnchor.scene?.anchors.removeAll()
            break
        case 3:
            // Robot
            let arAnchor  = try! Experience.loadGreenRobot()
            uiView.scene.anchors.append(arAnchor)
            robot = arAnchor
            break
        default:
            break
        }
    }
    
    func makeCoordinator() -> ARDelegateHandler {
        return ARDelegateHandler(self)
    }

}

extension ARViewController  {
    class ARDelegateHandler: NSObject, ARSessionDelegate {
        // MARK: - Properties

        var arViewController: ARViewController
        
        // MARK: - Lifecycle Functions

        init(_ controller: ARViewController) {
            self.arViewController = controller
            super.init()
        }
        
        // MARK: - Helper Functions

    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
