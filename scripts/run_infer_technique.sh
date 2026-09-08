#!/usr/bin/env bash
set -euo pipefail

# Auto-detect project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORKSPACE="${PROJECT_ROOT}"

# ========== Configuration ==========
# Audio directory (can point to the exported RWC tracks)
AUDIO_DIR="${WORKSPACE}/data/rwc_full_tracks"

# Output directory for results
OUTPUT_DIR="${WORKSPACE}/output/rwc_full_tracks_technique_classification"

# Model checkpoints
# NOTE_MODEL_CHECKPOINT="${WORKSPACE}/checkpoints/note_tech_model.pth"
NOTE_MODEL_CHECKPOINT="${WORKSPACE}/checkpoints/note_tech_model.pth"
TRANSCRIPTOR_CHECKPOINT="${WORKSPACE}/checkpoints/transcriptor_model.pth"

# Transcription features to use
TRANS_FEATURES_LIST="reg_onset_output reg_offset_output frame_output velocity_output"

# ========== Threshold Parameters ==========
FRAME_THRESHOLD="0.05"
ONSET_THRESHOLD="0.3"
OFFSET_THRESHOLD="0.3"
PEDAL_OFFSET_THRESHOLD="0.2"

# ===================================

if [[ ! -d "$AUDIO_DIR" ]]; then
  echo "Audio directory not found: $AUDIO_DIR"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Starting End-to-End Inference and Evaluation..."
echo "Audio Source: $AUDIO_DIR"

# 直接呼叫更新後的 Python 腳本處理整個資料夾
# --gt_technique auto 會自動根據 RWC 檔名解析標籤並計算 Accuracy
python "${WORKSPACE}/piano_transcription/pytorch/infer_technique.py" \
  --audio_path "$AUDIO_DIR" \
  --transcriptor_checkpoint "$TRANSCRIPTOR_CHECKPOINT" \
  --note_model_checkpoint "$NOTE_MODEL_CHECKPOINT" \
  --output_dir "$OUTPUT_DIR" \
  --use_trans_features \
  --trans_features_list $TRANS_FEATURES_LIST \
  --gt_technique "auto" \
  --device 0 \
  --frame_threshold $FRAME_THRESHOLD \
  --onset_threshold $ONSET_THRESHOLD \
  --offset_threshold $OFFSET_THRESHOLD \
  --pedal_offset_threshold $PEDAL_OFFSET_THRESHOLD

echo "-------------------------------------------"
echo "Done! Full report shown above."
echo "Results (CSV/MIDI) are in: $OUTPUT_DIR"
