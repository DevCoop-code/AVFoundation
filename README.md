# Playback
## Handling Asset for playback
* Different Types of Asset
1. File-based assets(ex] local file, Media Library)
2. Stream-based assets(ex] HTTP Live Streaming)

* To load and play a file-based asset
1. Create an asset using **AVURLAsset**
2. Create an instance of **AVPlayerItem** using the asset
3. Associate the item with an instance of AVPlayer

* To create and prepare an HTTP live stream
1. Initialize an instance of **AVPlayerItem** using the URL
(Cann't directly create an AVAsset instance to represent the media in an HTTP Live Stream)

When associate the player item with a player, it's time to ready to play.
When it is ready to play, the player item creates the **AVAsset** and **AVAssetTrack** instances

## Changing the Playback Rate
You can change the rate of playback by setting the player's rate property
[value : 1.0] = play at the natural rate of the current item
[value : 0.0] = same as player pause  

## Playing Multiple Items
Use **AVQueuePlayer** object to play a number of items in sequence
AVQueuePlayer is a subclass of AVPlayer
Initialize a queue player with an array of player items

## Monitoring Playback
Using **key-value** observing to monitor changes to properties values
