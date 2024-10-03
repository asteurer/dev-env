package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
)

func echoHandler(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Error reading request body", http.StatusInternalServerError)
		return
	}

	// Write method
	fmt.Fprintf(w, "Method: %s\n", r.Method)

	// Write headers
	fmt.Fprintf(w, "Headers:\n")
	for name, values := range r.Header {
		for _, value := range values {
			fmt.Fprintf(w, "%s: %s\n", name, value)
		}
	}

	// Write body
	fmt.Fprintf(w, "Body:\n%s", body)
}

func main() {
	http.HandleFunc("/", echoHandler)
	log.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("ListenAndServe: %v", err)
	}
}
