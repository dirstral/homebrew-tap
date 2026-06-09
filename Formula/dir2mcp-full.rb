# typed: false
# frozen_string_literal: true

class Dir2mcpFull < Formula
  desc "Deploy local directories as an MCP server with bundled Docling runtime"
  homepage "https://github.com/dirstral/dir2mcp"
  version "0.6.1"
  license "MIT"
  revision 1

  depends_on "rust" => :build
  depends_on "python@3.12"

  DOCLING_VERSION = "2.92.0"

  # Fully pinned dependency lock for the docling venv.
  #
  # docling-slim's published constraints are too loose (e.g. torchvision
  # <1,>=0; transformers <6,>=4.42), and the torch/torchvision combo PyPI
  # hands out on a fresh install is not always ABI-coherent (recent installs
  # picked torch 2.12 + torchvision 0.27 and crashed at import with "operator
  # torchvision::nms does not exist"). docling 2.92.0 also imports
  # `AutoProcessor` from a path reorganized in transformers 5.x. Pinning only
  # the four top-level packages still let transitive releases drift, so
  # install reliability decayed as new wheels landed on PyPI.
  #
  # DOCLING_LOCK freezes the **entire** transitive tree (markers included for
  # Linux CUDA wheels), so every install produces the same known-good
  # environment regardless of when it runs. Regenerate when bumping
  # DOCLING_VERSION:
  #   printf 'torch==2.5.1\ntorchvision==0.20.1\ntransformers==4.46.3\ndocling==<new>\n' > in.txt
  #   uv pip compile --universal --python-version 3.12 --no-annotate --no-header in.txt
  # then re-verify `docling --version` in the built venv.
  # Build-time backend for the macOS-ARM source builds of pydantic-core and
  # rpds-py (see install_docling_runtime). Their PEP 517 build-system.requires
  # aren't part of DOCLING_LOCK (a runtime lock), so pin the build backend
  # here and feed it via `pip install --build-constraint` to keep the source
  # build reproducible. Both packages build with maturin. Refresh alongside
  # DOCLING_LOCK when bumping DOCLING_VERSION.
  DOCLING_BUILD_CONSTRAINTS = <<~CONS
    maturin==1.13.3
  CONS

  DOCLING_LOCK = <<~LOCK.freeze
    accelerate==1.13.0
    annotated-doc==0.0.4
    annotated-types==0.7.0
    antlr4-python3-runtime==4.9.3
    anyio==4.13.0
    attrs==26.1.0
    beautifulsoup4==4.15.0
    certifi==2026.5.20
    charset-normalizer==3.4.7
    click==8.4.1
    colorama==0.4.6 ; sys_platform == 'win32'
    colorlog==6.10.1
    defusedxml==0.7.1
    dill==0.4.1
    docling==#{DOCLING_VERSION}
    docling-core==2.80.0
    docling-ibm-models==3.13.3
    docling-parse==5.11.0
    docling-slim==2.92.0
    et-xmlfile==2.0.0
    faker==40.21.0
    filelock==3.29.1
    filetype==1.2.0
    fsspec==2026.4.0
    h11==0.16.0
    hf-xet==1.5.1 ; platform_machine == 'aarch64' or platform_machine == 'amd64' or platform_machine == 'arm64' or platform_machine == 'x86_64'
    httpcore==1.0.9
    httpx==0.28.1
    huggingface-hub==0.36.2
    idna==3.18
    jinja2==3.1.6
    jsonlines==4.0.0
    jsonref==1.1.0
    jsonschema==4.26.0
    jsonschema-specifications==2025.9.1
    latex2mathml==3.81.0
    lxml==6.1.1
    markdown-it-py==4.2.0
    marko==2.2.3
    markupsafe==3.0.3
    mdurl==0.1.2
    mpire==2.10.2
    mpmath==1.3.0
    multiprocess==0.70.19
    networkx==3.6.1
    numpy==2.4.6
    nvidia-cublas-cu12==12.4.5.8 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-cuda-cupti-cu12==12.4.127 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-cuda-nvrtc-cu12==12.4.127 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-cuda-runtime-cu12==12.4.127 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-cudnn-cu12==9.1.0.70 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-cufft-cu12==11.2.1.3 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-curand-cu12==10.3.5.147 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-cusolver-cu12==11.6.1.9 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-cusparse-cu12==12.3.1.170 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-nccl-cu12==2.21.5 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-nvjitlink-cu12==12.4.127 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    nvidia-nvtx-cu12==12.4.127 ; platform_machine == 'x86_64' and sys_platform == 'linux'
    omegaconf==2.3.0
    opencv-python==4.13.0.92
    openpyxl==3.1.5
    packaging==26.2
    pandas==3.0.3
    pillow==12.2.0
    pluggy==1.6.0
    polyfactory==3.3.0
    psutil==7.2.2
    pyclipper==1.4.0
    pydantic==2.13.4
    pydantic-core==2.46.4
    pydantic-settings==2.14.1
    pygments==2.20.0
    pylatexenc==2.10
    pypdfium2==5.9.0
    python-dateutil==2.9.0.post0
    python-docx==1.2.0
    python-dotenv==1.2.2
    python-pptx==1.0.2
    pywin32==312 ; sys_platform == 'win32'
    pyyaml==6.0.3
    rapidocr==3.8.1
    referencing==0.37.0
    regex==2026.5.9
    requests==2.34.2
    rich==15.0.0
    rpds-py==2026.5.1
    rtree==1.4.1
    safetensors==0.8.0
    scipy==1.17.1
    semchunk==3.2.5
    setuptools==82.0.1
    shapely==2.1.2
    shellingham==1.5.4
    six==1.17.0
    soupsieve==2.8.4
    sympy==1.13.1
    tabulate==0.10.0
    tokenizers==0.20.3
    torch==2.5.1
    torchvision==0.20.1
    tqdm==4.68.2
    transformers==4.46.3
    tree-sitter==0.25.2
    tree-sitter-c==0.24.2
    tree-sitter-javascript==0.25.0
    tree-sitter-python==0.25.0
    tree-sitter-typescript==0.23.2
    triton==3.1.0 ; python_full_version < '3.13' and platform_machine == 'x86_64' and sys_platform == 'linux'
    typer==0.21.2
    typing-extensions==4.15.0
    typing-inspection==0.4.2
    tzdata==2026.2 ; sys_platform == 'emscripten' or sys_platform == 'win32'
    urllib3==2.7.0
    websockets==16.0
    xlsxwriter==3.2.9
  LOCK

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.6.1/dir2mcp_0.6.1_darwin_amd64.tar.gz"
      sha256 "3a318e16bb454dfc79cd2b13f328a22130bbc4645d3fb1856ae380aae1f1115d"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.6.1/dir2mcp_0.6.1_darwin_arm64.tar.gz"
      sha256 "0f4165f84d09a5a746e640b0a6f2d87af2cff9768db86e22f44e6da222338511"

      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.6.1/dir2mcp_0.6.1_linux_amd64.tar.gz"
      sha256 "8cb7d8deba0770c4a8cf608c18e3279f46ee79f7025e31502bb12b8ce3a98f63"
      define_method(:install) do
        libexec.install "dir2mcp"
        install_docling_runtime
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/dirstral/dir2mcp/releases/download/v0.6.1/dir2mcp_0.6.1_linux_arm64.tar.gz"
      sha256 "a7c105f3d272c432104b63471a5c4a6880be97e2cf3ecbaa54623fc16e362f36"
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
  def post_install
    return unless OS.mac?

    torch_lib = libexec/"docling-venv/lib/python3.12/site-packages/torch/lib"
    return unless torch_lib.directory?

    Pathname.glob(torch_lib/"*.dylib").each do |dylib|
      base = dylib.basename.to_s
      rpath_id = "@rpath/#{base}"
      if Utils.safe_popen_read("otool", "-D", dylib).lines[1]&.strip != rpath_id
        MachO::Tools.change_dylib_id(dylib.to_s, rpath_id)
      end
      unless Utils.safe_popen_read("otool", "-l", dylib).include?(" path @loader_path ")
        MachO::Tools.add_rpath(dylib.to_s, "@loader_path")
      end
      system "codesign", "--force", "--sign", "-", dylib
    end
  end

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
    # Use CPython's stdlib venv bootstrap directly instead of `uv venv`.
    # Some Homebrew python@3.12 bottles on newer macOS releases return an
    # empty `platform.mac_ver()`, which makes `uv venv --python <path>` abort
    # before the environment is created even though `python -m venv` works.
    system python, "-m", "venv", venv_dir
    venv_python = venv_dir/"bin/python"
    system venv_python, "-m", "pip", "install", "--upgrade", "pip"
    # Install the fully pinned tree from the embedded lock so the resolved
    # versions never drift between installs.
    lock_file = buildpath/"docling-lock.txt"
    lock_file.write(DOCLING_LOCK)
    with_env(PIP_DISABLE_PIP_VERSION_CHECK: "1") do
      if OS.mac? && Hardware::CPU.arm?
        # ARM macOS prebuilt wheels for pydantic-core/rpds-py ship with
        # insufficient Mach-O headerpad, so brew's install_name_tool
        # rewrite fails ("Updated load commands do not fit in the
        # header"). Force a source build for these two packages so the
        # resulting .so has enough headerpad. This is the reason the
        # `rust` build dep is still required on this arch.
        #
        # The forced source builds run in PEP 517 isolation, whose build
        # backend (maturin) isn't covered by the runtime lock; pin it via
        # --build-constraint so the build is reproducible too.
        build_constraints = buildpath/"docling-build-constraints.txt"
        build_constraints.write(DOCLING_BUILD_CONSTRAINTS)
        system venv_python, "-m", "pip", "install",
               "--no-binary", "pydantic-core,rpds-py",
               "--build-constraint", build_constraints,
               "--requirement", lock_file
      else
        system venv_python, "-m", "pip", "install",
               "--requirement", lock_file
      end
    end

    prune_problematic_cv2_dylibs!(venv_dir) if OS.mac?

    docling_bin = opt_libexec/"docling-venv/bin/docling"
    real_bin = libexec/"dir2mcp"
    (bin/"dir2mcp").write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
    (bin/"dir2mcp-full").write_env_script real_bin, DIR2MCP_DOCLING_COMMAND: docling_bin
  end

  # Restore the torch dylibs' self-references AFTER Homebrew's relocation.
  #
  # The prebuilt torch wheel ships its dylibs with ID `@rpath/<name>` and an
  # `LC_RPATH @loader_path`, and torchvision's `_C.so` references libtorch via
  # `@rpath/...`. Homebrew's keg relocation rewrites those IDs to absolute Cellar
  # paths and strips `@loader_path`, so the libtorch loaded by `import torch`
  # registers under its absolute name while torchvision still asks for
  # `@rpath/libtorch*` — dyld then loads a second libtorch and torchvision's ops
  # never register ("operator torchvision::nms does not exist") at docling import.
  #
  # This must run in post_install: relocation happens AFTER the install method
  # returns, so an install-time fix is undone (the bug the earlier
  # fix_torch_macos_rpath! couldn't beat). Here we re-assert `@rpath` IDs and the
  # `@loader_path` rpath, matching the working pip layout, then re-sign.

  private

  def prune_problematic_cv2_dylibs!(venv_dir)
    cv2_dylibs = venv_dir/"lib/python3.12/site-packages/cv2/.dylibs"
    return unless cv2_dylibs.directory?

    %w[libb2.1.dylib libtheoradec.1.dylib libtheoraenc.1.dylib].each do |name|
      (cv2_dylibs/name).delete if (cv2_dylibs/name).exist?
    end
  end

  test do
    system "#{bin}/dir2mcp", "version"
    # Exercise the docling runtime (imports torch/torchvision/transformers), not
    # just --help, so an ABI-broken venv fails the test instead of shipping.
    assert_match "Docling version", shell_output("#{libexec}/docling-venv/bin/docling --version 2>&1")
  end
end
