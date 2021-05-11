# These settings are for running spark shell from a pod running inside the cluster,
# for example a pod created from:
# oc run -i -t --serviceaccount=spark spark --image=quay.io/erikerlandson/spark-rapids:latest --command -- /bin/bash

# Spark will want this Service created for Executors to route back to
# the Driver running on this pod.

# kind: Service
# apiVersion: v1
# metadata:
#   name: < this pod name here >
# spec:
#   selector:
#     deploymentconfig: spark
#   clusterIP: None
#   type: ClusterIP
#   sessionAffinity: None

${SPARK_HOME}/bin/spark-shell --master k8s://https://kubernetes.default:443 \
             --conf spark.kubernetes.authenticate.submission.oauthToken=$(cat /run/secrets/kubernetes.io/serviceaccount/token) \
             --conf spark.kubernetes.container.image=quay.io/erikerlandson/spark-rapids:latest \
             --conf spark.driver.host=$(hostname) \
             --conf spark.locality.wait=0s \
             --conf spark.driver.memory=2g  --conf spark.executor.memory=4g \
             --conf spark.executor.cores=1  --conf spark.task.cpus=1 \
             --conf spark.plugins=com.nvidia.spark.SQLPlugin \
             --conf spark.executor.resource.gpu.discoveryScript=/opt/getGpusResources.sh \
             --conf spark.executor.resource.gpu.vendor=nvidia.com  \
             --conf spark.rapids.sql.concurrentGpuTasks=1  \
             --conf spark.rapids.memory.pinnedPool.size=1g  \
             --conf spark.task.resource.gpu.amount=1  \
             --conf spark.executor.resource.gpu.amount=1 \
             --conf spark.worker.resource.gpu.amount=1  \
             --conf spark.sql.files.maxPartitionBytes=512m   \
             --conf spark.sql.shuffle.partitions=10
