#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include "mpack/mpack.h"
#include <stdio.h>

mpack_tree_t getTree(int *error){
  mpack_tree_t tree;
  mpack_tree_init_filename(&tree, "./battle_ai/backprop_ai/weights.txt", 100);
  mpack_tree_parse(&tree);
  mpack_node_t root = mpack_tree_root(&tree);

  // extract the example data on the msgpack homepage
  bool compact = mpack_node_bool(mpack_node_map_cstr(root, "compact"));
  int schema = mpack_node_i32(mpack_node_map_cstr(root, "schema"));

  // clean up and check for errors
  return tree;
  // if (mpack_tree_destroy(&tree) != mpack_ok) {
  //     fprintf(stderr, "An error occurred decoding the data!\n");
  //     *error = 1;
  // }
}



int get_move(lua_State *L){
    
    // lua should pass in zero arguments for this
    lua_settop(L, 0);

    int error;
    mpack_tree_t tree = getTree(&error);
    if (error != 0){
      printf("success");
    }

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