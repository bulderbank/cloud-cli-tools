# Base images must be defined in to to be used with FROM
ARG VERSION_GCLOUD
ARG VERSION_ALPINE

# google/gcloud image that we will copy binaries from
FROM $VERSION_GCLOUD AS gcloud
ENV CLOUDSDK_CORE_DISABLE_PROMPTS=1
RUN gcloud components install beta bq gsutil

FROM $VERSION_ALPINE

ARG VERSION_KUBECTL
ARG VERSION_TERRAFORM
ARG VERSION_TERRAGRUNT
ARG VERSION_HELM
ARG VERSION_CIRCLECICLI
ENV TERRAFORM_URL="https://releases.hashicorp.com/terraform/${VERSION_TERRAFORM}/terraform_${VERSION_TERRAFORM}_linux_amd64.zip"
ENV TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION_TERRAGRUNT}/terragrunt_linux_amd64"

# Install utility command-line tools
RUN apk add --update --no-cache curl bash git vim nano python3 py3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${VERSION_KUBECTL}/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Install Terraform
RUN echo ${TERRAFORM_URL}
RUN wget -O /tmp/terraform.zip ${TERRAFORM_URL}  \
    && unzip /tmp/terraform.zip -d /bin \
    && rm -rf /tmp/terraform.zip /var/cache/apk/*

# Install Terragrunt
RUN echo ${TERRAFORM_URL}
RUN wget -O /usr/local/bin/terragrunt ${TERRAGRUNT_URL} && \
    chmod +x /usr/local/bin/terragrunt

# Install Helm
RUN wget https://get.helm.sh/helm-${VERSION_HELM}-linux-amd64.tar.gz \
    && tar -xvf helm-${VERSION_HELM}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64 helm-${VERSION_HELM}-linux-amd64.tar.gz

# Install yamllint
RUN pip install yamllint \
    && rm -rf ~/.cache/pip

# Install stern for better tailing kubernetes resources
RUN wget https://github.com/wercker/stern/releases/latest/download/stern_linux_amd64 \
    && chmod +x ./stern_linux_amd64 \
    && mv ./stern_linux_amd64 /usr/local/bin/stern

# Install circleci cli tool for creating and testing orbs
RUN wget https://github.com/CircleCI-Public/circleci-cli/releases/download/v${VERSION_CIRCLECICLI}/circleci-cli_${VERSION_CIRCLECICLI}_linux_amd64.tar.gz \
    && tar -xvf circleci-cli_${VERSION_CIRCLECICLI}_linux_amd64.tar.gz \
    && mv ./circleci-cli_${VERSION_CIRCLECICLI}_linux_amd64/circleci /usr/local/bin/circleci \
    && rm -rf ./circleci-cli_${VERSION_CIRCLECICLI}_linux_amd64

# Copy gcloud binaries and libraries to image, and add binaries to path
COPY --from=gcloud /google-cloud-sdk /usr/lib/google-cloud-sdk
ENV PATH="/usr/lib/google-cloud-sdk/bin:${PATH}"

# Create a group and user
RUN addgroup -g 1000 docker \
    && adduser -u 1000 -G docker -h /home/clitools -D docker

# Dirty hacks for dynamically changing UID on runtime
RUN USER=docker \
    && GROUP=docker \
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

# Set the default user to run commands, everything RUN after this line will be as normal user!
USER docker:docker

# Install Krew kubectl plugin manager
RUN cd $HOME && mkdir tmp-krew && cd ./tmp-krew \
    && wget https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz \
    && tar zxvf krew.tar.gz \
    && ./krew-linux_amd64 install krew \
    && cd ../ && rm -rf tmp-krew
ENV PATH="/home/clitools/.krew/bin:${PATH}"

# Install latest unittest Helm plugin as user
RUN helm plugin install https://github.com/quintush/helm-unittest \
    && rm -rf /tmp/*

# Install kubectl plugins with Krew
RUN kubectl krew update \
    && kubectl krew install cert-manager \
    && kubectl krew install deprecations \
    && kubectl krew install neat \
    && kubectl krew install np-viewer \
    && kubectl krew install popeye \
    && kubectl krew install prompt \
    && kubectl krew install resource-capacity \
    && kubectl krew install rolesum \
    && kubectl krew install score \
    && kubectl krew install tree

ENTRYPOINT ["fixuid", "-q"]
