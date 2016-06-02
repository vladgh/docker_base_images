# R10K Docker Image

https://github.com/puppetlabs/r10k

### Run example:

```
docker run -it -v $(pwd)/r10k.yaml:/etc/puppetlabs/r10k/r10k.yaml -v $(pwd)/environments:/etc/puppetlabs/code/environments vladgh/r10k deploy environment --puppetfile --verbose
```
