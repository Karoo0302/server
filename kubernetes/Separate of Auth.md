# Separation of Authority
- - -

### 쿠버네티스 권한 분리

쿠버네티스 클러스터의 api에 접근하기 위해서는 사용자 인증이 필요하다.
인증이 완료된 사용자만 api에 접근이 가능하기 때문에 namespace 별 분리 및 계정별 권한을 분리 할 수 있다.

### Role & Cluster Role

Role은 특정 api나 리소스에 대한 권한들을 명시해둔 규칙들의 집합이며 롤은 그 롤이 속한 네임스페이스에만 적용되지만, 클러스터롤은 특정 네임스페이스가 아닌 클러스터 전체에 대한 권한을 적용할 수 있다.
<br>
Role에는 rule이 포함된다. 룰을 롤이 가지는 규칙을 명시해준다.

|Verb|의미|
|-----|---|
|create|새로운 리소스 생성|
|get|개별 리소스 조회|
|list|여러건의 리소스 조회|
|update|기존 리소스내용 전체 업데이트|
|patch|기존 리소스중 일부 내용 변경|
|delete|개별 리소스 삭제|
|deletecollection|여러 리소스 삭제|

### 권한 생성 및 적용하기

Cluster Role 만들기

Cluster Role은 클러스터 자체에 적용되는 롤이기 때문에 namespace를 지정하지 않아도 된다.
우선 serviceaccount를 생성해준다.

	kubectl craete serviceaccount test --namespace default

#### token 생성하기

kubernetes 1.20~ 버전 이후 부터는 보안이슈로 인하여 serviceaccount를 만들 때 토큰이 자동생성되지 않는다.

* token.yaml

```
apiVersion: v1
kind: Secret
metadata:
  name: test-token
  annotations:
    kubernetes.io/service-account.name: test-bot
type: kubernetes.io/service-account-token
```

	kubectl apply -f token.yaml
	
	kubectl describe secret test-token

위의 token을 복사해준다.

	export TEST_TOKEN="붙여넣기"
	
	kubectl config set-credentials --token=$TEST_TOKEN test
	
	kubectl config set-context --cluster=kubernetes --user=test test
	
	kubectl config get-contexts
	
* ClusterRole & Role binding .yaml

```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: test-clusterrole
rules:
- apiGroups: ["","metrics.k8s.io"]
  resources: ["pods","nodes"]
  verbs: ["get", "list", "top"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: test-rolebinding
subjects:
- kind: ServiceAccount
  name: test
  namespace: default
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: test-clusterrole
  apiGroup: rbac.authorization.k8s.io
```

위와 같이 만들어주면 Cluster role이 생성된다.

.kube/config 안에 context 들이 구성되어 있으므로 해당내용을 확인하면 된다.