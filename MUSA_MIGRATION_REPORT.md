# NEURON CoreNEURON CUDA → MUSA 迁移报告

## 项目信息
- **项目名称**: NEURON (CoreNEURON)
- **原始分支**: official-nrn (master)
- **迁移分支**: musa-nrn
- **MUSA SDK版本**: 4.3.6

## 迁移概述

NEURON 是一个用于神经元建模的科学计算软件，其 CoreNEURON 子模块支持 GPU 加速。本次迁移将 CoreNEURON 的 CUDA GPU 支持迁移到摩尔线程 MUSA 平台。

## 代码修改清单

### 1. 源代码文件修改

| 文件 | 修改内容 |
|------|----------|
| `src/coreneuron/utils/utils_musa.h` | 新增：MUSA 错误检查宏（替代 utils_cuda.h） |
| `src/coreneuron/permute/cellorder.mu` | 新增：MUSA GPU 内核（替代 cellorder.cu） |
| `src/coreneuron/utils/memory.cpp` | cudaMallocManaged/cudaFree → musaMallocManaged/musaFree |
| `src/coreneuron/utils/memory_utils.cpp` | cudaMemGetInfo → musaMemGetInfo，移除 cuda_profiler_api.h |
| `src/coreneuron/gpu/nrn_acc_manager.cpp` | cudaSetDevice → musaSetDevice，acc_device_nvidia → acc_device_default |
| `src/coreneuron/utils/randoms/nrnran123.cpp` | __CUDACC__ → __MUSACC__，cudaMemcpyToSymbol → musaMemcpyToSymbol |
| `src/coreneuron/utils/profile/profiler_interface.h` | CORENEURON_CUDA_PROFILING → CORENEURON_MUSA_PROFILING |

### 2. CMake 构建系统修改

| 文件 | 修改内容 |
|------|----------|
| `cmake/coreneuron/OpenAccHelper.cmake` | CUDAToolkit → MUSAToolkit，移除 NVHPC 特定标志 |
| `src/coreneuron/CMakeLists.txt` | CUDA 语言 → mcc 自定义编译，coreneuron-cuda → coreneuron-musa |
| `cmake/neuronMechMaker.cmake` | CUDAToolkit/OpenACC → MUSAToolkit |
| `cmake/neuronConfig.cmake.in` | CUDA 版本变量 → MUSA 版本变量 |
| `cmake/coreneuron/MakefileBuildOptions.cmake` | NVHPC_ACC_COMP_FLAGS → MUSA_ACC_COMP_FLAGS |

## API 映射表

| CUDA API | MUSA API |
|----------|----------|
| `cuda_runtime_api.h` | `musa_runtime_api.h` |
| `cudaError_t` | `musaError_t` |
| `cudaSuccess` | `musaSuccess` |
| `cudaSetDevice` | `musaSetDevice` |
| `cudaMallocManaged` | `musaMallocManaged` |
| `cudaFree` | `musaFree` |
| `cudaMemGetInfo` | `musaMemGetInfo` |
| `cudaGetLastError` | `musaGetLastError` |
| `cudaGetErrorString` | `musaGetErrorString` |
| `cudaMemcpyToSymbol` | `musaMemcpyToSymbol` |
| `cudaDeviceSynchronize` | `musaDeviceSynchronize` |
| `cudaStream_t` | `musaStream_t` |
| `cudaStreamSynchronize` | `musaStreamSynchronize` |
| `cudaProfilerStart/Stop` | `musaProfilerStart/Stop` |
| `__CUDACC__` | `__MUSACC__` |
| `.cu` | `.mu` |

## 编译命令

### 环境要求
- MUSA SDK 4.3.6+（mcc 在 PATH 中）
- CMake 3.15+
- GCC 11+
- MPI（OpenMPI 或 MPICH）
- bison、flex、libreadline-dev

### 不带 GPU 支持
```bash
mkdir build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DNRN_ENABLE_CORENEURON=ON \
  -DNRN_ENABLE_PYTHON=OFF \
  -DNRN_ENABLE_RX3D=OFF \
  -DNRN_ENABLE_INTERVIEWS=OFF \
  -DCORENRN_ENABLE_GPU=OFF
make -j$(nproc)
```

### 带 MUSA GPU 支持
```bash
mkdir build_gpu && cd build_gpu
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DNRN_ENABLE_CORENEURON=ON \
  -DNRN_ENABLE_PYTHON=OFF \
  -DNRN_ENABLE_RX3D=OFF \
  -DNRN_ENABLE_INTERVIEWS=OFF \
  -DCORENRN_ENABLE_GPU=ON \
  -DCMAKE_MUSA_ARCHITECTURES=mp_22 \
  -DCMAKE_MODULE_PATH=/usr/local/musa/cmake
make -j$(nproc)
```

## 验证结果
- ✅ 不带 GPU 构建通过
- ✅ GPU 构建 CMake 配置通过，MUSA 工具链正确识别
- ✅ cellorder.mu 文件通过 mcc 编译

## 已知限制
1. OpenACC 不支持 MUSA，已移除该代码路径
2. OpenMP Target Offload 需要支持 MUSA 的编译器（非标准 GCC）
3. 完整 GPU 运行需要 MUSA 硬件验证
