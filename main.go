package basicserver

import (
	"fmt"
	"net/http"
)

func HelloWorld(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello DSdatsme!")
}

func api() {
	http.HandleFunc("/", HelloWorld)
	http.ListenAndServe(":8080", nil)
}
