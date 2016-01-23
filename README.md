lua-msgbus
=======

in-process message-bus module.


## Installation

```
luarocks install msgbus --from=http://mah0x211.github.io/rocks/
```


## API

### MsgBus.sub

Subscribe a message.

- **Syntax**: `MsgBus = MsgBus.sub( receiver, msg, callback [, ctx] )`
- **Parameters**: 
    - `receiver:<table or userdata>`
    - `msg:string`: a string that matches the [Message Pattern](#message-pattern).
    - `callback:function`: a function that has the following arguments;
        1. `receiver`
        2. `ctx`
        3. `...`
    - `ctx:any`: an any context value.
- **Returns**
    - `MsgBus`


### MsgBus.getnsub

Get a number of subscribers.

- **Syntax**: `nsub = MsgBus.getnsub( msg )`
- **Parameters**: 
    - `msg:string`: a string that matches the [Message Pattern](#message-pattern).
- **Returns**
    - `nsub`: number of subscribers.


### MsgBus.unsub

Unsubscribe a message.

- **Syntax**: `MsgBus = MsgBus.unsub( receiver, msg [, callback] )`
- **Parameters**:
    - `receiver:<table or userdata>`: unsubscribe a receiver associated message.
    - `msg:string`: a string that matches the [Message Pattern](#message-pattern).
    - `callback:function`: unsubscribe to a function  associated message.
- **Returns**
    - `MsgBus`


### MsgBus.pub

Publish a message.

- **Syntax**: `npub = MsgBus.pub( msg [, ...] )`
- **Parameters**:
    - `msg:string`: a string that matches the [Message Pattern](#message-pattern).
    - `...`: any arguments.
- **Returns**
    - `npub`: number of sent messages.


## Message Pattern

a `msg:string` format should be the following pattern;

- **String Pattern**: `[0-9a-zA-Z_]+`

