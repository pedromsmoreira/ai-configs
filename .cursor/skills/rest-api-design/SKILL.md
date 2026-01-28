---
name: rest-api-design
description: Designs REST and HTTP endpoints for this project—URL structure, HTTP methods, status codes, request/response patterns, error handling, and versioning. Use when creating or modifying REST APIs, HTTP handlers, routing, or API contracts.
version: 1.0
---

# REST API Design Skill

## When to use

- Designing or modifying REST API endpoints, URL structures, or routing
- Defining request/response formats, status codes, and error responses
- Planning API versioning strategies or backward compatibility
- Creating API documentation or OpenAPI/Swagger specs
- Understanding general REST principles and patterns

For **project-specific implementation** (shrtner handlers, router configuration, error types), see `.cursor/rules/12-http-rest-standards.mdc`. For **backend implementation** (Go handlers, services, domain logic), use the `go-backend` skill. For **testing** REST endpoints, use the `testing` skill.

**Note**: This skill provides **general REST design principles** that apply across projects. For shrtner-specific patterns (handler structure, error types, router setup), refer to the rule file above.

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
    return func(w http.ResponseWriter, r *http.Request) {
        var req CreateRequest
        if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
            // 400 Bad Request - malformed request
            w.WriteHeader(http.StatusBadRequest)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "400",
                Message: "could not decode request body",
            })
            return
        }
        
        // Call service/business logic (implementation-specific)
        resource, err := createResource(r.Context(), req)
        if err != nil {
            if isConflictError(err) {
                // 409 Conflict - duplicate resource
                w.WriteHeader(http.StatusConflict)
                json.NewEncoder(w).Encode(ErrorResponse{
                    Code:    "409",
                    Message: "resource already exists",
                })
                return
            }
            if isValidationError(err) {
                // 400 Bad Request - validation error
                w.WriteHeader(http.StatusBadRequest)
                json.NewEncoder(w).Encode(ErrorResponse{
                    Code:    "400",
                    Message: "invalid input",
                })
                return
            }
            // 500 Internal Server Error - unexpected error
            w.WriteHeader(http.StatusInternalServerError)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "500",
                Message: "an error occurred",
            })
            return
        }
        
        // 201 Created - successful creation
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusCreated)
        json.NewEncoder(w).Encode(resource)
    }
}
```

**Note**: For shrtner-specific error handling patterns (`respond()` function, custom error types), see `.cursor/rules/12-http-rest-standards.mdc`.

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
    return func(w http.ResponseWriter, r *http.Request) {
        // Validate Content-Type (standard library)
        contentType := r.Header.Get("Content-Type")
        if contentType != "application/merge-patch+json" {
            w.WriteHeader(http.StatusBadRequest)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "400",
                Message: "Content-Type must be application/merge-patch+json",
            })
            return
        }
        
        // Extract path variable (gorilla/mux)
        vars := mux.Vars(r)
        resourceID := vars["id"]
        
        // Decode patch (standard library)
        var patch map[string]interface{}
        if err := json.NewDecoder(r.Body).Decode(&patch); err != nil {
            w.WriteHeader(http.StatusBadRequest)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "400",
                Message: "could not decode request body",
            })
            return
        }
        
        // Apply merge patch and update resource (implementation-specific)
        resource, err := updateResource(r.Context(), resourceID, patch)
        if err != nil {
            w.WriteHeader(http.StatusInternalServerError)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "500",
                Message: "an error occurred updating the resource",
            })
            return
        }
        
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusOK)
        json.NewEncoder(w).Encode(resource)
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
- Pass dependencies (repository, service, config) as function parameters if needed
- Use serializer interface for encoding/decoding
- Handle errors consistently with appropriate status codes

**Note**: For shrtner-specific handler patterns (error types, serializer usage, `respond()` function), see `.cursor/rules/12-http-rest-standards.mdc`.

### Serialization

- Use interface pattern for serialization to support multiple formats (JSON, XML, etc.)
- Implement JSON serializer using standard library `encoding/json`
- Set Content-Type header appropriately (e.g., `application/json; charset=utf-8`)
- Handle encoding/decoding errors gracefully

**Note**: For shrtner-specific serializer implementation and `respond()` helper function, see `.cursor/rules/12-http-rest-standards.mdc`.

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

- Define custom error types with error codes for consistent responses
- Provide consistent error response format across all endpoints
- Never expose internal errors to clients
- Include error codes for programmatic handling
- Use error types that implement `error` interface
- Map domain errors to appropriate HTTP status codes

**Error response format:**
```json
{
  "code": "error_code",
  "message": "human-readable error message",
  "details": { /* optional additional context */ }
}
```

**Note**: For shrtner-specific error types (`NewBadRequestError`, `NewConflictError`, `NewNotFoundError`, etc.) and their usage, see `.cursor/rules/12-http-rest-standards.mdc`.

### Routing

- Use gorilla/mux for routing (only external library allowed)
- Define routes with path variables using `{name}` syntax
- Use `mux.Vars(r)` to extract path variables
- Explicitly specify HTTP methods using `.Methods("GET")`, `.Methods("POST")`, etc.
- Group routes by version or resource using subrouters
- Apply middleware using `router.Use()`

**Note**: For shrtner-specific router configuration (route definitions in `internal/shrtner/http/router.go`, middleware usage), see `.cursor/rules/12-http-rest-standards.mdc`.

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
- Keep parameter names consistent across endpoints
- Document required vs optional parameters
- Use standard library `r.URL.Query().Get()` and `r.URL.Query().Has()`
- Validate and convert types with `strconv` (standard library)
- Return 400 Bad Request for invalid parameter values
- Provide sensible defaults for optional parameters

**Common patterns:**
- Pagination: `page` and `size` (or `limit`/`offset`)
- Filtering: `status=active`, `owner_id=123`
- Sorting: `sort=created_at&order=desc`

**Note**: For shrtner-specific query parameter patterns (defaults, validation, pagination format), see `.cursor/rules/12-http-rest-standards.mdc`.

### Pagination

- Use `page` and `size` (or `offset` and `limit`) query parameters
- Include pagination metadata in response
- Provide links for next/previous pages when applicable
- Use consistent default values (e.g., `page=0`, `size=10`)

**Response format:**
```json
{
  "data": [...],
  "next_link": "/api/v1/resources?page=1&size=10"  // optional, when more data available
}
```

**Note**: For shrtner-specific pagination format (`page`/`size` defaults, `next_link` structure), see `.cursor/rules/12-http-rest-standards.mdc`.

### Authentication

- Use `Authorization: Bearer <token>` header
- Extract Principal from context (see authentication rules)
- Return 401 for missing/invalid tokens
- Return 403 for authorized but forbidden actions
- Use middleware for authentication (see middleware section)

```go
// ✅ GOOD: Authentication in handler
func CreateResource() func(w http.ResponseWriter, r *http.Request) {
    return func(w http.ResponseWriter, r *http.Request) {
        // Extract principal from context (implementation-specific)
        principal := getPrincipal(r.Context())
        if principal == nil {
            w.WriteHeader(http.StatusUnauthorized)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "401",
                Message: "missing or invalid token",
            })
            return
        }
        
        var body CreateRequest
        if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
            w.WriteHeader(http.StatusBadRequest)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "400",
                Message: "could not decode request body",
            })
            return
        }
        
        // Use principal for authorization/ownership (implementation-specific)
        resource, err := createResource(r.Context(), principal, body)
        if err != nil {
            w.WriteHeader(http.StatusConflict)
            json.NewEncoder(w).Encode(ErrorResponse{
                Code:    "409",
                Message: err.Error(),
            })
            return
        }
        
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusCreated)
        json.NewEncoder(w).Encode(resource)
    }
}
```

**Note**: For shrtner-specific authentication patterns (Principal extraction, JWT handling), see `.cursor/rules/05-authentication-security.mdc` and `.cursor/rules/12-http-rest-standards.mdc`.

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
| [.cursor/rules/12-http-rest-standards.mdc](.cursor/rules/12-http-rest-standards.mdc) | **shrtner-specific** HTTP/REST implementation standards (handler patterns, error types, router config, serializer usage) |
| [.cursor/rules/00-project-context.mdc](.cursor/rules/00-project-context.mdc) | Project overview, API ports, tech stack |
| [.cursor/rules/01-architecture.mdc](.cursor/rules/01-architecture.mdc) | Handler layer responsibilities, error handling, protocol transformation |
| [.cursor/rules/02-go-style-guide.mdc](.cursor/rules/02-go-style-guide.mdc) | Handler implementation patterns, context usage, error handling |
| [.cursor/rules/05-authentication-security.mdc](.cursor/rules/05-authentication-security.mdc) | JWT authentication, Principal pattern, authorization, public endpoints |
| [.cursor/rules/07-agent-behavior.mdc](.cursor/rules/07-agent-behavior.mdc) | Adding new API endpoints workflow, error handling, backward compatibility |
