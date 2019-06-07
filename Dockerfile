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
RUN apk add --no-cache ca-certificates krb5-libs libgcc libintl libssl1.1 libstdc+lttng-ust tzdata userspace-rcu zlib
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
COPY --from=core-tools-build-env [ "/output", "/azure-functions-core-tools" ]
RUN ln -s /azure-functions-core-tools/func /bin/func

