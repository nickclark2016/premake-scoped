# Premake Scoped

Provides function-scoped utilities for Premake 5, rather than relying on the implicit scoping mechanisms.

### Installation
Clone the repository somewhere along the Premake search paths ([See Here](https://premake.github.io/docs/Locating-Scripts)). In your top level build file, add:

```lua
scoped = require('premake-scoped')
```

### API and Usage
This library provides direct replacements for the premake `workspace`, `project`, `usage`, `group`, and `filter` APIs.

```lua
scoped.workspace('My Workspace', function(wks)
    scoped.group('My Group', function()
        scoped.group('My Subgroup', function()
            scoped.project('My Project', function(prj)
                scoped.filter({ 'configuration:Debug' }, function()
                
                end)

                scoped.usage('MyUsage', function(usg)

                end)
            end)
        end)
    end)
end)
```

When each function is exited, the scope is reset to no longer apply to that function. This eliminates the need to perform things like `filter {}` or `workspace "*"` to reset your scope. In addition, this allows the ability to define groups inside of groups implicitly, rather than explicitly needing to add `"/"` to create subgroups.