FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS core-tools-build-env

RUN wget https://github.com/Azure/azure-functions-core-tools/archive/master.tar.gz && \
    tar -xzvf master.tar.gz
RUN cd azure-functions-core-tools-* && \
    dotnet publish src/Azure.Functions.Cli/Azure.Functions.Cli.csproj --runtime linux-musl-x64 --output /output

FROM docker:latest

RUN apk update && apk add bash

# Install Azure CLI
RUN apk update && apk upgrade && apk add make py-pip
RUN apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python2-dev
RUN pip install azure-cli && apk del --purge build

# .NET Core dependencies
RUN apk add --no-cache \
        ca-certificates \
        \
        # .NET Core dependencies
        krb5-libs \
        libgcc \
        libintl \
        libssl1.1 \
        libstdc++ \
        lttng-ust \
        tzdata \
        userspace-rcu \
        zlib
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

# Install .NET Core
ENV DOTNET_VERSION 2.2.5
RUN wget -O dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='f4cab0135f69f3819a905640e59718f292fecef849480da16043e6cbbff72d80edbc64fbc3bf84bf6151148d9982dec67038020deba1e9ca4a1c61a35bcaea56' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz

COPY --from=core-tools-build-env [ "/output", "/azure-functions-core-tools" ]
RUN ln -s /azure-functions-core-tools/func /bin/func

