//
//  ViewController.swift
//  Code16Chalelenge
//
//  Created by Grzegorz Maciak on 06/02/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // We will use `viewDidAppear(_:)` method instead of `viewDidLoad()` because when view did appear its frame is set to the final size (view is added to the window, and layed out), in `viewDidLoad()` the frame has its value loaded from the storyboard/xib and is not set to the real device frame yet.

        //loadSnake()
        // or

        var dc=0;let wid=25,dxy=[0:(1,0),3:(-1,0),1:(0,-1),2:(0,1)],m=[-1:[1,3,0,2],1:[2,0,3,1]],
        vw=view.bounds.size.width,vh=view.bounds.size.height,ds=Int(vw/CGFloat(wid)),
        hid=Int((vh-140.0)/CGFloat(ds)),fw=CGFloat(ds*wid),fv=UIView(frame:CGRect(x:(vw-fw)/2,y:40,width:fw,height:CGFloat(ds*hid))),
        cd:(CGPoint?)->UIView={let v=UIView(frame:CGRect(origin:$0 ?? .zero,size:CGSize(width:ds,height:ds)));
        v.backgroundColor = .green;v.layer.borderWidth=1;return v},isc:(UIView,Int,Int)->Bool={$1==Int($0.frame.minX)/ds&&$2==Int($0.frame.minY)/ds},
        st:()->Void={[weak vi=view,weak fv]in vi?.backgroundColor = .white;fv?.subviews.forEach({$0.removeFromSuperview()});var sn=[UIView](),dts=[UIView](),
        d=2,cx=0,cy=0;dc=0;let rd:()->UIView={var x,y:Int;repeat{x=Int.random(in:0..<wid);y=Int.random(in:0..<hid)}
        while (sn+dts).first(where:{isc($0,x,y)}) != nil;dts.insert(cd(CGPoint(x:x*ds,y:y*ds)),at:0);return dts[0]};
        [0,1,2].forEach{sn.append(cd(.zero));fv?.addSubview(sn[$0])};fv?.addSubview(rd());Timer.scheduledTimer(withTimeInterval:0.3,repeats:true){
        d=m[dc]?[d] ?? d;dc=0;if let mv=dxy[d]{cx=cx+mv.0;cy=cy+mv.1;if cx>=0,cx<wid,cy>=0,cy<hid,sn.first(where:{isc($0,cx,cy)})==nil{
        if let l=sn.popLast(){if l.superview != nil{if let ei=dts.firstIndex(where:{isc($0,cx,cy)}){sn.insert(dts[ei],at:0)
        dts.remove(at:ei);fv?.addSubview(rd())};l.frame.origin=CGPoint(x:cx*ds,y:cy*ds);sn.insert(l,at:0)}else{$0.invalidate()}}}else{$0.invalidate();vi?.backgroundColor = .black}}}},
        r=UIButton(type:.contactAdd,primaryAction:.init(handler:{_ in st()}));fv.layer.borderWidth=1;view.addSubview(fv)
        r.frame=CGRect(x:view.frame.midX-50,y:vh-120,width:100,height:100);r.setImage(UIImage(systemName:"repeat"),for:.normal)
        view.addSubview(r);[-1,1].forEach{v in let b=UIButton(type:.system,primaryAction:.init(handler:{_ in dc=v}))
        b.setImage(UIImage(systemName:"arrowshape.turn.up.\(v==1 ?"right":"left").fill"),for:.normal);b.frame=CGRect(x:v==1 ?vw-120:20,y:vh-120,width:100,height:100);view.addSubview(b)};st()
    }

    /// Loads the Snake game logic and starts the game.
    ///
    /// - note: Lets keep in mind that this code is implemented for fun and to be minimalistic and prepared for later compression to 16 lines. That is why the names are so short which of cource is not compliant with the Swift code style guidline. Don't do it at h... work.
    func loadSnake() {
        /// Direction change
        var dc = 0

        /// Width of the field in dots, defines also the size of the field/snake
        let wid = 20
        /// Direction x, y
        let dxy=[0: (1,0), 3: (-1,0), 1: (0,-1), 2: (0,1)]
        /// Direction change map
        let m=[-1: [1,3,0,2], 1: [2,0,3,1]]
        let vw = view.bounds.size.width
        let vh = view.bounds.size.height
        /// Dot side length
        let ds = Int(vw/CGFloat(wid))
        /// Height of the field in dots
        let hid = Int((vh - 140.0)/CGFloat(ds))
        let fw = CGFloat(ds*wid)
        let fv = UIView(frame: CGRect(x: (vw - fw)/2, y: 40, width: fw, height: CGFloat(ds*hid)))
        /// Create dot
        let cd: (CGPoint?) -> UIView = { p in let v = UIView(frame: CGRect(origin: p ?? .zero, size: CGSize(width: ds, height: ds))); v.backgroundColor = .green; v.layer.borderWidth = 1 ; return v }
        /// Check is the view colliding with the given x and y position on the field
        let isc: (UIView, Int, Int) -> Bool = { $1 == Int($0.frame.minX)/ds && $2 == Int($0.frame.minY)/ds }
        /// game start
        let st: () -> Void = { [weak vi=view, weak fv] in
            /// Snake views
            var sn = [UIView]()
            /// Dot views
            var dts = [UIView]()
            /// Direction
            var d = 2
            /// current x grid position
            var cx = 0
            /// current y grid position
            var cy = 0
            /// Check is the position available (empty), meaning there is no dot at the coordinate
            let isa: (Int, Int) -> Bool = { x, y in (sn+dts).first(where: { isc($0, x, y) }) == nil }
            /// Generate dot at one of the empty positions
            let rd: () -> UIView = {
                var x, y: Int
                repeat { x = Int.random(in: 0..<wid); y = Int.random(in: 0..<hid) } while !isa(x, y)
                dts.insert(cd(CGPoint(x: x*ds, y: y*ds)), at: 0); return dts[0]
            }

            /// Reset the game
            dc = 0
            vi?.backgroundColor = .white
            fv?.subviews.forEach({$0.removeFromSuperview()})

            /// Add snake dots (3 dots)
            [0,1,2].forEach { sn.append(cd(.zero)); fv?.addSubview(sn[$0]) }
            /// Add initial random dot
            fv?.addSubview(rd())
            /// Start the game flow updating
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { t in
                d = m[dc]?[d] ?? d; dc = 0
                if let mv = dxy[d] {
                    cx = cx + mv.0;
                    cy = cy + mv.1;
                    if cx >= 0, cx < wid, cy >= 0, cy < hid, sn.first(where: { isc($0, cx, cy) }) == nil {
                        if let l = sn.popLast() {
                            if l.superview != nil {
                                if let eatenIdx = dts.firstIndex(where: { isc($0, cx, cy) }) {
                                    sn.insert(dts[eatenIdx], at: 0); dts.remove(at: eatenIdx); fv?.addSubview(rd())
                                }
                                l.frame.origin = CGPoint(x: cx*ds, y: cy*ds);sn.insert(l, at: 0)
                            } else {
                                t.invalidate()
                            }
                        }
                    } else {
                        t.invalidate()
                        vi?.backgroundColor = .black
                    }
                }
            }
        }

        // Setup subviews
        fv.layer.borderWidth = 1; view.addSubview(fv)
        /// Reset button
        let r = UIButton(type: .contactAdd, primaryAction: .init(handler: {_ in st() }))
        r.frame = CGRect(x: view.frame.midX - 50, y: vh - 120, width: 100, height: 100)
        r.setImage(UIImage(systemName: "repeat"), for: .normal); view.addSubview(r)
        // Navigation buttons
        [-1,1].forEach { v in
            let isl=v == -1
            let b = UIButton(type: .system, primaryAction: .init(handler: {_ in dc = v }))
            b.setImage(UIImage(systemName: "arrowshape.turn.up.\(isl ? "left" : "right").fill"), for: .normal)
            b.frame = CGRect(x: isl ? 20 : vw - 120, y: vh - 120, width: 100, height: 100)
            view.addSubview(b)
        }
        // start the game
        st()
    }
}

// MARK: - Xcode Preview
// Works from Xcode 11 and macOS 10.15

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, tvOS 13.0, *)
struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController

    func makeUIViewController(context: Context) -> ViewController {
        // let bundle = Bundle(for: StartViewController.self)
        // let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        // return storyboard.instantiateViewController(identifier: "ViewController")
        return ViewController(nibName: nil, bundle: nil)
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

@available(iOS 13.0, tvOS 13.0, *)
struct UIKitViewControllerProvider: PreviewProvider {
    static var previews: ViewControllerRepresentable { ViewControllerRepresentable() }
}

#endif

