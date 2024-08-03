# Configure Plex[^1]

## Download modified mpv dll and update htpc

Run the `update-plex.ps1` script with admin privileges to download the modified mpv dll and update the Plex HTPC installation.

```powershell
sudo ./update-plex.ps1
```

## Download Shaders

Download Anime4K Shaders from [releases](https://github.com/bloc97/Anime4K/releases) and put them in `C:\Program Files\Plex\Plex HTPC\shaders` folder.

## Update mpv configuration

Download and copy the `input.conf` and `mpv.conf` files to `$env:USERPROFILE\AppData\Local\Plex HTPC`

```powershell
cp .\input.conf $env:USERPROFILE\AppData\Local\Plex HTPC
cp .\mpv.conf $env:USERPROFILE\AppData\Local\Plex HTPC
```

[^1]: <https://github.com/Snaacky/thewiki/blob/master/docs/tutorials/plex.md#how-to-modify-the-mpv-player>
