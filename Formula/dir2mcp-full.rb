# typed: false
# frozen_string_literal: true

class Dir2mcpFull < Formula
  desc "Deploy local directories as an MCP server with bundled Docling runtime"
  homepage "https://github.com/dirstral/dir2mcp"
  version "0.4.4"
  license "MIT"

  depends_on "rust" => :build
  depends_on "python@3.12"

  DOCLING_VERSION = "2.92.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.4.4/dir2mcp_0.4.4_darwin_amd64.tar.gz"
      sha256 "598535e4123d64db5e905addf01904cfd11439257359c33118d0072daf39cc47"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.4.4/dir2mcp_0.4.4_darwin_arm64.tar.gz"
      sha256 "ad2dad129a776d3a22e9e85bbf2bc640f03f9bf7957c968e6976d769f82762c6"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.4.4/dir2mcp_0.4.4_linux_amd64.tar.gz"
      sha256 "bfe6170788b7e6769f0520d4af806dc0b9a553fe0d87f1e9a5125b344de9cdba"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.4.4/dir2mcp_0.4.4_linux_arm64.tar.gz"
      sha256 "ccdddce407bc348c0265b13ae00161086bd882d9147f7daac854f8430be049ef"
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
      system pip, "install", "--no-binary", "pydantic-core,rpds-py", "docling==#{DOCLING_VERSION}"
    else
      # Prefer wheels on Intel/Linux to reduce source-build failures and time.
      system pip, "install", "--prefer-binary", "docling==#{DOCLING_VERSION}"
    end

    docling_bin = opt_libexec/"docling-venv/bin/docling"
    real_bin = libexec/"dir2mcp"
    (bin/"dir2mcp").write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
    (bin/"dir2mcp-full").write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
  end

  test do
    system "#{bin}/dir2mcp", "version"
    assert_match "docling", shell_output("#{libexec}/docling-venv/bin/docling --help 2>&1")
  end
end
