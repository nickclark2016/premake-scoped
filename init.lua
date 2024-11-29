-- init.lua
--
-- Copyright (c) 2024 Nick Clark
-- MIT License

require("premake", ">=5.0.0-alpha1")

local scoped = {}
scoped._VERSION = "1.0.0"

local group_stack = {}

--
-- Scoped workspace function
--
-- @param name Name of the workspace
-- @param fn Function to execute in the context of the workspace. Function will receive the workspace object as an optional parameter.
-- @post The active workspace will be set to all workspaces in the global scope.
--
function scoped.workspace(name, fn)
    local wks = workspace(name)
    fn(wks)
    workspace("*")
end

--
-- Scoped project function
--
-- @param name Name of the project
-- @param fn Function to execute in the context of the project. Function will receive the project object as an optional parameter.
-- @post The active scope will be set to the scope active upon entry to the function, or the parent scope if the prior scope is the same as the scope entered.
--
function scoped.project(name, fn)
    local prj = project(name)
    fn(prj)
    project("*")
end

--
-- Scoped filter function
--
-- @param flt Filter to apply
-- @param fn Function to execute in the context of the filter
-- @post No filter will be active upon exit
--
function scoped.filter(flt, fn)
    filter(flt)
    fn()
    filter({})
end

--
-- Scoped group function. Unlike Premake's group function, this function will build "inner" groups without the need to insert slashes.
--
-- @param grp Group to apply
-- @param fn Function to execute in the context of the group
-- @post No group will be active upon exit
--
function scoped.group(grp, fn)
    -- Get the top of the group stack, or an empty string if the stack is empty
    -- Push the new group onto the stack
    -- Merge the group stack into a single string
    local top = group_stack[#group_stack] or ""
    table.insert(group_stack, grp)

    local full_group = table.concat(group_stack, "/")
    
    group(full_group)
    fn()

    -- Pop the group from the stack
    -- Merge the group stack into a single string
    -- Reapply the group
    table.remove(group_stack, #group_stack)
    full_group = table.concat(group_stack, "/")

    if full_group == "" then
        group("*")
    else
        group(full_group)
    end
end

return scoped