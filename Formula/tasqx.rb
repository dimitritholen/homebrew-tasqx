class Tasqx < Formula
  desc "Task manager that lives in the terminal and treats an AI agent as a normal user"
  homepage "https://github.com/dimitritholen/tasqx"
  # No `version`: Homebrew scans it out of the URL, and `brew audit` rejects
  # the field as redundant — the first check a tap maintainer runs, failing on
  # the formula this script exists to produce. Verified rather than assumed:
  # with the line gone, `brew info --json` still reports 0.7.0.
  #
  # Not an OSI-approved license, so homebrew-core is not a route this can ever
  # take. A tap is the whole distribution story, and that is a licensing
  # consequence rather than an omission.
  license "FSL-1.1-MIT"

  on_macos do
    on_arm do
      url "https://github.com/dimitritholen/tasqx/releases/download/v0.7.0/tasqx-v0.7.0-aarch64-apple-darwin.tar.gz"
      sha256 "4f33716b56e6aef1cc285a04c010ee4d8f115591742fbe4cb2c05e2d711f2a61"
    end
    on_intel do
      url "https://github.com/dimitritholen/tasqx/releases/download/v0.7.0/tasqx-v0.7.0-x86_64-apple-darwin.tar.gz"
      sha256 "0a5b526a319527bf1d9d43c28021e282d3eebd593bab2eb598a25afb77957956"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/dimitritholen/tasqx/releases/download/v0.7.0/tasqx-v0.7.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "dc0bff011d5124e214cfb56118c4620f919715aa877476a4a050f29bb1a710eb"
    end
  end

  def install
    bin.install "tasqx"

    # Generated HERE, by the binary brew has just installed, and deliberately
    # NOT copied out of the archive's own `completions/` directory.
    #
    # The two are different artifacts. clap bakes `current_exe()` into the
    # registration script, so a copy made on a CI runner names a path that
    # exists on no other machine; the archive therefore ships the ACTIVATION
    # LINE, which invokes `tasqx` off $PATH and survives being moved. A package
    # manager can do better than a line for a human to paste, because it knows
    # the final path and owns a directory the shell already reads — which is the
    # whole reason this route exists: `brew install tasqx` and Tab works, with
    # nobody having read anything.
    #
    # The baked path is this version's Cellar path. An upgrade installs a new
    # version and runs this again, so the file and the binary move together.
    completions = buildpath/"generated-completions"
    completions.mkpath
    { "bash" => "tasqx", "zsh" => "_tasqx", "fish" => "tasqx.fish" }.each do |shell, name|
      (completions/name).write(
        with_env("TASQX_COMPLETE" => shell) { Utils.safe_popen_read(bin/"tasqx") },
      )
    end
    bash_completion.install completions/"tasqx"
    zsh_completion.install completions/"_tasqx"
    fish_completion.install completions/"tasqx.fish"
  end

  test do
    # A store of its own: the test must not find, or create, the tester's real
    # one. `ENV` takes strings, and a Pathname here is a TypeError at test time.
    ENV["TASQX_DB"] = (testpath/"tasks.db").to_s
    system bin/"tasqx", "init", "work"
    assert_match "Buy milk", shell_output("#{bin}/tasqx add Buy milk")

    # The completion files are the reason this formula exists, so the test
    # asserts they were generated rather than merely installed empty — and that
    # the path inside them is the one brew installed, which is the single thing
    # that cannot be checked before install time.
    registration = (share/"zsh/site-functions/_tasqx").read
    installed = (bin/"tasqx").to_s
    assert_match "#compdef tasqx", registration
    assert_match installed, registration
  end
end
