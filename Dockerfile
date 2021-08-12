FROM golang:1.16-alpine

COPY myserver ./

EXPOSE 8080

CMD [ "/myserver" ]
