# K8S Health Check
- - -

쿠버네티스는 각 컨테이너의 상태를 주기적으로 체크해서 문제가 있는 컨테이너를 자동으로 재시작하거나 서비스에서 제외 할 수 있다.

- 컨테이너 상태 체크 방법
1. Liveness probe : 컨테이너가 살아있는지 체크
2. Readiness probe : 서비스가 가능한 상태인지를 체크

- 체크 방식
1. Command probe : 컨테이너의 상태 체크를 쉘 명령어로 수행한 후 체크
2. HTTP probe : 가장 많이 사용하는 probe 방식, http get으로 리턴 응답코드 체크
3. TCP probe : 지정된 포트에 tcp 연결을 시도하여 성공여부 체크

### 적용방법

yaml 파일안에 적용 가능하며 적용위치는 spec/spec 라인에 적용 가능하다.

- Command probe

```
apiVersion: v1
kind: Pod
metadata:  
  name: liveness-pod
spec:  
  containers:  
  - name: liveness-test
    image: testimg 
	imagePullPolicy: Always    
	ports:    
	- containerPort: 5000  
	livenessProbe:      
	  exec:        
	    command:        
		- cat        
		- /tmp/healthy
```

- HTTP probe

```
apiVersion: v1
kind: Pod
metadata:  
  name: readiness-pod
spec:  
  containers:  
  - name: readiness-test
    image: testimg 
	imagePullPolicy: Always    
	ports:    
	- containerPort: 5000
	readinessProbe:      
	  httpGet
	    path: /readiness
		prot: 5000
```

- TCP probe

```
apiVersion: v1
kind: Pod
metadata:  
  name: test-pod
spec:  
  containers:  
  - name: live-test
    image: testimg 
	imagePullPolicy: Always    
	ports:    
	- containerPort: 5000
	livenessProbe:      
	  tcpSocket:
	    prot: 5000
	  initialDelaySeconds: 5
	  periodSeconds: 5
```

initialDelaySeconds
컨테이너 가동 후 설정된 값만큼 대기 후 헬스체크를 진행한다.

periodSeconds
설정된 주기에 따라 헬스체크를 진행한다.
