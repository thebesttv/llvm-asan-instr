# ---------------------------------------------------------
# Stage 1: Builder
# ---------------------------------------------------------
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装构建依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    python3 \
    libpython3-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# 2. 拷贝源码 (依赖 .dockerignore 过滤无关文件)
COPY . .

# 3. 执行配置脚本
RUN chmod +x build-release.sh && ./build-release.sh

# 4. 切换到构建目录进行编译
# 脚本里虽然 cd 进了 build-release，但在 Dockerfile 中每个 RUN 指令都是独立的进程，
# 所以这里需要显式 WORKDIR 进入目录
WORKDIR /workspace/build-release

# 5. 编译 (耗时步骤)
RUN ninja

# 6. 安装
# 因为我们在 cmake 中指定了 PREFIX=/llvm-asan-instr，
# 这里 ninja install 会直接把文件写入 /llvm-asan-instr 目录
RUN ninja install

# ---------------------------------------------------------
# Stage 2: Final Image
# ---------------------------------------------------------
# FROM ubuntu:24.04
FROM thebesttv/llvm-asan-instr:base

ENV DEBIAN_FRONTEND=noninteractive

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    libxml2 \
    && rm -rf /var/lib/apt/lists/*

# 从构建阶段拷贝整个安装目录
COPY --from=builder /llvm-asan-instr /llvm-asan-instr

# 将自定义路径添加到 PATH，以便直接使用 clang 命令
ENV PATH="/llvm-asan-instr/bin:${PATH}"

# 验证安装
RUN clang --version

WORKDIR /root
CMD ["/bin/bash"]
