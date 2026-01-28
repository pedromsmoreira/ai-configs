---
name: rest-api-design
description: Designs REST and HTTP endpoints for this project—URL structure, HTTP methods, status codes, request/response patterns, error handling, and versioning. Use when creating or modifying REST APIs, HTTP handlers, routing, or API contracts.
version: 1.0
---

# REST API Design Skill

## When to use

- Designing or modifying REST API endpoints, URL structures, or routing
- Implementing HTTP handlers for REST endpoints (gorilla/mux router, REST Gateway, or direct HTTP)
- Defining request/response formats, status codes, and error responses
- Planning API versioning strategies or backward compatibility
- Creating API documentation or OpenAPI/Swagger specs
- Integrating REST endpoints with frontend clients

For **backend implementation** (Go handlers, services, domain logic), use the `go-backend` skill. For **testing** REST endpoints, use the `testing` skill.

**Note**: Examples in this skill are **implementation-agnostic**. They focus on HTTP/REST patterns, routing, and request/response handling. Replace placeholder functions (e.g., `createResource()`, `getResource()`) and types (e.g., `Resource`, `CreateRequest`) with your actual implementation.

## Library Usage

- **Use gorilla/mux** for routing (only external library allowed)
- **Use standard library** for all other functionality:
  - `net/http` for HTTP handling
  - `encoding/json` for JSON encoding/decoding
  - `strconv` for string conversions
  - `context` for context handling
- **Avoid** other external libraries unless absolutely necessary

## REST Design Principles

### Resource-Based URLs

- Use nouns, not verbs: `/users`, `/entities`, `/users/{id}/resources`
- Use plural nouns for collections: `/users` not `/user`
- Use hierarchical paths for relationships: `/users/{userId}/entities/{entityId}`
- Keep URLs simple and intuitive

```go
// ✅ GOOD: Resource-based URLs
GET    /api/v1/users
GET    /api/v1/users/{id}
POST   /api/v1/users
PUT    /api/v1/users/{id}
DELETE /api/v1/users/{id}
GET    /api/v1/users/{id}/entities

// ❌ BAD: Verb-based or inconsistent
GET    /api/v1/getUser/{id}
POST   /api/v1/createUser
GET    /api/v1/user/{id}/getEntities
```

### HTTP Methods

- **GET**: Retrieve resources (idempotent, safe)
- **POST**: Create resources or perform actions
- **PUT**: Replace entire resource (idempotent)
- **PATCH**: Partial update using JSON Merge Patch (RFC 7386) (idempotent when possible)
- **DELETE**: Remove resources (idempotent)

```go
// ✅ GOOD: Proper HTTP method usage
POST   /api/v1/users              // Create user
GET    /api/v1/users/{id}         // Get user
PUT    /api/v1/users/{id}         // Replace user
PATCH  /api/v1/users/{id}         // Partial update (JSON Merge Patch)
DELETE /api/v1/users/{id}         // Delete user

// ❌ BAD: Using POST for everything
POST   /api/v1/users/{id}/get     // Should be GET
POST   /api/v1/users/{id}/delete  // Should be DELETE
```

### Status Codes

- **2xx Success**: 200 (OK), 201 (Created), 204 (No Content)
- **4xx Client Error**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 409 (Conflict)
- **5xx Server Error**: 500 (Internal Server Error), 502 (Bad Gateway), 503 (Service Unavailable)

```go
// ✅ GOOD: Appropriate status codes
func CreateResource() func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        var req CreateRequest
        if err := serializer.Decode(w, r, &req); err != nil {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestError("could not decode request body", nil), serializer) // 400
            return
        }
        
        // Call service/business logic (implementation-specific)
        resource, err := createResource(r.Context(), req)
        if err != nil {
            if isConflictError(err) {
                respond(w, r, http.StatusConflict, 
                    NewConflictError("resource already exists"), serializer) // 409
                return
            }
            if isValidationError(err) {
                respond(w, r, http.StatusBadRequest, 
                    NewBadRequestErrorWithoutDetails("invalid input"), serializer) // 400
                return
            }
            respond(w, r, http.StatusInternalServerError, 
                NewInternalServerError("an error occurred"), serializer) // 500
            return
        }
        
        respond(w, r, http.StatusCreated, resource, serializer) // 201
    }
}
```

