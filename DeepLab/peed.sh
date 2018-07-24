#!/bin/sh

#SBATCH --job-name=FCN_test
#SBATCH --output=ML-%j-Tensorflow.out
#SBATCH --error=ML-%j-Tensorflow.err

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=GPUNodes
#SBATCH --gres=gpu:1
#SBATCH --gres-flags=enforce-binding

#srun tf-py3 virtualenv --system-site-packages $HOME/DeepLab/venv

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install scikit-image

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install keras

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install tensorflow==1.5

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install tensorflow-cpu==1.5

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install python-pil

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install python-numpy

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install jupyter

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install matplotlib

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install slim

#srun tf-py3 $HOME/DeepLab/venv/bin/pip install six

srun cd models/research/
srun export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

srun echo $PYTHONPATH

# Exit immediately if a command exits with a non-zero status.
srun set -e

# Move one-level up to tensorflow/models/research directory.
# srun cd ..

# Update PYTHONPATH.
# export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Set up the working environment.
CURRENT_DIR=$(pwd)
WORK_DIR="${CURRENT_DIR}/models/research/deeplab"

# Run model_test first to make sure the PYTHONPATH is correctly set.
srun tf-py3 $HOME/DeepLab/venv/bin/python "${WORK_DIR}"/model_test.py

srun echo "MODEL_TEST_OK"

# Go to datasets folder and download PASCAL VOC 2012 segmentation dataset.
DATASET_DIR="datasets"
cd "${WORK_DIR}/${DATASET_DIR}"
# sh download_and_convert_voc2012.sh

# Go back to original directory.
cd "${CURRENT_DIR}"

# Set up the working directories.
PASCAL_FOLDER="pascal_voc_seg"
EXP_FOLDER="exp/train_on_trainval_set"
INIT_FOLDER="${WORK_DIR}/${DATASET_DIR}/${PASCAL_FOLDER}/init_models"
TRAIN_LOGDIR="${WORK_DIR}/${DATASET_DIR}/${PASCAL_FOLDER}/${EXP_FOLDER}/train"
EVAL_LOGDIR="${WORK_DIR}/${DATASET_DIR}/${PASCAL_FOLDER}/${EXP_FOLDER}/eval"
VIS_LOGDIR="${WORK_DIR}/${DATASET_DIR}/${PASCAL_FOLDER}/${EXP_FOLDER}/vis"
EXPORT_DIR="${WORK_DIR}/${DATASET_DIR}/${PASCAL_FOLDER}/${EXP_FOLDER}/export"
mkdir -p "${INIT_FOLDER}"
mkdir -p "${TRAIN_LOGDIR}"
mkdir -p "${EVAL_LOGDIR}"
mkdir -p "${VIS_LOGDIR}"
mkdir -p "${EXPORT_DIR}"

# Copy locally the trained checkpoint as the initial checkpoint.
TF_INIT_ROOT="http://download.tensorflow.org/models"
TF_INIT_CKPT="deeplabv3_pascal_train_aug_2018_01_04.tar.gz"
cd "${INIT_FOLDER}"
wget -nd -c "${TF_INIT_ROOT}/${TF_INIT_CKPT}"
tar -xf "${TF_INIT_CKPT}"
cd "${CURRENT_DIR}"

PASCAL_DATASET="${WORK_DIR}/${DATASET_DIR}/${PASCAL_FOLDER}/tfrecord"

srun echo "ALL_PATH_SET"

# Train 10 iterations.
NUM_ITERATIONS=500
srun tf-py3 $HOME/DeepLab/venv/bin/python "${WORK_DIR}"/train.py \
  --logtostderr \
  --train_split="trainval" \
  --model_variant="xception_65" \
  --atrous_rates=6 \
  --atrous_rates=12 \
  --atrous_rates=18 \
  --output_stride=16 \
  --decoder_output_stride=4 \
  --train_crop_size=513 \
  --train_crop_size=513 \
  --train_batch_size=4 \
  --training_number_of_steps="${NUM_ITERATIONS}" \
  --fine_tune_batch_norm=true \
  --tf_initial_checkpoint="${INIT_FOLDER}/deeplabv3_pascal_train_aug/model.ckpt" \
  --train_logdir="${TRAIN_LOGDIR}" \
  --dataset_dir="${PASCAL_DATASET}"

srun echo "TRAIN_END"

# Run evaluation. This performs eval over the full val split (1449 images) and
# will take a while.
# Using the provided checkpoint, one should expect mIOU=82.20%.
srun tf-py3 $HOME/DeepLab/venv/bin/python "${WORK_DIR}"/eval.py \
  --logtostderr \
  --eval_split="val" \
  --model_variant="xception_65" \
  --atrous_rates=6 \
  --atrous_rates=12 \
  --atrous_rates=18 \
  --output_stride=16 \
  --decoder_output_stride=4 \
  --eval_crop_size=513 \
  --eval_crop_size=513 \
  --checkpoint_dir="${TRAIN_LOGDIR}" \
  --eval_logdir="${EVAL_LOGDIR}" \
  --dataset_dir="${PASCAL_DATASET}" \
  --max_number_of_evaluations=1

srun echo "EVAL_END"

# Visualize the results.
srun tf-py3 $HOME/DeepLab/venv/bin/python "${WORK_DIR}"/vis.py \
  --logtostderr \
  --vis_split="val" \
  --model_variant="xception_65" \
  --atrous_rates=6 \
  --atrous_rates=12 \
  --atrous_rates=18 \
  --output_stride=16 \
  --decoder_output_stride=4 \
  --vis_crop_size=513 \
  --vis_crop_size=513 \
  --checkpoint_dir="${TRAIN_LOGDIR}" \
  --vis_logdir="${VIS_LOGDIR}" \
  --dataset_dir="${PASCAL_DATASET}" \
  --max_number_of_iterations=1

srun echo "VISUALISATION_END"

# Export the trained checkpoint.
CKPT_PATH="${TRAIN_LOGDIR}/model.ckpt-${NUM_ITERATIONS}"
EXPORT_PATH="${EXPORT_DIR}/frozen_inference_graph.pb"

srun tf-py3 $HOME/DeepLab/venv/bin/python "${WORK_DIR}"/export_model.py \
  --logtostderr \
  --checkpoint_path="${CKPT_PATH}" \
  --export_path="${EXPORT_PATH}" \
  --model_variant="xception_65" \
  --atrous_rates=6 \
  --atrous_rates=12 \
  --atrous_rates=18 \
  --output_stride=16 \
  --decoder_output_stride=4 \
  --num_classes=21 \
  --crop_size=513 \
  --crop_size=513 \
  --inference_scales=1.0

srun echo "EXPORT_END"

# Run inference with the exported checkpoint.
# Please refer to the provided deeplab_demo.ipynb for an example.
