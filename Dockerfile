# Utiliser une image Alpine Linux comme base
FROM alpine:latest

# Installer OpenJDK 8 et autres dépendances + musl-locales pour le support des locales
RUN apk update && apk add --no-cache \
    openjdk8-jre \
    wget \
    unzip \
    tzdata

# Définir JAVA_HOME pour OpenJDK 8
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $JAVA_HOME/bin:$PATH

# Configuration locale et NLS Oracle pour éviter ORA-01843 (même config que Oracle)
ENV LANG=fr_FR.UTF-8
ENV LC_ALL=fr_FR.UTF-8
ENV NLS_LANG=FRENCH_FRANCE.AL32UTF8
ENV NLS_DATE_FORMAT="DD/MM/YYYY"
ENV NLS_TIMESTAMP_FORMAT="DD/MM/YYYY HH24:MI:SS"
ENV TZ=Indian/Antananarivo

# Télécharger et installer WildFly
RUN wget https://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip \
    && unzip wildfly-10.1.0.Final.zip -d /opt/ \
    && mv /opt/wildfly-10.1.0.Final /opt/wildfly \
    && rm wildfly-10.1.0.Final.zip

# Définir WILDFLY_HOME
ENV WILDFLY_HOME /opt/wildfly

# Copier votre application WAR dans le dossier de déploiement de WildFly
COPY ./deployments/kolotv.war $WILDFLY_HOME/standalone/deployments/kolotv.war

RUN touch $WILDFLY_HOME/standalone/deployments/kolotv.war.dodeploy

# Exposer les ports nécessaires
EXPOSE 8070 9990

# Démarrer WildFly
CMD ["/opt/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
