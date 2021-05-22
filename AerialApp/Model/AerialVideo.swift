//
//  AerialVideo.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/13/21.
//

import Foundation

struct AerialVideo: Equatable {
  var url: URL
  var timings: [AerialTiming]
  
  static func == (lhs: AerialVideo, rhs: AerialVideo) -> Bool {
    return lhs.url == rhs.url
  }
}

extension AerialVideo {
  public static func load(_ named: String) -> AerialVideo? {
    let timingsUrl = Bundle.main.url(forResource: "\(named)Timing", withExtension: "json")
    let timings = try! JSONDecoder().decode([AerialTiming].self, from: Data(contentsOf: timingsUrl!))
    
    return AerialVideo(
      url: Bundle.main.url(forResource: named, withExtension: "mov")!,
      timings: timings
    )
  }
}
