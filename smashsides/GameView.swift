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
    
    @State private var messages: [(UUID, CGPoint, CGFloat, CGFloat, Zone)] = []
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
                
                Grid {
                    GridRow {
                        Button {} label: {
                            RoundedRectangle(cornerRadius: 20)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ action in
                                    if isPressingLeft { return }
                                    isPressingLeft = true
                                    scene.onSmashButtonClick(.Left)
                                })
                                .onEnded({ _ in
                                    isPressingLeft = false
                                })
                        )
                        .sensoryFeedback(.impact, trigger: isPressingLeft)
                        
                        Rectangle()
                            .fill(.clear)
                        
                        Button {} label: {
                            RoundedRectangle(cornerRadius: 20)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ action in
                                    if isPressingRight { return }
                                    isPressingRight = true
                                    scene.onSmashButtonClick(.Right)
                                })
                                .onEnded({ _ in
                                    isPressingRight = false
                                })
                        )
                    }
                }
                .padding()
                .frame(height: reader.size.height * 0.4)
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
            
            ForEach(messages, id: \.0) { (id, point, rotation, scale, zone) in
                Text(zone.message())
                    .foregroundStyle(zoneColor(zone))
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .position(point)
                    .onAppear {
                        guard let idx = messages.firstIndex(where: { $0.0 == id }) else { return }
                        
                        withAnimation {
                            messages[idx].1.y -= .random(in: reader.size.height*0.15...reader.size.height*0.25)
                            messages[idx].3 = 1
                        } completion: {
                            messages.removeAll(where: { $0.0 == id })
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
            return .orange
        case .B:
            return .green
        case .C:
            return .yellow
        }
    }
}

extension GameView: GameDelegate {
    mutating func smashedEnemy(at point: CGPoint, points: Int, zone: Zone) {
        self.messages.append(
            (.init(), point, .random(in: -30...30), 0, zone)
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
