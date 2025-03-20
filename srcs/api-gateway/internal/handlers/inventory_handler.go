package handlers

import (
	"net/http"
	"net/http/httputil"
	"net/url"
)

// NewInventoryHandler creates a reverse proxy for the Inventory API
func NewInventoryHandler(target string) http.Handler {
	targetURL, _ := url.Parse(target)
	proxy := httputil.NewSingleHostReverseProxy(targetURL)

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		proxy.ServeHTTP(w, r)
	})
}
