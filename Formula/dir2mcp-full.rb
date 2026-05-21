# typed: false
# frozen_string_literal: true

class Dir2mcpFull < Formula
  desc "Deploy local directories as an MCP server with bundled Docling runtime"
  homepage "https://github.com/dirstral/dir2mcp"
  version "0.5.5"
  license "MIT"

  depends_on "rust" => :build
  depends_on "python@3.12"

  DOCLING_VERSION = "2.92.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.5/dir2mcp_0.5.5_darwin_amd64.tar.gz"
      sha256 "4e997119b97825b6ea0b48fd86c2f6a7c8cfb0793fe7962a259a1cf0c56d5bb0"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.5/dir2mcp_0.5.5_darwin_arm64.tar.gz"
      sha256 "9783b49cd98528745649414766a436edd1d64d9268cde4625e21c2e513c27bea"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.5/dir2mcp_0.5.5_linux_amd64.tar.gz"
      sha256 "cf5bb3e6f24ffdbaa4b5fddc330f5417d50169eb4d43f5bfbe8d67066c86b77a"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.5/dir2mcp_0.5.5_linux_arm64.tar.gz"
      sha256 "d76838208573264bf66783185819b64a3c74d4ecb74da90ceacd5c9f7d7616a3"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  conflicts_with "dir2mcp", because: "both install a dir2mcp runtime variant"

  # Surface the most common upgrade pitfall: zsh/bash cache the path to
  # `dir2mcp` per shell session, so an already-open terminal can keep
  # running the previous binary after `brew upgrade dir2mcp-full` until
  # the cache is cleared.
  def caveats
    <<~EOS
      If `dir2mcp version` reports an older version after upgrading,
      run `hash -r` (bash/zsh) in any open shells to refresh the
      command cache, or open a new terminal.
    EOS
  end

  def install_docling_runtime
    python = Formula["python@3.12"].opt_bin/"python3.12"
    venv_dir = libexec/"docling-venv"
    system python, "-m", "venv", venv_dir
    pip = venv_dir/"bin/pip"
    system pip, "install", "--upgrade", "pip"
    if OS.mac? && Hardware::CPU.arm?
      # ARM macOS linkage checks are stricter for some prebuilt wheels.
      # Keep rpds/pydantic-core from source here to avoid broken install IDs.
      system pip, "install", "--ignore-installed",
             "--no-binary", "pydantic-core,rpds-py",
             "docling==#{DOCLING_VERSION}"
    else
      # Prefer wheels on Intel/Linux to reduce source-build failures and time.
      system pip, "install", "--ignore-installed", "--prefer-binary", "docling==#{DOCLING_VERSION}"
    end

    prune_problematic_cv2_dylibs!(venv_dir) if OS.mac?
    fix_torch_macos_rpath!(venv_dir) if OS.mac?

    docling_bin = opt_libexec/"docling-venv/bin/docling"
    real_bin = libexec/"dir2mcp"
    (bin/"dir2mcp").write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
    (bin/"dir2mcp-full").write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
  end

  private

  def prune_problematic_cv2_dylibs!(venv_dir)
    cv2_dylibs = venv_dir/"lib/python3.12/site-packages/cv2/.dylibs"
    return unless cv2_dylibs.directory?

    %w[libb2.1.dylib libtheoradec.1.dylib libtheoraenc.1.dylib].each do |name|
      (cv2_dylibs/name).delete if (cv2_dylibs/name).exist?
    end
  end

  def fix_torch_macos_rpath!(venv_dir)
    site_packages = Pathname.glob(venv_dir/"lib/python*/site-packages").find(&:directory?)
    return unless site_packages

    torch_lib = site_packages/"torch/lib"
    return unless torch_lib.directory?

    Pathname.glob(torch_lib/"*.dylib").each do |dylib|
      rpath_id = "@rpath/#{dylib.basename}"
      current_id = Utils.safe_popen_read("otool", "-D", dylib).lines[1]&.strip
      next if current_id == rpath_id

      MachO::Tools.change_dylib_id(dylib.to_s, rpath_id)
      system "codesign", "--force", "--sign", "-", dylib
    end
  end

  test do
    system "#{bin}/dir2mcp", "version"
    assert_match "docling", shell_output("#{libexec}/docling-venv/bin/docling --help 2>&1")
  end
end
