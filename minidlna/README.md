# MiniDLNA ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/minidlna))
[![](https://images.microbadger.com/badges/image/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna "Get your own license badge on microbadger.com")

This is MiniDLNA on top of minimal Alpine.
It can be configured with environment variables.

## Usage

Prefix any configuration directive of MiniDLNA with `MINIDLNA_`
and run your container:

```
docker run -d --net=host \
  -p 8200:8200 \
  -v <media dir on host>:/media \
  -e MINIDLNA_MEDIA_DIR=/media \
  -e MINIDLNA_FRIENDLY_NAME=MyMini \
  vladgh/minidlna
```

### Multiple Media dirs

Any environment variable starting MEDIA_DIR will be treated as an additional media_dir directive.

```
docker run -d --net=host \
  -p 8200:8200 \
  -v <media dir on host>:/media/audio \
  -v <media dir on host>:/media/video \
  -e MEDIADIR_1=A:/media/audio \
  -e MEDIADIR_1=V:/media/video \
  -e MINIDLNA_FRIENDLY_NAME=MyMini \
  vladgh/minidlna
```

See: http://manpages.ubuntu.com/manpages/raring/man5/minidlna.conf.5.html
