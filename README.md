# homebrew-tasqx

Homebrew tap for [tasqx](https://github.com/dimitritholen/tasqx), the task
manager that lives in the terminal and treats an AI agent as a normal user.

```console
brew install dimitritholen/tasqx/tasqx
```

No `brew tap` needed first — that command taps this repository on the way past.
Updating is `brew upgrade tasqx`. Installing through brew also switches shell
Tab completion on without any manual step, which is the reason this route
exists next to the `curl | sh` one-liner.

## How the formula gets here

`Formula/tasqx.rb` is **generated per release**, never edited by hand: the main
repository's `scripts/brew-formula.sh <tag>` renders it from the checksums the
release itself publishes, so the formula cannot disagree with what a user
downloads. It arrives on a branch, the CI in this repository runs the four
checks Homebrew demands (`brew style`, `brew audit`, `brew install`,
`brew test`) on Linux and macOS, and only a green run merges to `main` — the
branch users actually tap.

Found a problem with the formula? File it against
[dimitritholen/tasqx](https://github.com/dimitritholen/tasqx/issues); this
repository only carries the rendered output.
