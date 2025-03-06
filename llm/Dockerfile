FROM python:3.13.2

# 환경 변수 설정
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 작업 디렉토리 설정
WORKDIR /app

# requirements.txt 복사 후 패키지 설치
COPY requirements.txt ./  
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 프로젝트 전체 파일 복사 (캐시 최적화)
COPY . /app

# 애플리케이션이 사용할 포트 노출
EXPOSE 8000

# FastAPI 애플리케이션 실행 (main.py의 위치에 따라 변경)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
