FROM registry.fedoraproject.org/fedora-minimal:38 as build

ARG VERSION=0.32.1

WORKDIR /src

RUN microdnf -y --nodocs install hostname make protobuf-devel golang git \
  golang-github-gogo-protobuf systemd-devel which npm
RUN git clone --depth 1 --branch v${VERSION} https://github.com/grafana/agent.git /src
RUN npm install -g yarn && make generate-ui
RUN RELEASE_BUILD=1 VERSION=${VERSION} \
    GO_TAGS="builtinassets promtail_journal_enabled" \
    make agent

FROM registry.fedoraproject.org/fedora-minimal:38

RUN microdnf -y --nodocs install systemd-libs && microdnf clean all && rm -rf /var/lib/dnf /var/cache/*

ENV ASSUME_NO_MOVING_GC_UNSAFE_RISK_IT_WITH=go1.18

COPY --from=build /src/build/grafana-agent /usr/bin/grafana-agent
COPY --from=build /src/cmd/grafana-agent/agent-local-config.yaml /etc/agent/agent.yml

ENTRYPOINT ["/usr/bin/grafana-agent"]

CMD ["--config.file=/etc/agent/agent.yml", "--metrics.wal-directory=/etc/agent/data"]
