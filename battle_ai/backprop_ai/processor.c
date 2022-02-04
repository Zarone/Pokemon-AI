#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include "mpack/mpack.h"
#include <stdio.h>
#include <string.h>

static char *readcontent(const char *filename)
{
    char *fcontent = NULL;
    int fsize = 0;
    FILE *fp;

    fp = fopen(filename, "r");
    if(fp) {
        fseek(fp, 0, SEEK_END);
        fsize = ftell(fp);
        rewind(fp);

        fcontent = (char*) malloc(sizeof(char) * fsize);
        fread(fcontent, 1, fsize, fp);

        fclose(fp);
    }
    return fcontent;
}

void do_something_with_tag(mpack_tag_t *tag){
  printf("tag called: %s\n", mpack_type_to_string(tag->type));
}

void parse_element(mpack_reader_t* reader, int depth) {
    if (depth >= 32) { // critical check!
        mpack_reader_flag_error(reader, mpack_error_too_big);
        return;
    }
 
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok)
        return;
 
    do_something_with_tag(&tag);
 
    if (mpack_tag_type(&tag) == mpack_type_array) {
        uint32_t count = mpack_tag_array_count(&tag);
        printf("count: %u\n", count);
        for (uint32_t i = count; i > 0; --i) {
            printf("here\n");
            parse_element(reader, depth + 1);
            if (mpack_reader_error(reader) != mpack_ok) // critical check!
                printf("error: %i\n", (int)mpack_reader_error(reader));
                break;
        }
        mpack_done_array(reader);
    }
 
    if (mpack_tag_type(&tag) == mpack_type_map) {
        for (uint32_t i = mpack_tag_map_count(&tag); i > 0; --i) {
            parse_element(reader, depth + 1);
            parse_element(reader, depth + 1);
            if (mpack_reader_error(reader) != mpack_ok) // critical check!
                break;
        }
        mpack_done_map(reader);
    }
}

int getTree(){

  mpack_reader_t reader;
  mpack_reader_init_filename(&reader, "./battle_ai/backprop_ai/weights.txt");

  // parse_element(&reader, 2);
  // mpack_tag_t tag = mpack_read_tag(&reader);
  // do_something_with_tag(&tag);

  return mpack_reader_destroy(&reader) == mpack_ok;
}



int get_move(lua_State *L){
    
    // lua should pass in zero arguments for this
    lua_settop(L, 0);
 
    getTree();

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