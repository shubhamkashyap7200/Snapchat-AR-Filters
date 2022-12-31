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
        arView.session.delegate = context.coordinator
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
    
    // MARK: - Inbuilt Functions
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
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let robot = robot else { return }
            
            // Getting faceanchor
            var faceAnchor: ARFaceAnchor?
            for anchor in anchors {
                if let a = anchor as? ARFaceAnchor {
                    faceAnchor = a
                }
            }
            
            /// Storing the values of movement of facial features
            // Eyes movement updating
            let blendShapes = faceAnchor?.blendShapes
            let eyeBlinkLeft = blendShapes?[.eyeBlinkLeft]?.floatValue
            let eyeBlinkRight = blendShapes?[.eyeBlinkRight]?.floatValue
            
            // Brow movement updating
            let browInnerUp = blendShapes?[.browInnerUp]?.floatValue
            let browLeft = blendShapes?[.browDownLeft]?.floatValue
            let browRight = blendShapes?[.browDownRight]?.floatValue
            
            // Jaw movement
            let jawOpen = blendShapes?[.jawOpen]?.floatValue
            
            
            /// Animating the facial features
            // Eyes Animation
            if let eyeBlinkLeft = eyeBlinkLeft, let browInnerUp = browInnerUp, let browLeft = browLeft {
                robot.eyeLidLeft?.orientation = simd_mul(
                    simd_quatf(angle: Deg2Rad(-120 + (90 * eyeBlinkLeft)), axis: [1,0,0]),
                    simd_quatf(angle: Deg2Rad((90 * browLeft) - (30 * browInnerUp)), axis: [0,0,1])
                )
            }
            
            if let eyeBlinkRight = eyeBlinkRight, let browInnerUp = browInnerUp, let browRight = browRight {
                robot.eyeLidLeft?.orientation = simd_mul(
                    simd_quatf(angle: Deg2Rad(-120 + (90 * eyeBlinkRight)), axis: [1,0,0]),
                    simd_quatf(angle: Deg2Rad((-90 * browRight) - (-30 * browInnerUp)), axis: [0,0,1])
                )
            }
            
            // Jaw Animation
            if let jawOpen = jawOpen {
                robot.jaw?.orientation = simd_quatf(
                    angle: Deg2Rad(-100 + (60 * jawOpen)),
                    axis: [1,0,0]
                )
            }
        }
        
        func Deg2Rad(_ value: Float) -> Float {
            return value * .pi / 180
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
