package main

import (
	"log"
	"net/http"

	"github.com/DSdatsme/golang-api-deployment/basicserver"
)

func main() {
	http.HandleFunc("/", basicserver.HelloWorld)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
