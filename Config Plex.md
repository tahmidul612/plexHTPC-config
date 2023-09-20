## Download mpv dll

[^1]Be sure to close the Plex App before applying the modifications.

- Go to https://sourceforge.net/projects/mpv-player-windows/files/libmpv/
  - Click the modified column to sort by newest.
  - Download `mpv-dev-x86_64-v3-{date}-git-{hash}.7z`, where `date` is the most recent date in `YYYYMMDD` format and `hash` is some random hash.
- Extract the zip to somewhere, and copy the `libmpv-2.dll` file.
- Go to plex install location (by default `C:\Program Files\Plex\Plex HTPC`, though it can vary).
  - If inside the Plex folder `libmpv-2.dll` exists paste the copied `libmpv-2.dll` and overwrite it. If it doesn't paste it and rename it to `mpv-2.dll`. It should be ~80MB in constrast to the original's 10MB.

## Download Shaders

Download Anime4K Shaders from [releases](https://github.com/bloc97/Anime4K/releases) and put them in `C:\Program Files\Plex\Plex HTPC\shaders` folder.

## Update mpv configuration

Download and copy the `input.conf` and `mpv.conf` files to `~\AppData\Local\Plex HTPC`

[^1]: https://github.com/Snaacky/thewiki/blob/master/docs/tutorials/plex.md#how-to-modify-the-mpv-player