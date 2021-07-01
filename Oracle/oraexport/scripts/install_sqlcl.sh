TARGET_FOLDER=.
#curl https://download.java.net/java/ga/jdk11/openjdk-11_osx-x64_bin.tar.gz \
# | tar -xz \
# && sudo mv jdk-11.jdk /Library/Java/JavaVirtualMachines

# Install Java
#mkdir ./java
#cd /java
#tar -xf /tmp/openjdk-11.0.1_linux-x64_bin.tar.gz
#ln -s ./j* ./latest

JAVA_JDK=openjdk-11.0.2
pushd .
mkdir ./java
cd java
curl -O https://download.java.net/java/GA/jdk11/9/GPL/$JAVA_JDK_linux-x64_bin.tar.gz
tar zxvf JAVA_JDK_linux-x64_bin.tar.gz
popd
export JAVA_HOME=$TARGET_FOLDER/java
export PATH=$JAVA_HOME/bin:$PATH

curl -O https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip | tar xf -
chmod 755 $TARGET_FOLDER/sqlcl/bin/sql

unset ORACLE_HOME

# ${HOME}/sqlcl/bin/sql