### JSON Merge Patch (RFC 7386)

**Preferred format for PATCH operations**. JSON Merge Patch describes changes to a target JSON document by example. Use `Content-Type: application/merge-patch+json` for PATCH requests.

**Key principles:**
- Fields present in patch are merged/replaced
- Fields set to `null` are removed from target
- Nested objects are merged recursively
- Arrays are replaced entirely (not merged)

```go
// ✅ GOOD: JSON Merge Patch for PATCH
// Original resource:
// {
//   "title": "Goodbye!",
//   "author": {
//     "givenName": "John",
//     "familyName": "Doe"
//   },
//   "tags": ["example", "sample"],
//   "content": "This will be unchanged"
// }

// PATCH /api/v1/users/{id}
// Content-Type: application/merge-patch+json
// {
//   "title": "Hello!",
//   "phoneNumber": "+01-123-456-7890",
//   "author": {
//     "familyName": null  // Removes familyName
//   },
//   "tags": ["example"]   // Replaces entire array
// }

// Result:
// {
//   "title": "Hello!",
//   "author": {
//     "givenName": "John"
//   },
//   "tags": ["example"],
//   "content": "This will be unchanged",
//   "phoneNumber": "+01-123-456-7890"
// }

import (
    "context"
    "encoding/json"
    "net/http"
    
    "github.com/gorilla/mux"
)

func PatchResource() func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        // Validate Content-Type (standard library)
        contentType := r.Header.Get("Content-Type")
        if contentType != "application/merge-patch+json" {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestErrorWithoutDetails("Content-Type must be application/merge-patch+json"), 
                serializer)
            return
        }
        
        // Extract path variable (gorilla/mux)
        vars := mux.Vars(r)
        resourceID := vars["id"]
        
        // Decode patch (standard library)
        var patch map[string]interface{}
        if err := serializer.Decode(w, r, &patch); err != nil {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestError("could not decode request body", nil), serializer)
            return
        }
        
        // Apply merge patch and update resource (implementation-specific)
        resource, err := updateResource(r.Context(), resourceID, patch)
        if err != nil {
            respond(w, r, http.StatusInternalServerError, 
                NewInternalServerError("an error occurred updating the resource"), serializer)
            return
        }
        
        respond(w, r, http.StatusOK, resource, serializer)
    }
}
```

**Implementation notes:**
- Validate Content-Type header is `application/merge-patch+json` (use `r.Header.Get()`)
- Decode patch using `json.NewDecoder(r.Body)` (standard library)
- Apply merge patch logic using standard library: merge objects recursively, replace arrays/primitives, remove null fields
- Extract path variables using `mux.Vars(r)` (gorilla/mux)
- Return updated resource in response (200 OK)
- Handle validation errors appropriately (400 Bad Request)

**JSON Merge Patch implementation** (using standard library only):
- Recursively merge objects: if patch field is object and target has same field as object, merge recursively
- Replace primitives and arrays: if patch field is primitive/array, replace target field entirely
- Remove fields: if patch field is `null`, remove from target

### Handler Pattern

- Use **higher-order functions** that return `func(w http.ResponseWriter, r *http.Request)`
- Handlers are functions, not methods on a struct
- Pass dependencies (repository, service, config) as function parameters if needed (implementation-specific)
- Use serializer interface for encoding/decoding

```go
import (
    "context"
    "encoding/json"
    "net/http"
)

// ✅ GOOD: Handler function pattern
func Create() func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        var body CreateRequest
        if err := serializer.Decode(w, r, &body); err != nil {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestError("could not decode request body", nil), serializer)
            return
        }
        
        // Validation (implementation-specific)
        if err := validateCreateRequest(body); err != nil {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestErrorWithoutDetails(err.Error()), serializer)
            return
        }
        
        // Business logic (implementation-specific)
        resource, err := createResource(r.Context(), body)
        if err != nil {
            respond(w, r, http.StatusConflict, NewConflictError(err.Error()), serializer)
            return
        }
        
        // Response
        response := &CreateResponse{
            Resource: resource,
        }
        respond(w, r, http.StatusCreated, response, serializer)
    }
}
```

