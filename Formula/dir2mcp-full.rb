# typed: false
# frozen_string_literal: true

class Dir2mcpFull < Formula
  desc "Deploy local directories as an MCP server with bundled Docling runtime"
  homepage "https://github.com/dirstral/dir2mcp"
  version "0.5.1"
  license "MIT"
  revision 1

  depends_on "rust" => :build
  depends_on "python@3.12"

  DOCLING_VERSION = "2.92.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.1/dir2mcp_0.5.1_darwin_amd64.tar.gz"
      sha256 "9fcc7ff2378ddef448d1c2cca1c0dbeddf4c3642f8745691da9fda24c498a8f2"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.1/dir2mcp_0.5.1_darwin_arm64.tar.gz"
      sha256 "2a63be3e19ec75ee431506c7afb36230d7ca7724a83c076b64b951e0368cf4ba"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.1/dir2mcp_0.5.1_linux_amd64.tar.gz"
      sha256 "8f37dda1a0a5bf6221e586ba7fffaad0891afc9004570eeb812b02e457d3a7d2"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.5.1/dir2mcp_0.5.1_linux_arm64.tar.gz"
      sha256 "c942eff38e2e46d8c2c34f3f9f704c9d42b70373bfd36dc5fa6bcd7f5447e54a"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  conflicts_with "dir2mcp", because: "both install a dir2mcp runtime variant"

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
