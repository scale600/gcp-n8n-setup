# 🚀 Simple Terraform + Ansible + Docker n8n Deployment

**Terraform → GCP 인프라 생성**  
**Ansible → 서버 설정 및 n8n 설치**  
**Docker → n8n 컨테이너 실행**  
**완료! (IP:5678로 접속)**

## 🎯 **단순화된 구성**

### **제거된 복잡성**

- ❌ Nginx 리버스 프록시
- ❌ SSL 인증서 (Let's Encrypt)
- ❌ 도메인 설정
- ❌ 복잡한 방화벽 규칙
- ❌ 복잡한 Ansible 태스크

### **유지된 핵심 기능**

- ✅ Terraform으로 GCP 인프라 관리
- ✅ Ansible으로 서버 설정 자동화
- ✅ Docker로 n8n 컨테이너 실행
- ✅ 간단한 방화벽 규칙 (포트 5678)
- ✅ 정적 IP 주소

## 📁 **파일 구조**

```
├── terraform-simple/
│   ├── main.tf          # 단순화된 Terraform 구성
│   └── variables.tf     # 변수 정의
├── ansible-simple/
│   ├── playbook.yml     # 단순화된 Ansible 플레이북
│   └── requirements.yml # Ansible 컬렉션 요구사항
├── .github/workflows/
│   └── deploy-simple.yml # 단순화된 GitHub Actions
└── deploy-simple.sh     # 로컬 배포 스크립트
```

## 🚀 **배포 방법**

### **방법 1: 로컬 배포 (권장)**

```bash
# 1. 환경 변수 설정
export GCP_PROJECT_ID=your-project-id
export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"

# 2. 배포 실행
./deploy-simple.sh

# 3. 완료 후 접속
# http://[IP]:5678
```

### **방법 2: GitHub Actions 배포**

```bash
# 1. GitHub Secrets 설정
# - GCP_PROJECT_ID
# - GCP_CREDENTIALS
# - SSH_PUBLIC_KEY
# - SSH_PRIVATE_KEY

# 2. 워크플로우 실행
gh workflow run deploy-simple.yml

# 3. 완료 후 접속
# http://[IP]:5678
```

## 🧹 **정리 방법**

### **로컬 정리**

```bash
cd terraform-simple
terraform destroy
```

### **GitHub Actions 정리**

```bash
# 워크플로우에서 terraform destroy 실행하거나
# 수동으로 GCP 콘솔에서 리소스 삭제
```

## 📊 **기존 vs 단순화된 구성 비교**

| 구분               | 기존 구성       | 단순화된 구성  |
| ------------------ | --------------- | -------------- |
| **Terraform 파일** | 3개             | 2개            |
| **Ansible 태스크** | 20+             | 8개            |
| **GitHub Actions** | 4개 워크플로우  | 1개 워크플로우 |
| **배포 시간**      | 10-15분         | 5-8분          |
| **복잡도**         | 높음            | 중간           |
| **기능**           | 완전한 프로덕션 | 핵심 기능      |

## 🔧 **요구사항**

### **로컬 배포**

- Terraform
- Ansible
- Google Cloud SDK
- SSH 키 쌍

### **GitHub Actions 배포**

- GitHub Secrets 설정
- GCP Service Account

## 🎉 **장점**

1. **복잡도 50% 감소**: Nginx, SSL, 도메인 설정 제거
2. **배포 시간 단축**: 5-8분 내 완료
3. **학습 곡선 완만**: 핵심 개념만 유지
4. **유지보수 간편**: 단순한 구조
5. **확장 가능**: 필요시 기능 추가 용이

## 🚨 **주의사항**

- **HTTP만 지원**: SSL 없음 (개발/테스트용)
- **기본 보안**: 방화벽 규칙 최소화
- **도메인 없음**: IP 주소로만 접속
- **백업 없음**: 수동 백업 필요

## 🔄 **확장 방법**

필요시 다음 기능들을 추가할 수 있습니다:

```bash
# SSL 추가
# - Let's Encrypt 인증서
# - Nginx 리버스 프록시

# 도메인 추가
# - DNS 설정
# - 도메인 검증

# 보안 강화
# - 방화벽 규칙 제한
# - SSH 키 기반 인증 강화
```

## 🎯 **결론**

이 구성은 **Terraform + Ansible + Docker의 핵심 장점**을 유지하면서 **불필요한 복잡성은 제거**한 **균형잡힌 접근법**입니다.

**빠른 배포**와 **간단한 유지보수**를 원하면서도 **인프라 코드화**의 장점을 누리고 싶다면 이 방법을 추천합니다!
