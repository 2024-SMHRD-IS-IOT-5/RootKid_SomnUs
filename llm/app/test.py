import sys
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # 현재 실행되는 embed.py의 경로
FAISS_DIR = os.path.join(BASE_DIR, "faiss")
CORE_DIR = os.path.join(BASE_DIR,"core")

# `faiss/` 폴더를 모듈 경로에 추가
sys.path.append(BASE_DIR)  # 현재 디렉토리 추가
sys.path.append(FAISS_DIR)  # `faiss` 폴더 직접 추가
sys.path.append(CORE_DIR)

print(f"📂 BASE_DIR: {BASE_DIR}")
print(f"📂 FAISS_DIR: {FAISS_DIR}")
print("\n🔍 Updated sys.path:")
print("\n".join(sys.path))
