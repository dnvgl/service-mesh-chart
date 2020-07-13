# Migration notes for 0.17.x from 0.15.x

## Behavior changes

### Authentication/Authorization policy

The API for jwt settings has changed significantly to better support the use cases we've found as well as changes to Istio API.

Previously, Istio AuthenticationPolicy handled both Authentication as well as light authorization (requiring token-based authentication for a user).

The new syntax for authentication and authorization separate request-based authenication (jwt) and peer authentication (mtls) and allow specification of simple authorization rules. In addition, the JTWRules now support multiple origins as well as audiences.

#### Typical configuration

The new syntax is best given by example. The following is a typical simple access configuration. Service-a (the current service) supports inbound connections from service-b (which has a default service account). In addition, assume that service-a is exposed through the gateway.

New syntax:

``` yaml
requestAuthentication:
  jwtRules:
    - issuer:  "https://sts.windows.net/.../"
      jwksUri: "https://login.microsoftonline.com/common/discovery/keys"
      audiences:
      - audience1.dnvgl.com
      - audience2.dnvgl.com

authorizationPolicy:
  enabled: true # default is true
  authorizedServices:
    - servicePrincipalName: service-b
```

Previous syntax:

``` yaml
jwt:
  createPolicy: false # whether JWT authorization policy should be applied
  issuer: # "https://sts.windows.net/.../"
  jwksUri: "https://login.microsoftonline.com/common/discovery/keys"
```

> Note that the previous syntax only validates that the token is valid, it allows any source with this token (including ingress) to make the request. The new syntax also requires a token but further limits access to only the service account for service-b and ingress (depending on whether the exposeService flag is set).

#### Additional options for authorization

Extending the previous example, let's say we also have a service C which needs access to service A. Service C may call A directly (without a user-initiated request, and therefore without a token). Service C will be authenticated using mtls (peer authentication), but we do not require a token for this case. In addition, suppose we have changed the options for service C to name it's service account *service-c-sa*.

To handle this case, we change the authorized services to:

``` yaml
authorizationPolicy:
  authorizedServices:
    - servicePrincipalName: service-b
    - servicePrincipalName: service-c-sa
      requireJwt: false
```

#### Network policy

Finally, network policy adds an additional layer of protection by locking down communication at the pod networking level.

The following configuration will allow only incoming tcp traffic pods in the same namespace with either app=service-b or app=service-c labels, and it will allow communication from Istio Ingress and Pilot components in the istio-system namespace.

``` yaml
networkPolicy:
  enabled: true # default is false, but I think we should change this
  appsAllowedAccess:
    - service-b
    - service-c
```

> Note that for network policy, the configuration is based on labels rather than service principals, so while the syntax for allowed apps looks similar and the defaults are the same, there actually may be a difference depending on how the service accounts for your other services are configured.

### defaultRouting.redirectOnNoTrailingSlash

Used together with prefix routing, this option ensures that:

`...dnvgl.com/prefix` will be redirected to: `...dnvgl.com/prefix/`

This option is now enabled by default.

## Syntax changes

### Environment variables

The format for specifying environment variables has changed. Rather than a list of values, the new format treats them as a map with the name of the variable as the key. This supports overriding individual values and adding new values rather than having to replace the whole set. Both *value* and *valueFrom* constructs are supported.

A simple value is specified in the typical `name: value` yaml format. The alternative `valueFrom` source is treated literally and therefore handles all contents supported by the Kubernetes deployment api for environment variables.

New syntax:

``` yaml
env:
  Serilog__MinimumLevel: Debug
  user:
    valueFrom:
      secretKeyRef:
        name: mysecret
        key: username
```

Previous syntax:

``` yaml
environmentVariables: |
  - name: Serilog__MinimumLevel
    value: Debug
  - name: user
    valueFrom:
     secretKeyRef:
       name: mysecret
       key: username
```

### Improved syntax for rewriting URL prefixes

The new api for rewriting prefixes combines the previous two approaches while also grouping the options together for clarity

Here is the new syntax, with the defaults as shown:

``` yaml
defaultRouting:
  # ...

  # options for rewriting the URL to remove the routing prefix before delivering
  # the request to the target pod
  rewriteUrlPrefix:
    # replace the routing prefix when enabled (when disabled, the URL is not adjusted)
    enabled: true
    # replace the routing prefix with the provided string
    # alternate prefixes should begin and end with a "/"
    # examples: "/", "/api/"
    replaceWith: "/"
```

This replaces two older methods:

``` yaml
defaultRouting:

  # ...
  # old method 1
  enableRewrite: true
  rewriteUri: "/"

  # old method 2
  rewriteUrl: true #always rewrites to "/"
```

### settingsSecret and settingsConfigMap

These options are now desupported. The replacement syntax is to use the regular volume syntax. For example:

New syntax:

``` yaml
  volumes:
    - name: service-secrets
      mountPath: "/secrets"
      volumeDefinition: |
        secret:
          secretName: service-secrets
```

Previous syntax:

``` yaml
  settingsSecret:
    enabled: true
    volumeName: service-secrets
    mountPath: "/secrets"
    secretName: cascade-secrets

```

## De-supported options

### fullnameOverride

Full name override has been removed. We don't believe this was used.

### forwardAuthentication

While we are not removing forward authentication in general, this option has been moved from the service-level configuration to application/namespace level. All options under the `forwardAuthentication` setting have been removed from the service level chart.
