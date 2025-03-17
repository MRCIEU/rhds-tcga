# Installing mamba

Below shows how to install the
[miniforge distribution](https://github.com/conda-forge/miniforge)
of mamba with default settings:

```
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
export PATH="~/miniforge3/bin:$PATH"
mamba init
```

Logout and then login again.

```
export PATH="~/miniforge3/bin:$PATH"
mamba activate ~/miniforge3
```

Mamba is ready!
