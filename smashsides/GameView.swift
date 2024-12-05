//
//  GameView.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 29/11/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scene: GameScene
    
    @State private var isPressingLeft = false
    @State private var isPressingRight = false
    
    @State private var messages: [Message] = []
    
    @State private var zoneIndicators: [(UUID, Zone, CGPoint, CGFloat)] = []
    
    @State private var scoreIndicators: [(UUID, Zone, Int, CGFloat, CGFloat)] = []
    
    @State private var countdown: Int = 4
    
    @State private var showBlur: Bool = false
    
    @State private var sequenceRotationAngle: CGFloat = 0
    @State private var sequenceScale: CGFloat = 1
    @State private var sequenceScaleOffset: CGFloat = 0
    
    init(mode: GameMode) {
        _scene = .init(wrappedValue: .init(mode: mode))
    }
    
    var body: some View {
        GeometryReader { reader in
//            SpriteView(scene: scene, debugOptions: [.showsPhysics])
            SpriteView(scene: scene)
                .onAppear {
                    scene.size = reader.size
                    scene.gamedelegate = self
                }
            
            VStack {
                Spacer()
                
                HStack {
                    VStack {
                        Button {} label: {
                            Image("UP")
                                .resizable()
                                .scaledToFit()
                                .tint(Color(uiColor: Orientation.Up.color()))
                        }
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ action in
                                    if isPressingLeft { return }
                                    isPressingLeft = true
                                    
                                    let smashed = scene.onSmashButtonClick(side: .Left, orientation: .Up)
                                    if !smashed {
                                        missedSmash(point: .init(x: reader.size.width * 0.25, y: reader.size.height/2))
                                    }
                                })
                                .onEnded({ _ in
                                    isPressingLeft = false
                                })
                        )
                        .disabled(!scene.canStart)
                        .animation(.easeInOut, value: scene.canStart)
                        
                        Button {} label: {
                            Image("DOWN")
                                .resizable()
                                .scaledToFit()
                                .tint(Color(uiColor: Orientation.Down.color()))
                        }
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ action in
                                    if isPressingLeft { return }
                                    isPressingLeft = true
                                    
                                    let smashed = scene.onSmashButtonClick(side: .Left, orientation: .Down)
                                    if !smashed {
                                        missedSmash(point: .init(x: reader.size.width * 0.25, y: reader.size.height/2))
                                    }
                                })
                                .onEnded({ _ in
                                    isPressingLeft = false
                                })
                        )
                        .disabled(!scene.canStart)
                        .animation(.easeInOut, value: scene.canStart)
                    }
                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.4), trigger: isPressingLeft)
                    
                    Spacer()
                    
                    VStack {
                        Button {} label: {
                            Image("UP")
                                .resizable()
                                .scaledToFit()
                                .tint(Color(uiColor: Orientation.Up.color()))
                        }
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ action in
                                    if isPressingRight { return }
                                    isPressingRight = true
                                    
                                    let smashed = scene.onSmashButtonClick(side: .Right, orientation: .Up)
                                    if !smashed {
                                        missedSmash(point: .init(x: reader.size.width * 0.75, y: reader.size.height/2))
                                    }
                                })
                                .onEnded({ _ in
                                    isPressingRight = false
                                })
                        )
                        .disabled(!scene.canStart)
                        .animation(.easeInOut, value: scene.canStart)
                        
                        Button {} label: {
                            Image("DOWN")
                                .resizable()
                                .scaledToFit()
                                .tint(Color(uiColor: Orientation.Down.color()))
                        }
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ action in
                                    if isPressingRight { return }
                                    isPressingRight = true
                                    
                                    let smashed = scene.onSmashButtonClick(side: .Right, orientation: .Down)
                                    if !smashed {
                                        missedSmash(point: .init(x: reader.size.width * 0.75, y: reader.size.height/2))
                                    }
                                })
                                .onEnded({ _ in
                                    isPressingRight = false
                                })
                        )
                        .disabled(!scene.canStart)
                        .animation(.easeInOut, value: scene.canStart)
                    }
                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.4), trigger: isPressingRight)
                }
                .frame(height: reader.size.height * 0.4)
                .padding(.vertical, 16)
                .padding(.horizontal, 48)
                .sensoryFeedback(.error, trigger: scene.hitstaken)
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    if scene.sequence > 0 {
                        Text("x\(scene.sequence)")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .bold()
                            .rotationEffect(.degrees(sequenceRotationAngle))
                            .scaleEffect(sequenceScale + sequenceScaleOffset)
                            .contentTransition(.numericText())
                            .transition(.scale)
                            .sensoryFeedback(.increase, trigger: scene.sequence)
                    }
                    
                    Spacer()
                }
                .frame(height: reader.size.height * 0.45)
            }
            .onChange(of: scene.sequence) {
                if scene.sequence == 0 {
                    sequenceScaleOffset = 0
                    sequenceScale = 1.0
                    sequenceRotationAngle = 0
                    
                    return
                }
                
                let duration = 1.0/(Double(scene.sequence)/10.0)
                
                withAnimation(.bouncy(duration: duration)) {
                    sequenceRotationAngle = .random(in: 5...35) * (sequenceRotationAngle > 0 ? -1 : 1)
                }
                
                let newScale = sequenceScale + 0.025
                withAnimation(.bouncy(duration: duration)) {
                    sequenceScaleOffset = 0.2
                } completion: {
                    withAnimation(.bouncy(duration: duration)) {
                        sequenceScaleOffset = 0
                        
                        if newScale >= 2.5 {
                            sequenceScale = 2.5
                        } else {
                            sequenceScale = newScale
                        }
                    }
                }
            }
            
            ForEach(zoneIndicators, id: \.0) { (_, zone, position, size) in
                Rectangle()
                    .fill(zoneColor(zone))
                    .position(.init(x: position.x, y: position.y + reader.size.width * 0.02))
                    .frame(width: size, height: reader.size.width * 0.04)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Text("\(timeText)")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(20)
            
            VStack {
                if countdown > 0 {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Text("\(countdown)")
                            .font(.largeTitle)
                            .bold()
                            .fixedSize()
                            .foregroundStyle(.white)
                            .shadow(radius: 10)
                            .padding()
                            .background {
                                
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .transition(.opacity)
                                
                            }
                            .contentTransition(.numericText())
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                                    if scene.isPaused { return }
                                    
                                    if countdown == 0 {
                                        self.scene.canStart = true
                                        timer.invalidate()
                                        
                                        return
                                    }
                                    
                                    withAnimation {
                                        countdown -= 1
                                    }
                                }
                                .fire()
                            }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .transition(.opacity)
            
            VStack {
                HStack {
                    Text("Score:  \(scene.score)")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                        .contentTransition(.numericText())
                        .overlay {
                            GeometryReader { innerReader in
                                ForEach(scoreIndicators, id: \.0) { (id, zone, points, offset, opacity) in
                                    Text("+\(points)")
                                        .foregroundStyle(zoneColor(zone))
                                        .position(x: innerReader.size.width, y: innerReader.size.height - offset)
                                        .opacity(opacity)
                                        .onAppear {
                                            withAnimation(.easeIn(duration: 0.35)) {
                                                guard let idx = scoreIndicators.firstIndex(where: { $0.0 == id }) else { return }
                                                scoreIndicators[idx].4 = 0
                                                scoreIndicators[idx].3 += .random(in: innerReader.size.height*0.1...innerReader.size.height)
                                            } completion: {
                                                scoreIndicators.removeAll(where: { $0.0 == id })
                                            }
                                        }
                                }
                            }
                        }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(20)
            
            ForEach(messages, id: \.id) { message in
                VStack {
                    HStack {
                        ForEach(0..<message.intensity.stars(), id: \.self) { star in
//                            Image(Bool.random() ? "STAR_1" : "STAR_2")
                            Image(message.id.uuidString.first == "A" ? "STAR_1" : "STAR_2")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(message.intensity.gradient())
                                .shadow(color: .red, radius: 5)
                                .frame(width: reader.size.height * 0.05)
                                .offset(y: message.intensity.stars() == 3 && star == 1 ? -5 : 0)
                        }
                    }
                    
                    Text(message.text)
                        .foregroundStyle(message.color)
                }
                .scaleEffect(message.scale)
                .rotationEffect(.degrees(message.rotation))
                .position(message.point)
                .opacity(message.opacity)
                .onAppear {
                    guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
                    
                    withAnimation {
                        messages[idx].point.y -= .random(in: reader.size.height*0.15...reader.size.height*0.25)
                        messages[idx].scale = 1
                    } completion: {
                        withAnimation {
                            guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
                            messages[idx].opacity = 0
                        } completion: {
                            messages.removeAll(where: { $0.id == message.id })
                        }
                    }
                }
            }
            
            if showBlur {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            VStack {
                                HStack {
                                    Button {
                                        dismiss()
                                    } label: {
                                        HStack {
                                            Image(systemName: "xmark")
                                            Text("Quit")
                                        }
                                        .bold()
                                        .foregroundStyle(.white)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                        }
                                    }
                                    
                                    Button {
                                        scene.reset()
                                        countdown = 3
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Restart")
                                        }
                                        .bold()
                                        .foregroundStyle(.white)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                        }
                                    }
                                }
                                .shadow(radius: 10)
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
                .compositingGroup()
                .transition(.opacity)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    if !scene.hasEnded {
                        Button {
                            scene.isPaused.toggle()
                        } label: {
                            Image(systemName: scene.isPaused ? "play.fill" : "pause.fill")
                                .bold()
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                }
                        }
                        .shadow(radius: 10)
                        .disabled(scene.hasEnded)
                        .transition(.opacity)
                        .sensoryFeedback(.selection, trigger: scene.isPaused)
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .onChange(of: scene.hasEnded) {
            if scene.hasEnded {
                withAnimation {
                    showBlur = true
                }
            } else {
                withAnimation {
                    showBlur = false
                }
            }
        }
        .onChange(of: scene.isScenePaused) {
            if scene.isScenePaused {
                withAnimation {
                    showBlur = true
                }
            } else {
                withAnimation {
                    showBlur = false
                }
            }
        }
    }
    
    private var timeText: String {
        switch scene.gamemode {
        case .Timed(_):
            guard let time = scene.countdown else { return "" }

            let minutes = time / 60
            let seconds = time % 60
            
            return "\(minutes < 10 ? "0" : "")\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
        case .Hittable:
            let minutes = scene.timetick / 60
            let seconds = scene.timetick % 60
            
            return "\(minutes < 10 ? "0" : "")\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
        }
    }
    
    private var overlayStyle: AnyShapeStyle {
        (scene.hasEnded || scene.isScenePaused) ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear)
    }
    
    private func zoneColor(_ zone: Zone) -> Color {
        switch zone {
        case .A:
            return .yellow
        case .B:
            return .green
        case .C:
            return .yellow
        }
    }
    
    private func missedSmash(point: CGPoint) {
        messages.append(
            .init(point: point, rotation: .random(in: -30...30), text: "MISSED!", color: .red, intensity: .Error)
        )
    }
}

