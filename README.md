# <img src="https://raw.githubusercontent.com/InsanityRadio/OnAirController/master/doc/headphones_dark.png" align="left" height=48 /> WEBM-DASH

WEBM-DASH is a Ruby server that can, with a bit of help from FFmpeg, create WEBM-based DASH-encoded audio streams. (Video doesn't work yet, but is planned).

It's not perfect yet - different bitrates don't perfectly align up, but it's a work in progress and a breeze to use. Timings need to be sorted, so there is the potential for a small amount of drift. This is an apparently limitation of FFmpeg (/lack of documentation). 

**Project shelved due to hardware constraints (encoding VP8/9 is expensive, especially when you have no hardware budget).**

## Installation

The only dependencies you'll need are Ruby (duh), FFmpeg, and a web server of choice. 

Simply run a `bundle install` in the top level directory. Open config.yaml, and change it to the format you want.

Make sure you have a web server running which can serve `config["root"]`. This doesn't have to be the web server's root. I'd recommend setting the Access-Control-Allow-Origin and Cache-Control headers to something appropriate through your web server's configuration (.htaccess or otherwise).

Finally, run `ruby start.rb` to start the FFmpeg instances, and you're generating content. Point your player at stream.mpd to play it. 

## Configuration

Configuration is a simple [YAML](http://docs.ansible.com/ansible/YAMLSyntax.html) file, with the following structure. 

(root)

| Key     | Description                         |
|---------|-------------------------------------|
| audio   | Contains information on the audio stream to be captured by this server, or nil/~. See below. |
| video   | Contains information on the video stream to be captured by this server, or nil/~. See below. |
| root    | An absolute path to the "root" directory that you want this server's files to be written to. Requires a trailing slash. <br /> Generates stream.mpd in this directory. |
| chunk_length | The length in milliseconds of an ideal audio chunk. |
| history | The length (in milliseconds) of how long you want to keep a backlog of the stream for |


audio (and eventually video)

| Key     | Description                         |
|---------|-------------------------------------|
| source  | A (FFmpeg-compatible) URL |
| source_format | *(optional)* A FFmpeg source format (see FFmpeg `-f` input) |
| encoder | The encoder backend to use. Currently, only `DASH::Encoder::FFmpeg` is supported. |
| bitrates | A list/array of bitrates this is available at. Should be suffixed with unit (e.g. 128k). |
| codec   | The codec to use to encode the content. For audio, only `libvorbis` and `libopus` are supported by design of WEBM |


## Development

This server was written due to the lack of documentation, MP4Box being a pain to compile correctly, and as nginx-rtmp-module doesn't really support adaptive bitrate streaming. Development of a stable beta took about 6 hours, and was hacked together based on [this post](http://wiki.webmproject.org/adaptive-streaming/instructions-to-do-webm-live-streaming-via-dash). 

The server will soon enter production use on Insanity Radio 103.2FM, a community radio station based in North Surrey, England. At that point it will be considered 'stable'. It was developed such that we could make use of a CDN, especially when we begin streaming video. 

### Caveats

Timings are very slightly off as we're relying on Ruby to spot new chunks as soon as they are written to the filesystem. VLC is unable to play the produced output due to lack of WEBM-DASH (or even real DASH) support. 

There's no support for MPEG-DASH, as FFmpeg doesn't support it. It could probably be supported through MP4box. 

There are currently no unit tests. We didn't have time during development.

