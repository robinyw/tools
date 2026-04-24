export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export YARN_CONF_DIR=/opt/hadoop/etc/hadoop
export SPARK_LOG_DIR=/opt/spark/logs
export SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=hdfs://mycluster/spark/history -Dspark.history.ui.port=18080"
