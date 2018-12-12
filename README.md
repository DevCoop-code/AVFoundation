# Different Types of Asset
1. File-based assets(ex] local file, Media Library)
2. Stream-based assets(ex] HTTP Live Streaming)

## To load and play a file-based asset
1. Create an asset using AVURLAsset
2. Create an instance of AVPlayerItem using the asset
3. Associate the item with an instance of AVPlayer

## To create and prepare an HTTP live stream
1. Initialize an instance of AVPlayerItem using the URL
Cann't directly create an AVAsset instance to represent the media in an HTTP Live Stream