#!/bin/bash

# update.sh
# GitHubリポジトリ情報
REPO="username/my-scripts"  # 置き換えてください
BRANCH="main"               # 使用するブランチ
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/scripts"

# ダウンロード先のデフォルトディレクトリ
DEFAULT_DEST_DIR="/usr/local/bin"
DEST_DIR="$DEFAULT_DEST_DIR"

# 対話型ディレクトリ選択
function browse_directory() {
  local current_dir="$1"

  echo "現在のディレクトリ: $current_dir"
  echo "リストを取得中..."
  
  # GitHubのディレクトリ構造を取得
  curl -s "$BASE_URL/$current_dir" | grep -oP '(?<=href=")[^"]+' | grep -vE '\.\.|raw.githubusercontent|tree' > temp_list.txt

  echo "選択肢:"
  i=1
  options=()
  while IFS= read -r line; do
    echo "[$i] $line"
    options+=("$line")
    i=$((i + 1))
  done < temp_list.txt
  echo "[0] ダウンロードを確定"

  # ユーザーの入力を受け取る
  read -p "番号を選択してください: " choice
  if [[ "$choice" -eq 0 ]]; then
    echo "ダウンロードを確定します。"
    return 0
  elif [[ "$choice" -ge 1 && "$choice" -le "${#options[@]}" ]]; then
    selected="${options[$((choice - 1))]}"
    if [[ "$selected" == */ ]]; then
      browse_directory "$current_dir$selected"
    else
      selected_files+=("$current_dir$selected")
    fi
  else
    echo "無効な選択肢です。再試行してください。"
  fi

  browse_directory "$current_dir"
}

# ダウンロード処理
function download_files() {
  mkdir -p "$DEST_DIR"
  for file in "${selected_files[@]}"; do
    echo "ダウンロード中: $file"
    curl -sfSL "$BASE_URL/$file" -o "$DEST_DIR/$(basename $file)"
    if [[ $? -eq 0 ]]; then
      chmod +x "$DEST_DIR/$(basename $file)"
      echo "ダウンロード成功: $DEST_DIR/$(basename $file)"
    else
      echo "ダウンロード失敗: $file"
    fi
  done
}

# メイン処理
selected_files=()
browse_directory ""

echo "現在のダウンロード先: $DEST_DIR"
read -p "ダウンロード先を変更しますか？ (y/n): " change_dest
if [[ "$change_dest" == "y" || "$change_dest" == "Y" ]]; then
  read -p "新しいダウンロード先を入力してください: " DEST_DIR
fi

echo "以下のスクリプトをダウンロードします:"
for file in "${selected_files[@]}"; do
  echo "- $file"
done

read -p "ダウンロードを実行しますか？ (y/n): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  download_files
else
  echo "ダウンロードがキャンセルされました。"
fi

echo "完了。"

