/*
Ruby module that is built according to the Perlin Noise function
located at http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
*/

#include "perlin.h"

void Init_perlin() {
    VALUE jm_Module = rb_define_module("Perlin");
    Init_Perlin_Generator(jm_Module);
}

