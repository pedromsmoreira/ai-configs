---
name: http-rest-endpoints
description: Create HTTP handlers and REST endpoints following shrtner project standards. Use when creating new handlers, endpoints, or modifying existing HTTP routes. Applies to handlers, routers, and HTTP-related code.
---

# HTTP and REST Endpoint Development

Quick reference for creating HTTP handlers and REST endpoints in the shrtner project. For comprehensive standards and detailed patterns, see `.cursor/rules/12-http-rest-standards.mdc`.

## Quick Checklist

When creating a new handler:

1. ✅ Return `func(w http.ResponseWriter, r *http.Request)` (higher-order function pattern)
2. ✅ Use `serializer := JSON` and `respond()` function
3. ✅ Use appropriate HTTP status codes (200, 201, 204, 400, 404, 409, 500)
4. ✅ Use custom error types from `handlers/errors.go`
5. ✅ Pass `context.Background()` to repository calls
6. ✅ Register route in `internal/shrtner/http/router.go` with `.Methods()`
7. ✅ Extract path parameters using `mux.Vars(r)`
8. ✅ Validate query parameters and return 400 on invalid input

## Common Patterns

**Handler skeleton:**
```go
func Create(dns string, repository data.Create) func(w http.ResponseWriter, r *http.Request) {
    serializer := JSON
    return func(w http.ResponseWriter, r *http.Request) {
        // 1. Decode request body
        var body UrlMetadata
        err := serializer.Decode(w, r, &body)
        if err != nil {
            respond(w, r, http.StatusBadRequest, NewBadRequestError("could not decode the request body", details), serializer)
            return
        }
        
        // 2. Validate input
        if body.Original == "" {
            respond(w, r, http.StatusBadRequest, NewBadRequestError("[original] property should not be empty", nil), serializer)
            return
        }
        
        // 3. Business logic (domain layer)
        u, err := url.New(body.Original, body.ExpirationDate)
        if err != nil {
            respond(w, r, http.StatusInternalServerError, NewInternalServerError("an error occurred"), serializer)
            return
        }
        
        // 4. Repository call (always use context.Background())
        cUrl, err := repository.Create(context.Background(), u)
        if err != nil {
            logrus.WithField("error", err.Error()).Warning("conflict")
            respond(w, r, http.StatusConflict, NewConflictError(err.Error()), serializer)
            return
        }
        
        // 5. Success response
        rBody := &UrlMetadata{
            Original:       cUrl.Original,
            Short:          fmt.Sprintf("%s/%s", dns, cUrl.Short),
            ExpirationDate: cUrl.ExpirationDate,
            DateCreated:    cUrl.DateCreated,
        }
        respond(w, r, http.StatusCreated, rBody, serializer)
    }
}
```

**Path parameters:**
```go
params := mux.Vars(r)
id := params["id"]
```

**Query parameters with validation:**
```go
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
    respond(w, r, http.StatusBadRequest, NewBadRequestErrorWithoutDetails(fmt.Sprintf("[page] was %v. Must be an integer.", qPage)), serializer)
    return
}
s, err := strconv.Atoi(qSize)
if err != nil {
    respond(w, r, http.StatusBadRequest, NewBadRequestErrorWithoutDetails(fmt.Sprintf("[size] was %v. Must be an integer.", qSize)), serializer)
    return
}
```

## Status Code Quick Reference

- `200 OK` - Successful GET
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE
- `400 Bad Request` - Validation errors
- `404 Not Found` - Resource not found
- `409 Conflict` - Duplicate resources
- `500 Internal Server Error` - Server errors

## Error Types

```go
NewBadRequestError("message", details)
NewBadRequestErrorWithoutDetails("message")
NewConflictError(err.Error())
NewNotFoundError(r.URL.Path)
NewInternalServerError("message")
```

## Additional Resources

- **Full standards**: `.cursor/rules/12-http-rest-standards.mdc` - Complete shrtner-specific HTTP/REST standards
- **General REST principles**: `.cursor/skills/rest-api-design/SKILL.md` - General REST design patterns and principles
- **Router configuration**: See rule file for `internal/shrtner/http/router.go` setup
- **Error types**: See rule file for all error constructors (`NewBadRequestError`, `NewConflictError`, etc.)
- **Pagination**: See rule file for `page`/`size` defaults and `next_link` format
- **Serialization**: See rule file for serializer interface and `respond()` function usage
