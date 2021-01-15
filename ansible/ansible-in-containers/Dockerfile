FROM centos:centos7.7.1908

ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_RETRY_FILES_ENABLED false

RUN yum check-update; \
  yum install -y gcc libffi-devel python3 epel-release; \
  yum install -y openssh-clients; \
  yum install -y sshpass; \
  pip3 install --upgrade pip; \
  pip3 install ansible

#ENTRYPOINT ["ansible-playbook","playbook.yml"]

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash","/entrypoint.sh"]