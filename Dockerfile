FROM registry.fedoraproject.org/fedora-minimal:39

ARG VERSION=0.39.1

RUN microdnf -y --nodocs install shadow-utils && \
    case "$(arch)" in \
       aarch64|arm64|arm64e) \
         ARCHITECTURE='arm64'; \
         ;; \
       x86_64|amd64|i386) \
         ARCHITECTURE='amd64'; \
         ;; \
       *) \
         echo "Unsupported architecture"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/gpg.key https://rpm.grafana.com/gpg.key && \
    rpm --import /tmp/gpg.key && \
    curl -LfsSo /tmp/grafana-agent.rpm https://github.com/grafana/agent/releases/download/v${VERSION}/grafana-agent-${VERSION}-1.${ARCHITECTURE}.rpm && \
    rpm -i /tmp/grafana-agent.rpm && \
    microdnf -y remove shadow-utils && \
    microdnf clean all && \
    rm -rf /var/lib/dnf /var/cache/* /tmp/grafana-agent.rpm /tmp/gpg.key

ENTRYPOINT ["/usr/bin/grafana-agent"]

CMD ["--config.file=/etc/grafana-agent.yaml"]
