--[[

  Copyright (C) 2016 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.


  msgbus.lua
  lua-msgbus
  Created by Masatoshi Teruya on 16/01/23.

--]]

-- assign to local
local floor = math.floor;
-- constants
local INFINITE_POS = math.huge;
-- containers
local Notifications = {};
local NSub = {};
local Changelist;

-- private functions

--- subscribe notification
local function subscribe( receiver, msg, callback, ctx )
    -- create subscribers[receiver] table
    if not Notifications[msg] then
        local callbacks = setmetatable({
            [callback] = ctx
        }, {
            __mode = 'k'
        });

        Notifications[msg] = setmetatable({
            [receiver] = callbacks
        },{
            __mode = 'k'
        });
    -- add subscriber
    else
        Notifications[msg][receiver][callback] = ctx;
    end

end


--- unsubscribe notification
function unsubscribe( receiver, msg, callback )
    local subs = Notifications[msg];

    -- remove subscriber associated with receiver
    if subs and subs[receiver] then
        if callback then
            subs[receiver][callback] = nil;
        else
            subs[receiver] = nil;
        end

        -- remove empty-subscribers from notification container
        if NSub[msg] == 0 then
            Notifications[msg] = nil;
            NSub[msg] = nil;
        end
    end
end


-- class
local MsgBus = {};


--- get number of subscribers
-- @return nsub
function MsgBus.getnsub( msg )
    if type( msg ) ~= 'string' or msg == '' then
        error( 'msg must be type of non-empty string', 2 );
    end

    return NSub[msg] or 0;
end


--- subscribe notification
-- @param receiver
-- @param msg
-- @param callback
-- @param ctx
-- @return MsgBus
function MsgBus.sub( receiver, msg, callback, ctx )
    local subs = Notifications[msg];

    if type( receiver ) ~= 'table' then
        error( 'receiver must be type of table', 2 );
    elseif type( msg ) ~= 'string' or msg == '' then
        error( 'msg must be type of non-empty string', 2 );
    elseif type( callback ) ~= 'function' then
        error( 'callback must be type of function', 2 );
    -- update context if already subscribed
    elseif subs and subs[receiver] and subs[receiver][callback] then
        subs[receiver][callback] = ctx;
        return MsgBus;
    -- increment number of subscriber
    elseif not NSub[msg] then
        NSub[msg] = 1;
    else
        NSub[msg] = NSub[msg] + 1;
    end

    -- add to Changelist
    if Changelist then
        Changelist[#Changelist + 1] = {
            proc = subscribe,
            msg = msg,
            receiver = receiver,
            callback = callback,
            ctx = ctx
        };
    -- add to subscribers
    else
        subscribe( receiver, msg, callback, ctx );
    end

    return MsgBus;
end


--- unsubscribe notification
-- @param receiver
-- @param msg
-- @param callback
-- @return MsgBus
function MsgBus.unsub( receiver, msg, callback )
    local subs = Notifications[msg];

    if type( receiver ) ~= 'table' then
        error( 'receiver must be type of table', 2 );
    elseif type( msg ) ~= 'string' or msg == '' then
        error( 'msg must be type of non-empty string', 2 );
    elseif callback ~= nil and type( callback ) ~= 'function' then
        error( 'callback must be type of function', 2 );
    -- unsubscribe if registered
    elseif subs and subs[receiver] and
           ( callback == nil or subs[receiver][callback] ) then

        -- decrement number of subscriber
        NSub[msg] = NSub[msg] - 1;

        if Changelist then
            Changelist[#Changelist + 1] = {
                proc = unsubscribe,
                receiver = receiver,
                msg = msg,
                callback = callback
            };
        else
            unsubscribe( receiver, msg, callback );
        end
    end

    return MsgBus;
end


--- publish notification
-- @param msg
-- @param ...
-- @return notified
function MsgBus.pub( msg, ... )
    if type( msg ) ~= 'string' or msg == '' then
        error( 'msg must be type of non-empty string', 2 );
    else
        local subs = Notifications[msg];
        local notified = 0;

        if subs then
            local changelist = {};
            local item;

            -- set changelist reference
            Changelist = changelist;

            -- notify
            for receiver, callbacks in pairs( subs ) do
                for fn, ctx in pairs( callbacks ) do
                    notified = notified + 1;
                    fn( receiver, ctx, ... );
                end
            end

            -- remove changelist reference
            Changelist = nil;

            -- apply changelist
            for i = 1, #changelist do
                item = changelist[i];
                -- increment remove
                if item.proc == unsubscribe then
                    item.proc( item.receiver, item.msg, item.callback );
                else
                    item.proc( item.receiver, item.msg, item.callback, item.ctx );
                end
            end
        end

        return notified;
    end
end


local function newindex( _, k )
    error( ('attempt to newindex %q'):format( k ), 2 );
end


return setmetatable( MsgBus, {
    __metatable = 1,
    __newindex = newindex
});

