package main

import (
	"net/http"
	"github.com/DSdatsme/golang-api-deployment/basicserver"
)


func main() {
	http.HandleFunc("/", basicserver.HelloWorld)
	http.ListenAndServe(":8080", nil)
}
