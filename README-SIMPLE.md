# 🚀 Simple n8n Deployment

최소한의 구성으로 n8n을 빠르게 배포하는 방법들입니다.

## 🎯 **3가지 간단한 배포 방법**

### **방법 1: 로컬 Docker Compose (가장 간단)**

```bash
# 1. Docker Compose 실행
docker-compose up -d

# 2. n8n 접속
# http://localhost:5678
```

### **방법 2: GCP 단일 명령어 배포 (권장)**

```bash
# 1. 환경 변수 설정
export GCP_PROJECT_ID=your-project-id

# 2. 배포 실행
./one-command-deploy.sh

# 3. 출력된 IP로 접속
# http://[IP]:5678
```

### **방법 3: GCP 상세 스크립트 배포**

```bash
# 1. 환경 변수 설정
export GCP_PROJECT_ID=your-project-id
export GCP_ZONE=us-central1-a

# 2. 배포 실행
./simple-n8n-deploy.sh

# 3. 출력된 IP로 접속
# http://[IP]:5678
```

## 🧹 **정리 방법**

### **로컬 정리**

```bash
docker-compose down
docker volume rm gcp-n8n-setup_n8n_data
```

### **GCP 정리**

```bash
gcloud compute instances delete n8n-simple --zone=us-central1-a --project=$GCP_PROJECT_ID
gcloud compute firewall-rules delete allow-n8n --project=$GCP_PROJECT_ID
```

## 📋 **요구사항**

### **로컬 실행**

- Docker
- Docker Compose

### **GCP 배포**

- Google Cloud SDK (gcloud)
- GCP 프로젝트
- Compute Engine API 활성화

## 🔒 **보안 고려사항**

현재 설정은 **개발/테스트용**입니다. 프로덕션 사용 시 다음을 추가하세요:

- SSL 인증서 (Let's Encrypt)
- 도메인 설정
- 방화벽 규칙 제한
- 백업 전략
- 모니터링

## 🆚 **기존 복잡한 구성 vs 간단한 구성**

| 구분          | 기존 구성       | 간단한 구성 |
| ------------- | --------------- | ----------- |
| **파일 수**   | 15+ 파일        | 3-4 파일    |
| **배포 시간** | 10-15분         | 2-3분       |
| **복잡도**    | 높음            | 낮음        |
| **유지보수**  | 어려움          | 쉬움        |
| **기능**      | 완전한 프로덕션 | 기본 기능   |

## 🎉 **결론**

**빠른 테스트/개발**: 방법 1 (로컬 Docker)
**간단한 클라우드 배포**: 방법 2 (단일 명령어)
**상세한 제어**: 방법 3 (상세 스크립트)

기존의 복잡한 Terraform + Ansible + GitHub Actions 구성 대신, 위의 간단한 방법들을 사용하면 **90%의 복잡도를 줄이면서도** n8n을 빠르게 구축할 수 있습니다.
