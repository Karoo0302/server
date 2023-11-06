# ECR 연동하기
- - -

ECR에서 push와 pull을 하려면 aws-cli를 통해 로그인을 한 후 인증이 완료되면 ECR에 접근가능하다.
aws-cli로 로그인을 하게되면 ~/.docker/config.json에 로그인 정보가 기록된다
kubernetes에서는 config.json의 인증정보를 사용하여 ECR로부터 컨테이너 이미지를 pull 받기위한 secret을 사용한다.

### Secret 생성 및 적용

- secret 생성

```
kubectl create secret generic [secret이름] \
--from-file=.dockerconfigjson=$HOME/.docker/config.json \
--type=kubernetes.io/dockerconfigjson
```

- secret 적용하기

deployment yaml 파일 안에 적용이 가능하다.

spec/template/spec 안에 적용가능하다.

```
  spec:
    template:
	  spec:
	    imagePullSecrets:
		- name: [secret 이름]
```

하지만 이 aws 인증은 12시간마다 세션이 만료되기 때문에 주기적으로 인증해주어야 한다.
인증을 진행하기 위하여 cronjob을 통해 실행시킨다.

### 인증 cronjob

cronjob을 실행하기 위해선 aws에 접근한 access_key와 secret_access_key가 필요하다. 이것을 secret으로 저장한다.

- aws-config-secret.yaml

```
apiVersion: v1
kind: Secret
metadata:
  name: aws-configure-secret
  namespace:
type: Opaque
data:
  ACCESS_KEY:
  SECRET_ACCESS_KEY: 
```

- cronjob.yaml

	apiVersion: batch/v1
	kind: CronJob
	metadata:
	  name: [namespace]-ecr-cronjob
	  namespace: [namespace]
	spec:
	  schedule: "0 */8 * * *"
	  concurrencyPolicy: Forbid
	  successfulJobsHistoryLimit: 1
	  failedJobsHistoryLimit: 1
	  jobTemplate:
	    spec:
	    backoffLimit: 4
	    template:
	      spec:
	        serviceAccountName: default
	        terminationGracePeriodSeconds: 0
	        restartPolicy: Never
	        volumes:
	        - name: shared-data
	          emptyDir: {}
	        containers:
	        - name: aws-cli
	          securityContext:
	            allowPrivilegeEscalation: false
	            runAsUser: 0
	          imagePullPolicy: IfNotPresent
	          image: lawdiansz/aws-cli:latest
	          volumeMounts:
	          - name: shared-data
	            mountPath: /data
	          envFrom:
	          - secretRef:
	            name: aws-configure-secret
	          command:
	          - "/bin/sh"
	          - "-c"
	          - |
	            aws configure set aws_access_key_id "${ACCESS_KEY}"
	            aws configure set aws_secret_access_key "${SECRET_ACCESS_KEY}"
	            aws configure set region ap-northeast-2
	            aws configure set output json
	            aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 688312605767.dkr.ecr.ap-northeast-2.amazonaws.com
                cp /root/.docker/config.json /data/config.json
            - name: kubectl
              securityContext:
                allowPrivilegeEscalation: false
                runAsUser: 0
              imagePullPolicy: IfNotPresent
              image: bitnami/kubectl
              volumeMounts:
              - name: shared-data
                mountPath: /data
              command:
              - "/bin/sh"
              - "-c"
              - |
                sleep 20
                ls -l /data
                kubectl delete secret -n [namespace] ecr
                kubectl create secret generic ecr --from-file=.dockerconfigjson=/data/config.json --type=kubernetes.io/dockerconfigjson -n [namespace]

schedule: "0 */8 * * *"
은 8시간마다 시도한다는 셋팅이다. 처음 셋팅할 경우 * * * * * 으로 최초 셋팅을 진행한 후 다시 바
꾸어서 적용해준다.
spec에 successfulJobsHistoryLimit 같은 경우 파드의 생성 제한을 잡아주는 셋팅이다.
이후 롤바인딩을 해주어야 secret이 생성된다.
kubectl create clusterrolebinding [rolename] --clusterrole cluster-admin --serviceaccount=[서비스
어카운트:default]
