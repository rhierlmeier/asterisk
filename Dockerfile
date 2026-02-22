FROM ubuntu:24.04

RUN apt-get update && apt-get install -y asterisk && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY asterisk/*.conf /etc/asterisk/
COPY asterisk/*.template /etc/asterisk/
COPY asterisk/sounds/*.ulaw /opt/asterisk/sounds/
COPY create_stoerung.sh /app/
COPY entrypoint.sh /app/

RUN chown -R asterisk:asterisk /opt/asterisk /etc/asterisk/extensions.conf /etc/asterisk/pjsip.conf \
    && chmod +x /app/create_stoerung.sh \
    && chmod +x /app/entrypoint.sh \
    && rm /etc/asterisk/pjsip.conf /etc/asterisk/indications.conf /etc/asterisk/phoneprov.conf



ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["asterisk", "-fp"]
