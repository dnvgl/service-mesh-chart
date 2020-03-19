# Migration notes for v1

## Behavior changes

### defaultRouting.redirectOnNoTrailingSlash

Used together with prefix routing, this option ensures that 

`...dnvgl.com/prefix` will be redirected to: `...dnvgl.com/prefix/`

This option is now enabled by default.
  

## Syntax changes

### Environment variables

The format for specifying environment variables has changed. Previously, a string-based approach was used in the yaml. This meant that to override any environment variables specified in the chart, you needed to override them all since it was basically one large string. Now, you specify the environment variables as normal yaml. The only difference from a syntax perspective is that you leave the `|` character out.

Previous syntax:
``` yaml
environmentVariables: |
 - name: Serilog__MinimumLevel
   value: Debug
   valueFrom:
     secretKeyRef:
       name: mysecret
       key: username

```

New syntax:

``` yaml
environmentVariables:
 - name: Serilog__MinimumLevel
   value: Debug
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

Previous syntax:
``` yaml
  settingsSecret:
    enabled: true
    volumeName: service-secrets
    mountPath: "/secrets"
    secretName: cascade-secrets

```

``` yaml
  volumes:
    - name: service-secrets
      mountPath: "/secrets"
      volumeDefinition: |
        secret:
          secretName: service-secrets
```

## De-supported options

### fullnameOverride
Full name override has been removed. We don't believe this was used.

### forwardAuthentication

While we are not removing forward authentication, this option has been moved from the service-level configuration to application/namespace level. All options under the `forwardAuthentication` setting have been removed from the service level chart.
