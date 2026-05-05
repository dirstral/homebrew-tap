# typed: false
# frozen_string_literal: true

require "language/python/virtualenv"

class Dir2mcpFull < Formula
  include Language::Python::Virtualenv

  desc "Deploy any local directory as an MCP knowledge server with bundled Docling runtime"
  homepage "https://github.com/Dirstral/dir2mcp"
  version "0.4.0"
  license "MIT"

  depends_on "python@3.12"
  conflicts_with "dir2mcp", because: "both install a dir2mcp runtime variant"

  DOCLING_VERSION = "2.92.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/Dirstral/dir2mcp/releases/download/v0.4.0/dir2mcp_0.4.0_darwin_amd64.tar.gz"
      sha256 "aa0dbf69204976737a1c1d979b67edf154d13d21150a98d8b6c028e570d65e54"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/Dirstral/dir2mcp/releases/download/v0.4.0/dir2mcp_0.4.0_darwin_arm64.tar.gz"
      sha256 "259d55a4ad6781a9cbde1215cfb9b35e2165de4413b2f8ed70a2eb65890404ed"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/Dirstral/dir2mcp/releases/download/v0.4.0/dir2mcp_0.4.0_linux_amd64.tar.gz"
      sha256 "8aebf5ab111f54c527b573bccd84a39762310100f54b4593e95e230ffda649ff"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/Dirstral/dir2mcp/releases/download/v0.4.0/dir2mcp_0.4.0_linux_arm64.tar.gz"
      sha256 "8f2e9d41f2bad3b2a0fd2fa8b9686f1efa8d1256223b2a990b6d7769480815f4"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  def install_docling_runtime
    python = Formula["python@3.12"].opt_bin/"python3.12"
    venv = virtualenv_create(libexec/"docling-venv", python)
    venv.pip_install "docling==#{DOCLING_VERSION}"

    docling_bin = libexec/"docling-venv/bin/docling"
    real_bin = libexec/"dir2mcp"
    bin.write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
    (bin/"dir2mcp-full").write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
  end

  test do
    system "#{bin}/dir2mcp", "version"
    assert_match "docling", shell_output("#{libexec}/docling-venv/bin/docling --help 2>&1")
  end
end
