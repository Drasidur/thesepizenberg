#!/bin/sh

#SBATCH --job-name=FCN_test
#SBATCH --output=ML-%j-Tensorflow.out
#SBATCH --error=ML-%j-Tensorflow.err

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=GPUNodes
#SBATCH --gres=gpu:1
#SBATCH --gres-flags=enforce-binding

srun tf-py3 virtualenv --system-site-packages $HOME/DeepLab/venv

srun tf-py3 $HOME/DeepLab/venv/bin/pip install scikit-image

srun tf-py3 $HOME/DeepLab/venv/bin/pip install keras

srun tf-py3 $HOME/DeepLab/venv/bin/pip install tensorflow==1.5

srun tf-py3 $HOME/DeepLab/venv/bin/pip install tensorflow-cpu==1.5

srun tf-py3 $HOME/DeepLab/venv/bin/pip install python-pil

srun tf-py3 $HOME/DeepLab/venv/bin/pip install python-numpy

srun tf-py3 $HOME/DeepLab/venv/bin/pip install jupyter

srun tf-py3 $HOME/DeepLab/venv/bin/pip install matplotlib

srun tf-py3 $HOME/DeepLab/venv/bin/pip install slim

srun cd models/research/
srun export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

srun echo $PYTHONPATH

srun tf-py3 $HOME/DeepLab/venv/bin/python "$HOME/DeepLab/models/research/deeplab/model_test.py"
