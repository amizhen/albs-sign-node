FROM almalinux:8

COPY ./signnode.repo /etc/yum.repos.d/signnode.repo
RUN curl https://packages.codenotary.org/codenotary.repo -o /etc/yum.repos.d/codenotary.repo

RUN dnf install -y epel-release && \
    dnf upgrade -y && \
    dnf install -y --enablerepo="powertools" --enablerepo="epel" --enablerepo="signnode" --enablerepo="codenotary-repo" \
        rpm-sign python3 python3-devel python3-virtualenv git \
        python3-pycurl tree mlocate keyrings-filesystem pinentry \
        ubu-keyring debian-keyring raspbian-keyring cas && \
    dnf clean all

RUN curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o wait_for_it.sh && chmod +x wait_for_it.sh
RUN useradd -ms /bin/bash alt
RUN usermod -aG wheel alt
RUN echo 'alt ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo 'wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


WORKDIR /sign-node

COPY requirements.txt /sign-node/requirements.txt

RUN python3 -m venv --system-site-packages env
RUN cd /sign-node && source /sign-node/env/bin/activate && pip3 install --upgrade pip && pip3 install -r /sign-node/requirements.txt --no-cache-dir

RUN chown -R alt:alt /sign-node /wait_for_it.sh /srv
USER alt

CMD ["/bin/bash", "-c", "source env/bin/activate && pip3 install --upgrade pip && pip3 install -r requirements.txt --no-cache-dir && python3 almalinux_sign_node.py"]
