# nrn-musa

`nrn-musa` is the Moore Threads MUSA maintenance line of
[NEURON](https://github.com/neuronsimulator/nrn), a simulator for neurons and
networks with Python and CoreNEURON interfaces.

## Source and version

- Upstream project: NEURON
- Inherited version: `v9.0.1`
- Upstream baseline: `bab66a6675840360fadb31a251f4cf3a214856be`
- Maintainer: Moore Threads

The MUSA line adds MUSA-aware CoreNEURON GPU integration and memory paths while
retaining the upstream simulator, Python, CPU, CUDA, tests, and documentation
structure.

## Requirements and build

Use CMake 3.19 or newer, a C++17-capable compiler, Python, MPI when required,
and the MUSA SDK for the MUSA backend. A typical configure/build outline is:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

Follow the project options for Python, CoreNEURON, and accelerator support.
External numerical libraries and toolkits are supplied by the deployment.

## Layout and contribution

Core sources are under `src/`, Python support under `share/lib/python/`, and
CoreNEURON, tests, and CMake modules retain the upstream organization. Keep
MUSA changes isolated and preserve upstream notices.

Moore Threads maintains this source line. See [LICENSE](LICENSE) for the
applicable declaration.
