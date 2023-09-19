//
//  SwiftUIView.swift
//  
//
//  Created by gandreas on 9/19/23.
//

import SwiftUI
import StatterCRG
import AVFoundation

#if os(iOS)
struct ScannerView: UIViewRepresentable {
    var onQRCode: (String?) -> Void
    class ViewView: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer?
        override func layoutSubviews() { // so the preview layer resizes since we can't use autoresize
            previewLayer?.frame = self.bounds
            previewLayer?.connection?.videoOrientation = UIDevice.current.orientation == .landscapeRight ? AVCaptureVideoOrientation.landscapeLeft : AVCaptureVideoOrientation.landscapeRight
        }
    }

    class VideoCamCoordinator : NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var previewLayer: AVCaptureVideoPreviewLayer?
        var session = AVCaptureSession()
        var device: AVCaptureDevice?
        var lastCode: String? = nil
        var onQRCode: (String?) -> Void = { _ in }
        let metadataOutput = AVCaptureMetadataOutput()
        func installDevice(_ newDevice: AVCaptureDevice?, view: ViewView) {
            if device === newDevice {
                return
            }
            device = newDevice
            if let oldPreviewLayer = previewLayer {
                oldPreviewLayer.session?.stopRunning()
                oldPreviewLayer.removeFromSuperlayer()
                previewLayer = nil
            }
            guard let device = device else {
                return
            }
            do {
                try session.addInput(AVCaptureDeviceInput(device: device))
                session.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = [.qr]
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                //Preview
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                view.previewLayer = previewLayer
                previewLayer!.frame = view.bounds
//                previewLayer!.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
//                previewLayer!.videoGravity = camInputManager.scaling == .letterbox ? AVLayerVideoGravity.resizeAspect : AVLayerVideoGravity.resizeAspectFill
//                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft //landscapeRight
                previewLayer!.videoGravity = .resizeAspectFill
                view.layer.addSublayer(previewLayer!)
                
                DispatchQueue.global(qos: .background).async {
                    self.session.startRunning()
                }
                //  print(device)
            } catch {
                //print(device)
            }

        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first,
                  let codeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let qrCode = codeObject.stringValue
                else {
                if lastCode != nil {
                    onQRCode(nil)
                    lastCode = nil
                }
                return
            }
            if lastCode != qrCode { // only send it once
                onQRCode(qrCode)
                lastCode = qrCode
            }
        }

    }
    @State var installedDevice: AVCaptureDevice?

    func makeCoordinator() -> VideoCamCoordinator {
        VideoCamCoordinator()
    }
    func makeUIView(context: Context) -> ViewView {
        let retval = ViewView()
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus == .authorized {
            context.coordinator.installDevice(AVCaptureDevice.default(for: AVMediaType.video), view: retval)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.sync {
                    if granted {
                        context.coordinator.installDevice(AVCaptureDevice.default(for: AVMediaType.video), view: retval)
                    }
                }
            }
        }

        return retval
    }
    func updateUIView(_ uiView: ViewView, context: Context) {
        uiView.setNeedsLayout()
        context.coordinator.installDevice(AVCaptureDevice.default(for: AVMediaType.video), view: uiView)
        context.coordinator.onQRCode = onQRCode
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}

#endif
/// A util view to fill in the connection record for a connection, including (on iOS) an optional QR code scanner
public struct SelectAddress: View {
    public init(connection: Binding<Connection.ConnectionRecord>) {
        _connection = connection
    }
    
    @Binding var connection: Connection.ConnectionRecord
    #if os(iOS)
    @State private var showScanner = false
    @State private var message:String? = nil
    @State private var permissionGranted = false
    #endif
    public var body: some View {
        Form {
            Text("Server Connection Info")
            TextField("Host Name/Address", text: $connection.host)
            TextField("Port", value: $connection.port, formatter: NumberFormatter())
            TextField("Operator Name", text: $connection.operatorName)
            #if os(iOS)
            Button {
                showScanner.toggle()
            } label: {
                Label("Scan QR Code", systemImage: "qrcode.viewfinder")
            }
            .disabled(permissionGranted == false)
            .onAppear(perform: {
                #if targetEnvironment(simulator)
                #else
                AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
                    DispatchQueue.main.async {
                        self.permissionGranted = accessGranted
                    }
                })
                #endif
            })
            .sheet(isPresented: $showScanner) {
                ZStack {
                    ScannerView() {
                        if let code = $0 {
                            message = "Found Code"
                            if showScanner, let url = URL(string: code), let host = url.host() {
                                connection.port = url.port ?? 8000
                                connection.host = host
                                showScanner = false
                            } else {
                                message = "Code '\(code)' Not Recognized"
                            }
                        } else {
                            if message != nil {
                                message = nil
                            }
                        }
                    }
                    VStack {
                        Text("Scan QR Code for Server")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                        Spacer()
                        if let message {
                            Text(message)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.5))
                        }
                        Button("Cancel") {
                            showScanner.toggle()
                        }
                    }
                }
            }
            #endif
        }
    }
}
#Preview {
    SelectAddress(connection: .constant(.init(host: "10.0.0.10")))
}
