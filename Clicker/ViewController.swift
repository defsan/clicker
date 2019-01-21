//
//  ViewController.swift
//  Clicker
//
//  Created by Eli on 1/21/19.
//  Copyright © 2019 Eli. All rights reserved.
//

import Cocoa
import HotKey
import Foundation

class ViewController: NSViewController {
    @IBOutlet weak var label: NSTextField!
    var timer: Timer?
    var hotKey: HotKey
    
    // Xcode 7 & 8
    required init?(coder aDecoder: NSCoder) {
        hotKey = HotKey(key: .r, modifiers: [.command, .shift])
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        acquirePrivileges()
        // Setup hot key for
        hotKey.keyDownHandler = {
            print("Pressed at \(Date())")
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
            } else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    override func viewWillDisappear() {
        timer?.invalidate()
    }
    
    @objc func runTimedCode(timer: Timer) {
        self.simulateMouseClick(.left)
    }
    
    func acquirePrivileges() {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [trusted: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(privOptions)
        
        if accessEnabled == true {
            print("access granted")
        } else {
            print("access denied")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        print( "Mouse Clicked" )
    }

    func activeWindows() {
        /*
        let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowListInfo as NSArray? as! [[String: AnyObject]]
        
        for info in infoList {
            print(info)
        }
        */
        
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
        for var app in apps {
            if app.isActive {
                let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
                let windowList = CGWindowListCopyWindowInfo(options,
                                                        kCGNullWindowID)
                                                        as NSArray? as! [[String: AnyObject]]
                for window in windowList {
                    if app.processIdentifier == window["kCGWindowOwnerPID"] as! pid_t  {
                        print(window["kCGWindowName"] as! String)
                        break
                    }
                }
            }
        }
    }
    
    func simulateMouseClick(_ mouseButtonClicked: CGMouseButton) {
        
        var mouseLocation = NSEvent.mouseLocation
        var mouseTypeUp: CGEventType!
        var mouseTypeDown: CGEventType!
        
        switch mouseButtonClicked {
        case .left:
            mouseTypeUp = .leftMouseUp
            mouseTypeDown = .leftMouseDown
        case .right:
            mouseTypeUp = .rightMouseUp
            mouseTypeDown = .rightMouseDown
        case .center:
            mouseTypeUp = .otherMouseUp
            mouseTypeDown = .otherMouseDown
        }
        
        mouseLocation.y = NSHeight(NSScreen.screens[0].frame) - mouseLocation.y
        let point = CGPoint(x: mouseLocation.x, y: mouseLocation.y)
        print(point)
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: mouseTypeDown, mouseCursorPosition: point, mouseButton: CGMouseButton(rawValue: mouseButtonClicked.rawValue)!)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: mouseTypeUp, mouseCursorPosition: point, mouseButton: CGMouseButton(rawValue: mouseButtonClicked.rawValue)!)
        
        mouseDown!.post(tap: .cghidEventTap)
        usleep(1_000)
        mouseUp!.post(tap: .cghidEventTap)
    }


}
