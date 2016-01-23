-- create class
local MsgBus = require('msgbus');
local unpack = unpack or table.unpack;

local invoked = {
    hello = {
        count = 0
    },
    hello2 = {
        count = 0
    },
    world = {
        count = 0
    }
};

local function update( tbl, ctx, ... )
    tbl.count = tbl.count + 1;
    tbl.ctx = ctx;
    tbl.args = {...};
end


local Rcvr = {};

function Rcvr:hello( ... )
    update( invoked.hello, ... );
end

function Rcvr:hello2( ... )
    update( invoked.hello2, ... );
end

function Rcvr:world( ... )
    update( invoked.world, ... );
end


-- invalid arguments
local yes = true;
local num = 1;
local str = 'character';
local tbl = {};
local fn = function()end;
local co = coroutine.create(fn);

-- subscribe
for _, arg in ipairs({
    -- receiver
    {},
    { yes },
    { num },
    { str },
    { fn },
    { co },
    -- msg
    { tbl,  yes },
    { tbl,  num },
    { tbl,  tbl },
    { tbl,  fn },
    { tbl,  co },
    -- callback
    { tbl,  str, yes },
    { tbl,  str, num },
    { tbl,  str, str },
    { tbl,  str, tbl },
    { tbl,  str, co }
}) do
    ifTrue(isolate(function()
        MsgBus.sub( unpack( arg ) );
    end));
end


-- unsubscribe
for _, arg in ipairs({
    -- receiver
    {},
    { yes },
    { num },
    { str },
    { fn },
    { co },
    -- msg
    { tbl,  yes },
    { tbl,  num },
    { tbl,  tbl },
    { tbl,  fn },
    { tbl,  co },
    -- callback
    { tbl,  str, yes },
    { tbl,  str, num },
    { tbl,  str, str },
    { tbl,  str, tbl },
    { tbl,  str, co }
}) do
    ifTrue(isolate(function()
        MsgBus.unsub( unpack( arg ) );
        print('ok', inspect( arg ) );
    end));
end


-- publish
for _, arg in ipairs({
    -- receiver
    {},
    { yes },
    { num },
    { tbl },
    { fn },
    { co }
}) do
    ifTrue(isolate(function()
        MsgBus.pub( unpack( arg ) );
        print('ok', inspect( arg ) );
    end));
end


-- add observers
MsgBus
.sub( Rcvr, 'hello', Rcvr.hello, 'hello context' )
.sub( Rcvr, 'hello', Rcvr.hello2, 'hello context' );
-- check
ifNotEqual( MsgBus.getnsub('hello'), 2 );

-- post
ifNotEqual( { MsgBus.pub('hello') }, { 2 } );
ifNotEqual( invoked.hello.ctx, 'hello context' );
ifNotEqual( invoked.hello.count, 1 );


-- post with arguments
local args = { 'a', 'b', 'c' };
local args2 = { 'x', 'y', 'z' };
ifNotEqual( { MsgBus.pub('hello', unpack( args ) ) }, { 2 } );
ifNotEqual( invoked.hello.ctx, 'hello context' );
ifNotEqual( invoked.hello.count, 2 );
ifNotEqual( invoked.hello.args, args );
ifNotEqual( invoked.hello, invoked.hello2 );


-- remove cbHello
MsgBus.unsub( Rcvr, 'hello', Rcvr.hello );
ifNotEqual( MsgBus.getnsub('hello'), 1 );
ifNotEqual( { MsgBus.pub('hello', unpack( args2 ) ) }, { 1 } );
ifNotEqual( invoked.hello.ctx, 'hello context' );
ifNotEqual( invoked.hello.count, 2 );
ifNotEqual( invoked.hello.args, args );
-- hello2 still alive
ifNotEqual( invoked.hello2.ctx, 'hello context' );
ifNotEqual( invoked.hello2.count, 3 );
ifNotEqual( invoked.hello2.args, args2 );

-- remove all 'hello' observer
MsgBus.unsub( Rcvr, 'hello' );
ifNotEqual( MsgBus.getnsub('hello'), 0 );
ifNotEqual( { MsgBus.pub('hello', unpack( args ) ) }, { 0 } );
ifNotEqual( invoked.hello.ctx, 'hello context' );
ifNotEqual( invoked.hello.count, 2 );
ifNotEqual( invoked.hello.args, args );
ifNotEqual( invoked.hello2.ctx, 'hello context' );
ifNotEqual( invoked.hello2.count, 3 );
ifNotEqual( invoked.hello2.args, args2 );


-- remove observer
MsgBus.sub( Rcvr, 'world', Rcvr.world, 'world context' );
ifNotEqual( MsgBus.getnsub('world'), 1 );
ifNotEqual( { MsgBus.pub( 'world', unpack( args2 ) ) }, { 1 } );
ifNotEqual( invoked.world.ctx, 'world context' );
ifNotEqual( invoked.world.count, 1 );
ifNotEqual( invoked.world.args, args2 );