### Serializer Pattern

- Use interface for serialization to support multiple formats (JSON, XML, etc.)
- Implement JSON serializer using standard library `encoding/json`
- Set Content-Type via serializer

```go
type serializer interface {
    Encode(w http.ResponseWriter, r *http.Request, v interface{}) error
    ContentType(w http.ResponseWriter, r *http.Request) string
    Decode(w http.ResponseWriter, r *http.Request, v interface{}) error
}

type jsonSerializer struct{}

var JSON serializer = (*jsonSerializer)(nil)

func (j *jsonSerializer) Encode(w http.ResponseWriter, r *http.Request, v interface{}) error {
    return json.NewEncoder(w).Encode(v)
}

func (j *jsonSerializer) ContentType(w http.ResponseWriter, r *http.Request) string {
    return "application/json; charset=utf-8"
}

func (j *jsonSerializer) Decode(w http.ResponseWriter, r *http.Request, v interface{}) error {
    return json.NewDecoder(r.Body).Decode(v)
}
```

### Response Helper

- Use `respond()` helper function with serializer
- Set Content-Type header via serializer
- Handle nil data gracefully

```go
func respond(w http.ResponseWriter, r *http.Request, status int, data interface{}, encoder serializer) {
    w.Header().Set("Content-Type", encoder.ContentType(w, r))
    w.WriteHeader(status)
    if data == nil {
        return
    }
    
    if err := encoder.Encode(w, r, data); err != nil {
        // Log encoding error (server-side only)
    }
}
```

### Request/Response Format

- Use JSON for request/response bodies
- Set `Content-Type: application/json; charset=utf-8` via serializer
- Include consistent response structure
- Return created/updated resources in response body
- Use standard library `encoding/json` (no external libraries)

```go
// ✅ GOOD: Response structures (implementation-specific types)
type CreateResponse struct {
    Resource Resource `json:"resource"` // Replace Resource with your domain type
}

type ListResponse struct {
    Data []Resource `json:"data"` // Replace Resource with your domain type
    Next string     `json:"next_link,omitempty"`
}
```

### Error Handling

- Define custom error types with error codes
- Provide consistent error response format
- Never expose internal errors to clients
- Include error codes for programmatic handling
- Use error types that implement `error` interface

```go
// ✅ GOOD: Custom error types with codes
type BadRequestError struct {
    Code    string      `json:"code,omitempty"`
    Message string      `json:"message,omitempty"`
    Details interface{} `json:"details,omitempty"`
}

func NewBadRequestError(message string, details interface{}) error {
    return &BadRequestError{
        Code:    "100002",
        Message: message,
        Details: details,
    }
}

func NewBadRequestErrorWithoutDetails(message string) error {
    return &BadRequestError{
        Code:    "100003",
        Message: message,
    }
}

func (bde *BadRequestError) Error() string {
    return "error_code: " + bde.Code + " message: " + bde.Message
}

type ConflictError struct {
    Code    string `json:"code,omitempty"`
    Message string `json:"message,omitempty"`
}

func NewConflictError(message string) error {
    return &ConflictError{
        Code:    "100004",
        Message: message,
    }
}

func (ce *ConflictError) Error() string {
    return "error_code: " + ce.Code + " message: " + ce.Message
}

type NotFoundError struct {
    Code    string `json:"code,omitempty"`
    Message string `json:"message,omitempty"`
}

func NewNotFoundError(id string) error {
    return &NotFoundError{
        Code:    "100005",
        Message: "path: " + id + " not found",
    }
}

func (nfe *NotFoundError) Error() string {
    return "error_code: " + nfe.Code + " message: " + nfe.Message
}

// Usage in handler
func GetResource() func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        vars := mux.Vars(r)
        id := vars["id"]
        
        // Get resource (implementation-specific)
        resource, err := getResource(r.Context(), id)
        if err != nil {
            respond(w, r, http.StatusNotFound, NewNotFoundError(id), serializer)
            return
        }
        
        respond(w, r, http.StatusOK, resource, serializer)
    }
}
```

