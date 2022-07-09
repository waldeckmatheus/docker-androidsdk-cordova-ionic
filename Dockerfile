FROM ubuntu:21.10

LABEL image-name="androidsdk-cordova-ionic"

ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && apt-get update -yqq && apt-get install -y \
  curl \
  expect \
  git \
  make \
  libc6:i386 \
  libgcc1:i386 \
  libncurses5:i386 \
  libstdc++6:i386 \
  zlib1g:i386 \
  wget \
  unzip \
  vim \
  openssh-client \
  locales \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.UTF-8

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android -u 1000 android

#echo 'Installing JDK 11...'
RUN java -version || apt update -y && apt install openjdk-11-jdk -y

#echo 'Checking and installing nvm...'
RUN export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

#echo 'Installing gradle and exporting gradle bin to path...'
RUN [ -d /opt/gradle/gradle-7.1.1/ ] && export PATH=$PATH:/opt/gradle/gradle-7.1.1/bin && gradle -v || \ 
 rm -f /tmp/gradle-7.1.1-bin.zip && \
 wget https://downloads.gradle-dn.com/distributions/gradle-7.1.1-bin.zip -P /tmp/ && \
 mkdir -p /opt/gradle/ && \
 unzip /tmp/gradle-7.1.1-bin.zip -d /opt/gradle/ && \
 export PATH=$PATH:/opt/gradle/gradle-7.1.1/bin && \
 gradle -v

#echo 'Installing node 18.5.0, ionic/cli and cordova...'
RUN NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \ 
 nvm install 18.5.0 && npm install -g @ionic/cli && npm i -g cordova

COPY tools /opt/tools

COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

CMD /opt/tools/entrypoint.sh built-in

