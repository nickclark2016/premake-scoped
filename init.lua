-- init.lua
--
-- Copyright (c) 2024 Nick Clark
-- MIT License

local p = require("premake", ">=5.0.0-alpha1")

local scoped = {}
scoped._VERSION = "1.2.0"

local group_stack = {}
local filter_stack = {}

--
-- Scoped workspace function
--
-- @param name Name of the workspace
-- @param fn Function to execute in the context of the workspace. Function will receive the workspace object as an optional parameter.
-- @post The active workspace will be set to all workspaces in the global scope.
--
function scoped.workspace(name, fn)
    -- Log a warning if the workspace is already active
    local activewks = p.api.scope.workspace
    if activewks then
        p.warn("Scoped workspace " .. name .. " is being created while workspace " .. activewks.name .. " is active.")
    end

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
    local activeprj = p.api.project
    if activeprj then
        p.warn("Scoped project " .. name .. " is being created while project " .. activeprj.name .. " is active.")
    end

    local activewks = p.api.scope.workspace
    if not activewks then
        p.error("Error: Scoped project " .. name .. " is being created without an active workspace.")
    end

    local group_name = table.concat(group_stack, "/")
    group(group_name)

    local prj = project(name)
    fn(prj)
    project("*")
    group("*")
end

--
-- Scoped usage function
--
-- @param name Name of the usage
-- @param fn Function to execute in the context of the usage
-- @post No usage will be active upon exit
--
function scoped.usage(name, fn)
    local activeusg = p.api.usage
    if activeusg then
        p.warn("Scoped usage " .. name .. " is being created while usage " .. activeusg.name .. " is active.")
    end

    local usg = usage(name)
    fn(usg)
    usage("*")
end

--
-- Scoped filter function
--
-- @param flt Filter to apply
-- @param fn Function to execute in the context of the filter
-- @post No filter will be active upon exit
--
function scoped.filter(flt, fn)
    local top = filter_stack[#filter_stack] or {}
    table.insert(filter_stack, flt)

    filter(filter_stack)
    fn()

    table.remove(filter_stack, #filter_stack)
    filter(filter_stack)
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
    table.insert(group_stack, grp)

    local full_group = table.concat(group_stack, "/")
    group(full_group)
    fn()

    -- Pop the group from the stack
    -- Merge the group stack into a single string
    -- Reapply the group
    table.remove(group_stack, nil)
    full_group = table.concat(group_stack, "/")

    if full_group == "" then
        group("*")
    else
        group(full_group)
    end
end

return scoped
