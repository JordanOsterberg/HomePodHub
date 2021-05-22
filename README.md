# HomePod Hub
[Click here to watch the video!](https://www.youtube.com/watch?v=xTNb-o7KJE4)

HomePod is copyright Apple, Inc. This project is purely for fun, conceptualization, experimentation and shouldn't be taken as a real Apple product.

Best experienced on an iPad Pro. We used an 11" from 2018 in our video. 

App also runs on macOS under the `My Mac (Designed for iPad)` destination. Though, I am using an M1 Mac so I'm not sure if Intel Macs will have that specific destination (you can never know these days 🤣)

## Aerial App Note
I have not included the aerial movie files in the project because they are a combined ~400 MB in size, and are also Apple's property. I retrieved them by exploring this site by Benjamin Mayo: https://bzamayo.com/watch-all-the-apple-tv-aerial-video-screensavers#b2-4

I have included the timing JSON files (the raw data of which was also found as part of Benjamin's site) so you only need to add the videos under the names "SFNight.mov" and "SFDay.mov".

Add them to /Resources/Aerial/Resources/SFNight/ or /Resources/Aerial/Resources/SFDay/ in Xcode. Make sure they're a member of the `HomePodHub` target, not the `AerialApp` target.

The app looks for them in the main Bundle

You can always substitute other videos in. The Aerial App will not function without 2 video files named appropriately and added to the main bundle.
