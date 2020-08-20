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
ARG VERSION_HELM
ENV TERRAFORM_URL="https://releases.hashicorp.com/terraform/${VERSION_TERRAFORM}/terraform_${VERSION_TERRAFORM}_linux_amd64.zip"

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

# Install Helm and install latest unittest plugin
RUN wget https://get.helm.sh/helm-${VERSION_HELM}-linux-amd64.tar.gz \
    && tar -xvf helm-${VERSION_HELM}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64 helm-${VERSION_HELM}-linux-amd64.tar.gz \
    && helm plugin install https://github.com/quintush/helm-unittest \
    && rm -rf /tmp/*

# Install yamllint
RUN pip install yamllint \
    && rm -rf ~/.cache/pip

# Install stern for better tailing kubernetes resources
RUN wget https://github.com/wercker/stern/releases/latest/download/stern_linux_amd64 \
    && chmod +x ./stern_linux_amd64 \
    && mv ./stern_linux_amd64 /usr/local/bin/stern

# Copy gcloud binaries and libraries to image, and add binaries to path
COPY --from=gcloud /google-cloud-sdk /usr/lib/google-cloud-sdk
ENV PATH="/usr/lib/google-cloud-sdk/bin:${PATH}"

# Create a group and user
RUN addgroup -g 1000 dockeruser \
    && adduser -u 1000 -G dockeruser -h /home/clitools -D clitools
USER clitools
