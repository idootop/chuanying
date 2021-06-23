import Cocoa
import Foundation
import FlutterMacOS

import SwiftUI

public class AutoInputPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "auto_input", binaryMessenger: registrar.messenger)
        let instance = AutoInputPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "copy":
                let path = call.arguments as! String
                Helper.copy(path: path)
                result(true)
                break
            case "paste":
                Helper.paste()
                result(true)
                break
            case "click":
                let args = call.arguments as! [String: Any]
                Helper.click(x: args["x"] as! CGFloat,y: args["y"] as! CGFloat)
                result(true)
                break
            case "openImageWindow":
                let args = call.arguments as! [String: Any]
                Helper.openImageWindow(
                    path: args["path"] as! String,
                    srcX: args["srcX"] as! CGFloat,
                    srcY: args["srcY"] as! CGFloat,
                    width: args["width"] as! CGFloat,
                    height: args["height"] as! CGFloat
                )
                result(true)
                break
            case "screenSize":
                let size : CGPoint = Helper.screenSize()
                result([
                    "x":size.x,
                    "y":size.y,
                ])
                break
            case "screenShot":
                let path = call.arguments as! String
                Helper.screenShot(path: path)
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}

public class Helper {
    //复制图片到剪切板
    public static func copy(path: String){
        let data = NSURL(fileURLWithPath: path).dataRepresentation
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setData(data, forType: .fileURL)        
	}

    //粘贴
    public static func paste(){
        let v : UInt16 = 0x09;
        pressKeyWithCMD(keyCode: v);
    }

    //点击
    public static func click(x : CGFloat, y : CGFloat){
        let screen = NSScreen.screens.first!.frame
        let width = NSWidth(screen)
        let height = NSHeight(screen)
        leftClick(x: x * width, y: y * height)
    }

    ///在指定位置打开本地图片
    public static func openImageWindow(
        path:String,
        srcX:CGFloat,
        srcY:CGFloat,
        width:CGFloat,
        height:CGFloat
    ){
        ImageView(path:path).openNewWindow(srcX:srcX,srcY:srcY,width:width,height:height)
    }

    //屏幕尺寸
    public static func screenSize() -> CGPoint{
        let screen = NSScreen.screens.first!.frame
        let width = NSWidth(screen)
        let height = NSHeight(screen)
        return CGPoint(x: width, y: height)
    }

    //截图
    public static func screenShot(path:String) {
        guard let image = CGDisplayCreateImage(CGMainDisplayID()) else { return }
        let url = NSURL(fileURLWithPath:path)
        guard let destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil) else { return }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }

    public static func leftClick(x : CGFloat, y : CGFloat){
        let source = CGEventSource.init(stateID: .hidSystemState)
        let position = CGPoint(x: x, y: y)
        let eventDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: position , mouseButton: .left)
        let eventUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: position , mouseButton: .left)
        eventDown?.post(tap: .cghidEventTap)
        eventUp?.post(tap: .cghidEventTap)
    }

    public static func rightClick(x : CGFloat, y : CGFloat){
        let source = CGEventSource.init(stateID: .hidSystemState)
        let position = CGPoint(x: x, y: y)
        let eventDown = CGEvent(mouseEventSource: source, mouseType: .rightMouseDown, mouseCursorPosition: position , mouseButton: .right)
        eventDown?.post(tap: .cghidEventTap)
    }

    public static func pressKey(keyCode : UInt16){
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        let loc = CGEventTapLocation.cghidEventTap
        keyDown?.post(tap: loc)
        keyUp?.post(tap: loc)
    }
    
    public static func pressKeyWithCMD(keyCode:UInt16){
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let cmdd = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
        let cmdu = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)

        keyDown?.flags = .maskCommand

        let loc = CGEventTapLocation.cghidEventTap

        cmdd?.post(tap: loc)
        keyDown?.post(tap: loc)
        keyUp?.post(tap: loc)
        cmdu?.post(tap: loc)
    }
}

struct ImageView: View {
    var path: String
    var body: some View {
        Image(nsImage:NSImage(byReferencingFile: path)!)
        .resizable()
        .onDrag { return NSItemProvider(object:NSURL(fileURLWithPath:path))}
    }
}

extension View {
    func openNewWindow(
        srcX:CGFloat,
        srcY:CGFloat,
        width:CGFloat,
        height:CGFloat
    ) {
        let contentView=self.edgesIgnoringSafeArea(.top)
        let screen = NSScreen.screens.first!.frame
        let w = NSWidth(screen)
        let h = NSHeight(screen)
        let window = NSWindow(
            contentRect: NSRect(x: w*srcX,y:h*(1-srcY-height), width: w*width, height: h*height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .screenSaver
        window.isReleasedWhenClosed = false
        // window.isMovableByWindowBackground=true
        window.titlebarAppearsTransparent = true
        window.contentView=NSHostingView(rootView:contentView)
        window.standardWindowButton(NSWindow.ButtonType.zoomButton)!.isHidden = true
        window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)!.isHidden = true
        window.makeKeyAndOrderFront(nil)
    }
}
