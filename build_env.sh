#!/bin/sh

#SBATCH --job-name=build_env
#SBATCH --output=build_env.out
#SBATCH --error=build_env.err

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=GPUNodes
#SBATCH --gres=gpu:1
#SBATCH --gres-flags=enforce-binding

srun tf-py3 virtualenv --system-site-packages venv

srun tf-py3 venv/bin/pip install tensorboardX

srun tf-py3 venv/bin/pip install torchvision

srun tf-py3 venv/bin/pip install pytorch

srun tf-py3 venv/bin/pip install scikit-image

srun tf-py3 venv/bin/pip install keras

srun tf-py3 venv/bin/pip install tensorflow==1.5

srun tf-py3 venv/bin/pip install tensorflow-cpu==1.5

srun tf-py3 venv/bin/pip install python-pil

srun tf-py3 venv/bin/pip install python-numpy

srun tf-py3 venv/bin/pip install jupyter

srun tf-py3 venv/bin/pip install matplotlib
