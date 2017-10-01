# Change Log

## [v0.3.1](https://github.com/vladgh/docker_base_images/tree/v0.3.1) (2017-10-01)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.3.0...v0.3.1)

**Implemented enhancements:**

- Backup: Allow GPG public key importing from multiple URLs [\#38](https://github.com/vladgh/docker_base_images/issues/38)
- Allow multiple GPG recipients [\#37](https://github.com/vladgh/docker_base_images/issues/37)
- Upgrade Tini [\#36](https://github.com/vladgh/docker_base_images/issues/36)
- Allow GPG passphrase from environment variable or Docker Secret [\#34](https://github.com/vladgh/docker_base_images/issues/34)

## [v0.3.0](https://github.com/vladgh/docker_base_images/tree/v0.3.0) (2017-08-25)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.2.6...v0.3.0)

**Implemented enhancements:**

- Improve Backup image [\#35](https://github.com/vladgh/docker_base_images/issues/35)
- Backup image should allow file decryption through standard input [\#33](https://github.com/vladgh/docker_base_images/issues/33)
- Update README [\#31](https://github.com/vladgh/docker_base_images/issues/31)
- Update Puppet Agent to 5.1.0 [\#29](https://github.com/vladgh/docker_base_images/issues/29)
- Add Hiera EYaml to the Puppet Server image [\#28](https://github.com/vladgh/docker_base_images/issues/28)
- Move MicroBadger tokens to .env [\#26](https://github.com/vladgh/docker_base_images/issues/26)
- Upgrade Tini [\#25](https://github.com/vladgh/docker_base_images/issues/25)
- Upgrade Puppet Agent [\#24](https://github.com/vladgh/docker_base_images/issues/24)
- Improve symmetric encryption algorithm [\#23](https://github.com/vladgh/docker_base_images/issues/23)
- Remove ASCII-armored format for the encrypted files [\#22](https://github.com/vladgh/docker_base_images/issues/22)
- Set a very restrictive umask [\#27](https://github.com/vladgh/docker_base_images/pull/27) ([vladgh](https://github.com/vladgh))

**Fixed bugs:**

- Fix GPG key importing from folder [\#32](https://github.com/vladgh/docker_base_images/issues/32)
- Prefix gets doubled when restoring a backup so archive not copied [\#30](https://github.com/vladgh/docker_base_images/issues/30)

## [v0.2.6](https://github.com/vladgh/docker_base_images/tree/v0.2.6) (2017-07-11)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.2.5...v0.2.6)

**Implemented enhancements:**

- Adhere to recommended community standards [\#21](https://github.com/vladgh/docker_base_images/issues/21)
- Remove hardcoded AWS credentials location [\#20](https://github.com/vladgh/docker_base_images/issues/20)
- Use the new Puppet rolling repos [\#19](https://github.com/vladgh/docker_base_images/issues/19)
- Allow restore single file from backup [\#18](https://github.com/vladgh/docker_base_images/issues/18)

**Fixed bugs:**

- Backup restore doesn't work [\#17](https://github.com/vladgh/docker_base_images/issues/17)

## [v0.2.5](https://github.com/vladgh/docker_base_images/tree/v0.2.5) (2017-06-06)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.2.4...v0.2.5)

**Implemented enhancements:**

- Refactor Backup image for Docker Swarm secrets [\#15](https://github.com/vladgh/docker_base_images/issues/15)
- Use the voxpupuli configuration for Puppet Board [\#13](https://github.com/vladgh/docker_base_images/issues/13)
- Upgrade to Alpine 3.6 [\#12](https://github.com/vladgh/docker_base_images/issues/12)
- Add health check to the PuppetDB [\#11](https://github.com/vladgh/docker_base_images/issues/11)
- Add support for Docker Swarm secrets to the backup image [\#16](https://github.com/vladgh/docker_base_images/pull/16) ([vladgh](https://github.com/vladgh))
- Refactor S3Sync to allow Docker Swarm secrets [\#14](https://github.com/vladgh/docker_base_images/pull/14) ([vladgh](https://github.com/vladgh))
- Add PuppetBoard base image [\#9](https://github.com/vladgh/docker_base_images/pull/9) ([vladgh](https://github.com/vladgh))

**Fixed bugs:**

- Improve PuppetDB entrypoint [\#10](https://github.com/vladgh/docker_base_images/pull/10) ([vladgh](https://github.com/vladgh))

## [v0.2.4](https://github.com/vladgh/docker_base_images/tree/v0.2.4) (2017-04-27)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.2.3...v0.2.4)

## [v0.2.3](https://github.com/vladgh/docker_base_images/tree/v0.2.3) (2017-04-27)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.2.2...v0.2.3)

## [v0.2.2](https://github.com/vladgh/docker_base_images/tree/v0.2.2) (2017-04-25)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.2.1...v0.2.2)

## [v0.2.1](https://github.com/vladgh/docker_base_images/tree/v0.2.1) (2017-04-16)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.2.0...v0.2.1)

## [v0.2.0](https://github.com/vladgh/docker_base_images/tree/v0.2.0) (2017-04-14)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.1.1...v0.2.0)

## [v0.1.1](https://github.com/vladgh/docker_base_images/tree/v0.1.1) (2017-04-01)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.1.0...v0.1.1)

## [v0.1.0](https://github.com/vladgh/docker_base_images/tree/v0.1.0) (2017-04-01)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.10...v0.1.0)

## [v0.0.10](https://github.com/vladgh/docker_base_images/tree/v0.0.10) (2017-03-31)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.9...v0.0.10)

**Implemented enhancements:**

- When you set a WATCHDIR in s3sync it still tries to sync from S3 to /sync on startup [\#7](https://github.com/vladgh/docker_base_images/issues/7)

## [v0.0.9](https://github.com/vladgh/docker_base_images/tree/v0.0.9) (2017-03-25)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.8...v0.0.9)

## [v0.0.8](https://github.com/vladgh/docker_base_images/tree/v0.0.8) (2017-03-20)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.7...v0.0.8)

## [v0.0.7](https://github.com/vladgh/docker_base_images/tree/v0.0.7) (2017-03-10)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.6...v0.0.7)

## [v0.0.6](https://github.com/vladgh/docker_base_images/tree/v0.0.6) (2017-03-05)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.5...v0.0.6)

## [v0.0.5](https://github.com/vladgh/docker_base_images/tree/v0.0.5) (2017-01-22)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.4...v0.0.5)

## [v0.0.4](https://github.com/vladgh/docker_base_images/tree/v0.0.4) (2017-01-09)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.3...v0.0.4)

## [v0.0.3](https://github.com/vladgh/docker_base_images/tree/v0.0.3) (2017-01-08)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.2...v0.0.3)

## [v0.0.2](https://github.com/vladgh/docker_base_images/tree/v0.0.2) (2017-01-08)
[Full Changelog](https://github.com/vladgh/docker_base_images/compare/v0.0.1...v0.0.2)

## [v0.0.1](https://github.com/vladgh/docker_base_images/tree/v0.0.1) (2016-12-22)
**Implemented enhancements:**

- Add metadata [\#6](https://github.com/vladgh/docker_base_images/issues/6)

**Closed issues:**

- Create build hooks [\#5](https://github.com/vladgh/docker_base_images/issues/5)
- Add rubycritic and reek [\#4](https://github.com/vladgh/docker_base_images/issues/4)
- Prefix the logs for s3sync with date [\#3](https://github.com/vladgh/docker_base_images/issues/3)
- Use alpine base images [\#2](https://github.com/vladgh/docker_base_images/issues/2)

**Merged pull requests:**

- Add a Gitter chat badge to README.md [\#1](https://github.com/vladgh/docker_base_images/pull/1) ([gitter-badger](https://github.com/gitter-badger))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*