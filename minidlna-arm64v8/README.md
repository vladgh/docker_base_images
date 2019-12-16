# MiniDLNA ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/minidlna))

[![Image](https://images.microbadger.com/badges/image/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna)
[![Version](https://images.microbadger.com/badges/version/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna)
[![Commit](https://images.microbadger.com/badges/commit/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna)
[![License](https://images.microbadger.com/badges/license/vladgh/minidlna.svg)](https://microbadger.com/images/vladgh/minidlna)

This is MiniDLNA on top of minimal Alpine.
It can be configured with environment variables.

## Usage

Prefix any configuration directive of MiniDLNA with `MINIDLNA_`
and run your container:

```sh
docker run -d \
  --net=host \
  -v <media dir on host>:/media \
  -e MINIDLNA_MEDIA_DIR=/media \
  -e MINIDLNA_FRIENDLY_NAME=MyMini \
  vladgh/minidlna
```

Note: You need to run the container in host mode for it to be able to receive UPnP broadcast packets. The default bridge mode will not work.

### Multiple Media dirs

Any environment variable starting with `MINIDLNA_MEDIA_DIR` will be treated as
an additional `media_dir` directive and any suffix in the variable name will
be trimmed (ex: `MINIDLNA_MEDIA_DIR_1`). This way you can declare multiple
`media_dir` directives

```sh
docker run -d \
  --net=host \
  -v <media dir on host>:/media/audio \
  -v <media dir on host>:/media/video \
  -e MINIDLNA_MEDIA_DIR_1=A,/media/audio \
  -e MINIDLNA_MEDIA_DIR_2=V,/media/video \
  -e MINIDLNA_FRIENDLY_NAME=MyMini \
  vladgh/minidlna
```

See: <http://manpages.ubuntu.com/manpages/raring/man5/minidlna.conf.5.html>