extension GameView: GameDelegate {
    mutating func smashedEnemy(at point: CGPoint, points: Int, zone: Zone) {
        let intensity: Message.Intensity
        switch zone {
        case .A:
            intensity = .Ok
        case .B:
            if scene.sequence > 40 {
                intensity = .Excellent
            } else if scene.sequence > 25 {
                intensity = .Amazing
            } else if scene.sequence > 10 {
                intensity = .WoW
            } else {
                intensity = .Ok
            }
        case .C:
            intensity = .Ok
        }
        
        self.messages.append(
            .init(point: point, rotation: .random(in: -30...30), text: zone.message(), color: zoneColor(zone), intensity: intensity)
        )
        
        self.scoreIndicators.append(
            (.init(), zone, points, 0, 1)
        )
    }
    
    mutating func spawnZonesIndicators(_ zones: [(Zone, CGPoint, CGFloat)]) {
        self.zoneIndicators = zones.map({ (UUID(), $0.0, $0.1, $0.2) })
    }
}

#Preview {
    //    GameView(mode: .Hittable(hits: 2))
    GameView(mode: .Timed(seconds: 60))
}

protocol GameDelegate {
    mutating func smashedEnemy(at point: CGPoint, points: Int, zone: Zone)
    mutating func spawnZonesIndicators(_ zones: [(Zone, CGPoint, CGFloat)])
}
