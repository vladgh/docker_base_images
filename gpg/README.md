# GPG Docker Image ([Dockerfile](Dockerfile))
[![](https://images.microbadger.com/badges/image/vladgh/gpg.svg)](https://microbadger.com/images/vladgh/gpg "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/gpg.svg)](https://microbadger.com/images/vladgh/gpg "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/gpg.svg)](https://microbadger.com/images/vladgh/gpg "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/gpg.svg)](https://microbadger.com/images/vladgh/gpg "Get your own license badge on microbadger.com")

## USAGE

- Show version

```SH
docker run --rm -it vladgh/gpg --version
```

- List keys

```SH
docker run -it -v /path/to/keys/store:/root/.gnupg -e GPG_TTY=/dev/console vladgh/gpg --list-keys
```

- Encrypt with symmetric cipher only. This command asks for a passphrase.

```SH
docker run -it -v $(pwd):/gpg -e GPG_TTY=/dev/console vladgh/gpg --symmetric /gpg/my_file
```

- Generate GPG key

```SH
docker run -it -v /path/to/keys/store:/root/.gnupg -e GPG_TTY=/dev/console vladgh/gpg --full-gen-key
```

If the command complaints about more entropy start the following container in a new session on the same host

```SH
docker run --rm --privileged --entrypoint haveged vladgh/gpg -F
```

- Export public GPG key

```SH
docker run --rm -it -v /path/to/keys/store:/root/.gnupg -v $(pwd)/keys:/keys -e GPG_TTY=/dev/console vladgh/gpg --output /keys/my_key.pub --armor --export me@example.com
```

- Export private GPG key (KEEP SAFE)

```SH
docker run --rm -it -v /path/to/keys/store:/root/.gnupg -v $(pwd)/keys:/keys -e GPG_TTY=/dev/console vladgh/gpg --output /keys/my_rsa_key --armor --export-secret-key me@example.com
```
