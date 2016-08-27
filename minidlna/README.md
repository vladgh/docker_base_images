# MiniDLNA

This is minidlna on top of minimal Alpine.
It can be configured with environment variables.

## Usage

Prefix any config directive of minidlna with `MINIDLNA_`
and run your container:

```
docker run -d --net=host \
  -p 8200:8200 \
  -v <media dir on host>:/media \
  -e MINIDLNA_MEDIA_DIR=/media \
  -e MINIDLNA_FRIENDLY_NAME=MyMini \
  vladgh/minidlna
```

See: http://manpages.ubuntu.com/manpages/raring/man5/minidlna.conf.5.html
