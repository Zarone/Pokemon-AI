#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include <stdio.h>

int get_move(lua_State *L){
    
    // lua should pass in zero arguments for this
    lua_settop(L, 0);
    lua_pushstring(L, "value pushed from get_move()");
    return 1;

}

int luaopen_processor(lua_State *L){
  luaL_Reg fns[] = {
    {"get_move", get_move},
    {NULL, NULL}
  };
  luaL_newlib(L, fns);
  return 1;  // Number of Lua-facing return values on the Lua stack in L.
}