### Routing with gorilla/mux

- Use gorilla/mux for routing (only external library allowed)
- Define routes with path variables using `{name}` syntax
- Use `mux.Vars(r)` to extract path variables
- Group routes by version or resource

```go
import (
    "github.com/gorilla/mux"
    "net/http"
)

// ✅ GOOD: Router setup with gorilla/mux
func NewRouter() *mux.Router {
    router := mux.NewRouter()
    
    // Apply middleware (implementation-specific)
    router.Use(middleware.LoggedHandler)
    
    // Register routes with handler functions
    router.HandleFunc("/resources", List()).Methods("GET")
    router.HandleFunc("/resources", Create()).Methods("POST")
    router.HandleFunc("/resources/{id}", GetResource()).Methods("GET")
    router.HandleFunc("/resources/{id}", UpdateResource()).Methods("PUT")
    router.HandleFunc("/resources/{id}", PatchResource()).Methods("PATCH")
    router.HandleFunc("/resources/{id}", DeleteResource()).Methods("DELETE")
    
    return router
}

// ✅ GOOD: Extract path variables using mux.Vars
func DeleteResource() func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        vars := mux.Vars(r)
        id := vars["id"]
        
        // Check if resource exists (implementation-specific)
        exists, err := resourceExists(r.Context(), id)
        if err != nil || !exists {
            respond(w, r, http.StatusNotFound, NewNotFoundError(r.URL.Path), serializer)
            return
        }
        
        // Delete resource (implementation-specific)
        err = deleteResource(r.Context(), id)
        if err != nil {
            // Log error server-side
        }
        
        respond(w, r, http.StatusNoContent, nil, serializer)
    }
}
```

### API Versioning

- Version at URL path: `/api/v1/`, `/api/v2/`
- Use gorilla/mux subrouters for version grouping
- Include version in all endpoints
- Maintain backward compatibility when possible
- Document breaking changes

```go
// ✅ GOOD: URL versioning with gorilla/mux
func NewRouter() *mux.Router {
    router := mux.NewRouter()
    
    router.Use(middleware.LoggedHandler)
    
    // API v1 routes
    v1 := router.PathPrefix("/api/v1").Subrouter()
    v1.HandleFunc("/resources", List()).Methods("GET")
    v1.HandleFunc("/resources", Create()).Methods("POST")
    v1.HandleFunc("/resources/{id}", GetResource()).Methods("GET")
    
    // API v2 routes
    v2 := router.PathPrefix("/api/v2").Subrouter()
    v2.HandleFunc("/resources", ListV2()).Methods("GET") // New version
    
    return router
}
```

### Query Parameters

- Use for filtering, pagination, sorting
- Keep parameter names consistent
- Document required vs optional parameters
- Use standard library `r.URL.Query().Get()` and `r.URL.Query().Has()`
- Validate and convert types with `strconv` (standard library)

```go
import (
    "context"
    "fmt"
    "net/http"
    "strconv"
)

const (
    defaultPageNumber = "0"
    defaultPageSize   = "10"
)

// ✅ GOOD: Query parameters for filtering
GET /api/v1/users?page=0&size=20
GET /api/v1/entities?owner_id=123&status=active

// Handler example
func List() func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        qPage := defaultPageNumber
        qSize := defaultPageSize
        
        if r.URL.Query().Has("page") {
            qPage = r.URL.Query().Get("page")
        }
        if r.URL.Query().Has("size") {
            qSize = r.URL.Query().Get("size")
        }
        
        p, err := strconv.Atoi(qPage)
        if err != nil {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestErrorWithoutDetails(fmt.Sprintf("[page] was %v. Must be an integer.", qPage)), 
                serializer)
            return
        }
        
        s, err := strconv.Atoi(qSize)
        if err != nil {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestErrorWithoutDetails(fmt.Sprintf("[size] was %v. Must be an integer.", qSize)), 
                serializer)
            return
        }
        
        // List resources (implementation-specific)
        resources, err := listResources(r.Context(), p, s)
        if err != nil {
            respond(w, r, http.StatusInternalServerError, 
                NewInternalServerError("an error occurred in the server"), serializer)
            return
        }
        
        response := &ListResponse{
            Data: resources,
        }
        
        if len(resources) > 0 {
            baseURL := getBaseURL(r) // Implementation-specific: extract base URL
            response.Next = fmt.Sprintf("%s/resources?page=%d&size=%d", baseURL, p+1, s)
        }
        
        respond(w, r, http.StatusOK, response, serializer)
    }
}
```

