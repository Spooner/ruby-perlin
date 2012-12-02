/*
 * class Perlin::Generator
 */

#ifndef GENERATOR_H
#define GENERATOR_H

#include <ruby.h>

#include <stdbool.h>

#include "classic.h"
#include "simplex.h"

extern long seed;

void Init_Perlin_Generator();

// Getters.
VALUE Perlin_Generator_get_seed(const VALUE self);
VALUE Perlin_Generator_get_persistence(const VALUE self);
VALUE Perlin_Generator_get_octave(const VALUE self);
VALUE Perlin_Generator_get_classic(const VALUE self);

// Setters.
VALUE Perlin_Generator_set_seed(const VALUE self, const VALUE seed);
VALUE Perlin_Generator_set_persistence(const VALUE self, const VALUE persistence);
VALUE Perlin_Generator_set_octave(const VALUE self, const VALUE octave);
VALUE Perlin_Generator_set_classic(const VALUE self, const VALUE classic);

// Actually getting noise.
VALUE Perlin_Generator_run(const int argc, const VALUE *argv, const VALUE self);
VALUE Perlin_Generator_run2d(const VALUE self, const VALUE x, const VALUE y);
VALUE Perlin_Generator_run3d(const VALUE self, const VALUE x, const VALUE y, const VALUE z);

VALUE Perlin_Generator_chunk(const int argc, const VALUE *argv, const VALUE self);
VALUE Perlin_Generator_chunk2d(const VALUE self, const VALUE x, const VALUE y, const VALUE steps_x, const VALUE steps_y, VALUE interval);
VALUE Perlin_Generator_chunk3d(const VALUE self, const VALUE x, const VALUE y, const VALUE z, const VALUE steps_x, const VALUE steps_y, const VALUE steps_z, const VALUE interval);

VALUE Perlin_Generator_init(const int argc, const VALUE *argv, const VALUE self);

// Data management stuff.

typedef struct _PerlinGenerator
{
    bool is_classic; // True if Classic, false if Simplex.
    long seed; // >= 1
    long octave; // >= 1
    double persistence;
} PerlinGenerator;

#define GENERATOR() \
    PerlinGenerator* generator; \
    Data_Get_Struct(self, PerlinGenerator, generator);

VALUE Perlin_Generator_allocate(VALUE klass);
void Perlin_Generator_free(PerlinGenerator* generator);

#endif // GENERATOR_H