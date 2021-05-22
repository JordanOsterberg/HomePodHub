//
//  AerialTiming.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/13/21.
//

import Foundation

struct AerialTiming: Codable {
  var time: Int
  var caption: String
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    time = Int(try container.decode(String.self, forKey: .time)) ?? 0
    caption = try container.decode(String.self, forKey: .caption)
  }
  
  enum CodingKeys: CodingKey {
    case time, caption
  }
}
