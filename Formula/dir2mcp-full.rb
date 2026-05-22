# typed: false
# frozen_string_literal: true

class Dir2mcpFull < Formula
  desc "Deploy local directories as an MCP server with bundled Docling runtime"
  homepage "https://github.com/dirstral/dir2mcp"
  version "0.5.6"
  license "MIT"

  depends_on "rust" => :build
  depends_on "uv" => :build
  depends_on "python@3.12"

  DOCLING_VERSION = "2.92.0"

  # Pin the torch/transformers stack the docling venv resolves against.
  #
  # docling-slim 2.92.0's published constraints are too loose:
  #   torchvision <1,>=0      (any version)
  #   transformers <6,>=4.42  (excludes 5.0-5.3, allows 5.4+)
  #
  # In practice docling 2.92.0's code imports `AutoProcessor` from a
  # path that was reorganized in transformers 5.x, and the torch /
  # torchvision combo PyPI hands out on a fresh install is not always
  # ABI-coherent (e.g. recent installs picked torch 2.12 + torchvision
  # 0.27 and crashed at import with "operator torchvision::nms does
  # not exist"). Without pins, install reliability decays as new
  # transitive releases land on PyPI.
  #
  # The triple below is the most recent combination verified to load
  # docling 2.92.0 cleanly. Bump these in lockstep when bumping
  # DOCLING_VERSION; re-verify with `docling --help` post-install.
  TORCH_VERSION = "2.5.1"
  TORCHVISION_VERSION = "0.20.1"
  TRANSFORMERS_VERSION = "4.46.3"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.6/dir2mcp_0.5.6_darwin_amd64.tar.gz"
      sha256 "2300213c6f7f2f27917f34ef7625241ea6298c21c80852b56b5d27147c3bdac1"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.6/dir2mcp_0.5.6_darwin_arm64.tar.gz"
      sha256 "79ec663571751dc5bd02e79f67e5af2616c141ad0786b29cb94ce98cef625f49"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.6/dir2mcp_0.5.6_linux_amd64.tar.gz"
      sha256 "bd3a0bc43f34f42793dd5e6b88866d0700523461257637b1798db9adadc1a57b"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.6/dir2mcp_0.5.6_linux_arm64.tar.gz"
      sha256 "d0a25e306ee250d84139fcedba8ed2d4ea6d1895d3c8cf972feeaa1e665c6132"
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
    uv = Formula["uv"].opt_bin/"uv"
    python = Formula["python@3.12"].opt_bin/"python3.12"
    venv_dir = libexec/"docling-venv"
    system uv, "venv", "--python", python, venv_dir
    venv_python = venv_dir/"bin/python"
    # UV_COMPILE_BYTECODE pre-compiles .pyc files at install time so the
    # first `docling` invocation doesn't pay the bytecode-compile tax.
    with_env(UV_COMPILE_BYTECODE: "1") do
      torch_pin = "torch==#{TORCH_VERSION}"
      torchvision_pin = "torchvision==#{TORCHVISION_VERSION}"
      transformers_pin = "transformers==#{TRANSFORMERS_VERSION}"
      docling_pin = "docling==#{DOCLING_VERSION}"
      if OS.mac? && Hardware::CPU.arm?
        # ARM macOS prebuilt wheels for pydantic-core/rpds-py ship with
        # insufficient Mach-O headerpad, so brew's install_name_tool
        # rewrite fails ("Updated load commands do not fit in the
        # header"). Force a source build for these two packages so the
        # resulting .so has enough headerpad. This is the reason the
        # `rust` build dep is still required on this arch.
        system uv, "pip", "install",
               "--python", venv_python,
               "--no-binary", "pydantic-core",
               "--no-binary", "rpds-py",
               torch_pin, torchvision_pin, transformers_pin, docling_pin
      else
        system uv, "pip", "install",
               "--python", venv_python,
               torch_pin, torchvision_pin, transformers_pin, docling_pin
      end
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
