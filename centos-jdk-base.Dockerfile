FROM centos:7
LABEL maintainer="Chirag Bhatia <chiragbhatia94@gmail.com>"

# Install packages necessary to run EAP
RUN yum update -y && yum -y install xmlstarlet saxon augeas bsdtar unzip && yum clean all

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
  chmod 755 /opt/jboss

# Specify the user which should be used to execute all commands below
# User root user to install software
USER root

WORKDIR /root

ENV JDK_VERSION jdk-8u152
ENV JDK_SHA1 1a3c0f86fcfdec6156f8256c87fbdcc04caea242
ENV JAVA_INSTALL_HOME /usr/java/jdk1.8.0_152

# Install Java JDK 8
COPY Softwares/${JDK_VERSION}-linux-x64.tar.gz .

# Make sure the distribution is available from a well-known place
RUN sha1sum ${JDK_VERSION}-linux-x64.tar.gz | grep $JDK_SHA1 \
  && mkdir /usr/java \
  && tar xzf ${JDK_VERSION}-linux-x64.tar.gz -C /usr/java \
  && rm ${JDK_VERSION}-linux-x64.tar.gz \
  && update-alternatives --install /usr/bin/java java ${JAVA_INSTALL_HOME%*/}/bin/java 20000 \
  && update-alternatives --install /usr/bin/javac javac ${JAVA_INSTALL_HOME%*/}/bin/javac 20000 \
  && yum clean all

# Change root password to empty
RUN echo "toor" | passwd --stdin root 

# Switch back to jboss user
USER jboss

WORKDIR /opt/jboss
