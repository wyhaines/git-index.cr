# git-index

This tool takes a list of paths and checks them for git repositories. It writes to a sqlite database a table of repositories found, indexed by both the first and the second commit hashes on the repository. The rationale is that these first couple of commits are unlikely to ever change as the result of a rebase, and thus make a fairly reliable fingerprint of the identity of the repository. The motivation behind this tool is for use with  Serf and the `serf-hander` gem or the `serf-handler.cr` crystal implementation to power a slick, simple deployment manger utizing a git repo and deploy hooks at the underlying source and trigger.

## Usage

```
git-index /gluster/htdocs/site.doc.com
```

Add the given directory to the index.

```
git-index -l
```

List all of the indexed hashes and their directories

```
git-index -q d950c4bbe672fe02e36009d71d88ef4ab754fa91
```

Perform a lookup in the index to see if that has code matches a known repository, and returns the matches, one per line.

```
git-index -h
```

See all options.
