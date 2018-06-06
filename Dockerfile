FROM ubuntu:bionic-20180526

# Set one or more individual labels
ARG VERSION=latest
ARG DATE=2018-06-06

LABEL \
      vendor="Heroku.com Minimal Ubuntu 18.04 Bionic Minimal Image - 20180526" \
      com.heroku.version=${VERSION} \ 
      com.heroku.release-date=${DATE}

RUN mkdir -p /var/run/sshd /app /ssh /data
RUN chmod -R g-w,o-w /ssh
RUN chmod -R a+rwx /app /data

COPY ./app /app
COPY ./ssh /ssh

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    	    bash \
	    openssh-server \
	    openssh-sftp-server \
	    autossh \
	    s3cmd && \
	    	  rm -rf /var/lib/apt/lists/*

CMD ["/app/start.sh"]
