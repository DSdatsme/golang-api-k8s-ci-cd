FROM golang:1.16-alpine

WORKDIR /app

COPY basicserver /app/basicserver

COPY go.mod /app

COPY main.go /app

RUN go build -o myserver

EXPOSE 8080

CMD [ "/app/myserver" ]

# ENTRYPOINT ["/bin/ash", "-c", "sleep infinity"]