### Pagination

- Use `page` and `limit` or `offset` and `limit`
- Include pagination metadata in response
- Provide links for next/previous pages when applicable

```go
// ✅ GOOD: Pagination response (generic type)
type PaginatedResponse[T any] struct {
    Data     []T   `json:"data"`     // Replace T with your domain type
    Page     int   `json:"page"`
    Limit    int   `json:"limit"`
    Total    int   `json:"total"`
    HasMore  bool  `json:"has_more"`
}
```

### Authentication

- Use `Authorization: Bearer <token>` header
- Extract Principal from context (see authentication rules)
- Return 401 for missing/invalid tokens
- Return 403 for authorized but forbidden actions
- Use middleware for authentication (see middleware section)

```go
// ✅ GOOD: Authentication in handler
func CreateResource() func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        // Extract principal from context (implementation-specific)
        principal := getPrincipal(r.Context())
        if principal == nil {
            respond(w, r, http.StatusUnauthorized, 
                NewUnauthorizedError("missing or invalid token"), serializer)
            return
        }
        
        var body CreateRequest
        if err := serializer.Decode(w, r, &body); err != nil {
            respond(w, r, http.StatusBadRequest, 
                NewBadRequestError("could not decode request body", nil), serializer)
            return
        }
        
        // Use principal for authorization/ownership (implementation-specific)
        resource, err := createResource(r.Context(), principal, body)
        if err != nil {
            respond(w, r, http.StatusConflict, NewConflictError(err.Error()), serializer)
            return
        }
        
        respond(w, r, http.StatusCreated, resource, serializer)
    }
}
```

### Middleware

- Use gorilla/mux middleware for cross-cutting concerns
- Apply middleware with `router.Use()`
- Common middleware: logging, authentication, CORS, request ID

```go
// ✅ GOOD: Middleware usage
func NewRouter() *mux.Router {
    router := mux.NewRouter()
    
    // Apply middleware in order (implementation-specific)
    router.Use(middleware.LoggedHandler)
    router.Use(middleware.AuthHandler)
    router.Use(middleware.RequestIDHandler)
    
    // Register routes
    router.HandleFunc("/resources", List()).Methods("GET")
    
    return router
}
```

## REST vs gRPC Considerations

- **REST**: Use for public APIs, web frontend integration, simple CRUD
- **gRPC**: Use for internal services, high-performance, streaming
- **REST Gateway**: Generated from gRPC proto annotations (see project context)
- When using REST Gateway, design proto messages with REST in mind

## References

| File | Purpose |
|------|---------|
| [RFC 7386 - JSON Merge Patch](https://datatracker.ietf.org/doc/html/rfc7386) | JSON Merge Patch specification for PATCH operations |
| [shrtner repository](https://github.com/pedromsmoreira/shrtner) | Reference implementation showing handler patterns, serializer interface, error types, and routing with gorilla/mux |
| [.cursor/rules/00-project-context.mdc](.cursor/rules/00-project-context.mdc) | Project overview, API ports, tech stack (gorilla/mux router, REST Gateway) |
| [.cursor/rules/01-architecture.mdc](.cursor/rules/01-architecture.mdc) | Handler layer responsibilities, error handling, protocol transformation |
| [.cursor/rules/02-go-style-guide.mdc](.cursor/rules/02-go-style-guide.mdc) | Handler implementation patterns, context usage, error handling |
| [.cursor/rules/05-authentication-security.mdc](.cursor/rules/05-authentication-security.mdc) | JWT authentication, Principal pattern, authorization, public endpoints |
| [.cursor/rules/07-agent-behavior.mdc](.cursor/rules/07-agent-behavior.mdc) | Adding new API endpoints workflow, error handling, backward compatibility |
