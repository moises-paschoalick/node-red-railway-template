# Node-RED com proteção por senha — pronto para Railway
#   docker build -t node-red .

FROM nodered/node-red:latest

USER root

# /data-template fica FORA do ponto de montagem do volume.
# init.sh sincroniza settings/node_modules para /data a cada start.
COPY data /data-template
RUN chown -R node-red:node-red /data-template && chmod -R 755 /data-template

# Pré-instala as dependências do template (bcrypt para o script de senha)
USER node-red
RUN cd /data-template && npm install --no-cache --unsafe-perm --no-update-notifier --no-fund --omit=dev

# Semente de /data para deploys sem volume
USER root
RUN cp -r /data-template/. /data/ && chown -R node-red:node-red /data

# Scripts fora de /data para o volume não apagá-los
COPY scripts/user-provision.js /usr/local/bin/user-provision.js
COPY scripts/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

ENV NODE_RED_ENABLE_SAFE_MODE=false \
    NODE_RED_ENABLE_PROJECTS=false

EXPOSE 1880

# Roda como root para o init.sh corrigir permissões do volume antes de trocar para node-red
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD []
