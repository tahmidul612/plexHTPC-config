# Configure Plex

<!--start-->
> Follows guide in <https://github.com/Snaacky/thewiki/blob/master/docs/tutorials/plex.md#how-to-modify-the-mpv-player>

## Download modified mpv dll and update htpc

> Script from <https://forums.plex.tv/t/script-to-automatically-check-update-both-plex-htpc-and-mitzschs-mpv-with-truehd-support/883742>

Clone the `PlexConfig` repository.

```powershell
git clone https://gist.github.com/4e1fdfc60bc39112fdd237cacb26cb56.git "PlexConfig"
cd PlexConfig
```

Run the `update-plex.ps1` script with admin privileges to download the modified mpv dll and update the Plex HTPC installation.

```powershell
sudo ./update-plex.ps1
```

## Download Shaders

Download GLSL Shaders from [Plex-GLSL-Shaders](https://github.com/LitCastVlog/Plex-GLSL-Shaders) and put them in `"<appdata\local>\Plex HTPC\shaders"` folder.

```powershell
git clone https://github.com/LitCastVlog/Plex-GLSL-Shaders.git
cp -r .\Plex-GLSL-Shaders\shaders "$env:USERPROFILE\AppData\Local\Plex HTPC"
```

## Update mpv configuration

Download and copy the `input.conf` and `mpv.conf` files to `$env:USERPROFILE\AppData\Local\Plex HTPC`

```powershell
cp .\input.conf "$env:USERPROFILE\AppData\Local\Plex HTPC"
cp .\mpv.conf "$env:USERPROFILE\AppData\Local\Plex HTPC"
```
<!--end-->
