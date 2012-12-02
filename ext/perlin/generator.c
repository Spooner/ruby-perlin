#include "generator.h"

void Init_Perlin_Generator(VALUE module)
{
    VALUE rb_cPerlinGenerator = rb_define_class_under(module, "Generator", rb_cObject);
    rb_define_alloc_func(rb_cPerlinGenerator, Perlin_Generator_allocate);

    rb_define_method(rb_cPerlinGenerator, "initialize", Perlin_Generator_init, -1);

    rb_define_method(rb_cPerlinGenerator, "seed", Perlin_Generator_get_seed, 0);
    rb_define_method(rb_cPerlinGenerator, "persistence", Perlin_Generator_get_persistence, 0);
    rb_define_method(rb_cPerlinGenerator, "octave", Perlin_Generator_get_octave, 0);
    rb_define_method(rb_cPerlinGenerator, "classic?", Perlin_Generator_get_classic, 0);

    rb_define_method(rb_cPerlinGenerator, "seed=", Perlin_Generator_set_seed, 1);
    rb_define_method(rb_cPerlinGenerator, "persistence=", Perlin_Generator_set_persistence, 1);
    rb_define_method(rb_cPerlinGenerator, "octave=", Perlin_Generator_set_octave, 1);
    rb_define_method(rb_cPerlinGenerator, "classic=", Perlin_Generator_set_classic, 1);

    rb_define_method(rb_cPerlinGenerator, "[]", Perlin_Generator_run, -1);
    rb_define_method(rb_cPerlinGenerator, "run2d", Perlin_Generator_run2d, 2);
    rb_define_method(rb_cPerlinGenerator, "run3d", Perlin_Generator_run3d, 3);

    rb_define_method(rb_cPerlinGenerator, "chunk", Perlin_Generator_chunk, -1);
    rb_define_method(rb_cPerlinGenerator, "chunk2d", Perlin_Generator_chunk2d, 5);
    rb_define_method(rb_cPerlinGenerator, "chunk3d", Perlin_Generator_chunk3d, 7);
}

// Memory management.

VALUE Perlin_Generator_allocate(VALUE klass)
{
    PerlinGenerator* generator = ALLOC(PerlinGenerator);
    memset(generator, 0, sizeof(PerlinGenerator));

    return Data_Wrap_Struct(klass, 0, Perlin_Generator_free, generator);
}

void Perlin_Generator_free(PerlinGenerator* generator)
{
    xfree(generator);
}

// Getters and setters.

VALUE Perlin_Generator_set_seed(const VALUE self, const VALUE seed)
{
    GENERATOR();

    long _seed = NUM2LONG(seed);
    if(_seed < 0) rb_raise(rb_eArgError, "seed must be >= 0");
    generator->seed = _seed;

    return seed;
}

VALUE Perlin_Generator_get_seed(const VALUE self)
{
    GENERATOR();
    return LONG2NUM(generator->seed);
}

VALUE Perlin_Generator_set_persistence(const VALUE self, const VALUE persistence)
{
    GENERATOR();
    generator->persistence = NUM2DBL(persistence);
    return persistence;
}

VALUE Perlin_Generator_get_persistence(const VALUE self)
{
    GENERATOR();
    return rb_float_new(generator->persistence);
}

VALUE Perlin_Generator_set_octave(const VALUE self, const VALUE octave)
{
    GENERATOR();

    long _octave = NUM2LONG(octave);
    if(_octave < 1) rb_raise(rb_eArgError, "octave must be >= 1");
    generator->octave = _octave;

    return octave;
}

VALUE Perlin_Generator_get_octave(const VALUE self)
{
    GENERATOR();
    return UINT2NUM(generator->octave);
}

VALUE Perlin_Generator_set_classic(const VALUE self, const VALUE classic)
{
    GENERATOR();
    generator->is_classic = RTEST(classic);
    return classic;
}

VALUE Perlin_Generator_get_classic(const VALUE self)
{
    GENERATOR();
    return (generator->is_classic ? Qtrue : Qfalse);
}

// x, y
// x, y, z
VALUE Perlin_Generator_run(const int argc, const VALUE *argv, const VALUE self)
{
    VALUE x, y, z;

    rb_scan_args(argc, argv, "21", &x, &y, &z);

    switch(argc)
    {
        case 2:  return Perlin_Generator_run2d(self, x, y);
        case 3:  return Perlin_Generator_run3d(self, x, y, z);
        default: rb_raise(rb_eArgError, "%d parameters not supported (2D and 3D are)", argc);
    }
}

/*
Takes points (x, y) and returns a height (n)
*/
VALUE Perlin_Generator_run2d(const VALUE self, const VALUE x, const VALUE y)
{
    GENERATOR();

    if(generator->is_classic)
    {
        seed = generator->seed; // Store in global, for speed.
        return rb_float_new(perlin_octaves_2d(NUM2DBL(x), NUM2DBL(y), generator->persistence, generator->octave));
    }
    else
    {
        return rb_float_new(octave_noise_3d(generator->octave, generator->persistence, 1.0, NUM2DBL(x), NUM2DBL(y),
                            generator->seed * SEED_OFFSET));
    }
}

/*
Takes points (x, y, z) and returns a height (n)
*/
VALUE Perlin_Generator_run3d(const VALUE self, const VALUE x, const VALUE y, const VALUE z)
{
    GENERATOR();

    if(generator->is_classic)
    {
        seed = generator->seed; // Store in global, for speed.
        return rb_float_new(perlin_octaves_3d(NUM2DBL(x), NUM2DBL(y), NUM2DBL(z), generator->persistence, generator->octave));
    }
    else
    {
        return rb_float_new(octave_noise_4d(generator->octave, generator->persistence, 1.0, NUM2DBL(x), NUM2DBL(y), NUM2DBL(z),
                            generator->seed * SEED_OFFSET));
    }

}

// x, y steps_x, steps_y, interval
// x, y, z, steps_x, steps_y, steps_z, interval
VALUE Perlin_Generator_chunk(const int argc, const VALUE *argv, const VALUE self)
{
    VALUE a, b, c, d, e, f, g;

    rb_scan_args(argc, argv, "52", &a, &b, &c, &d, &e, &f, &g);

    switch(argc)
    {
        case 5:  return Perlin_Generator_chunk2d(self, a, b, c, d, e);
        case 7:  return Perlin_Generator_chunk3d(self, a, b, c, d, e, f, g);
        default: rb_raise(rb_eArgError, "%d parameters not supported (5 for 2D and 7 for 3D are)", argc);
    }
}

/*
Returns a chunk of coordinates starting from x, y and of size steps_x, steps_y with interval.
*/
VALUE Perlin_Generator_chunk2d(const VALUE self, const VALUE x, const VALUE y, const VALUE steps_x, const VALUE steps_y, const VALUE interval)
{
    GENERATOR();

    VALUE arr, row;
    int i, j;

    const float x_min = NUM2DBL(x), y_min = NUM2DBL(y);
    float _x, _y;
    const int _steps_x = NUM2INT(steps_x), _steps_y = NUM2INT(steps_y);
    const float _interval = NUM2DBL(interval);

    if(_steps_x < 1 || _steps_y < 1)
    {
        rb_raise(rb_eArgError, "steps must be >= 1");
    }

    if(generator->is_classic) seed = generator->seed; // Store in global, for speed.

    if(rb_block_given_p())
    {
        // Iterate through x, then y [0, 0], [1, 0], [2, 0]...
        _x = x_min;
        for (i = 0; i < _steps_x; i++)
        {
           _y = y_min;
           for (j = 0; j < _steps_y; j++)
           {
                if(generator->is_classic)
                {
                    rb_yield_values(3, rb_float_new(perlin_octaves_2d(_x, _y, generator->persistence, generator->octave)),
                                    rb_float_new(_x), rb_float_new(_y));
                }
                else
                {
                    rb_yield_values(3, rb_float_new(octave_noise_3d(generator->octave, generator->persistence, 1.0, _x, _y, generator->seed * SEED_OFFSET)),
                                    rb_float_new(_x), rb_float_new(_y));
                }

                _y += _interval;
           }
           _x += _interval;
       }

       return Qnil;
    }
    else
    {
        // 2D array can be indexed with arr[x][y]
        arr = rb_ary_new();
        _x = x_min;
        for (i = 0; i < _steps_x; i++)
        {
            row = rb_ary_new();
            _y = y_min;
            for (j = 0; j < _steps_y; j++)
            {
                if(generator->is_classic)
                {
                    rb_ary_push(row, rb_float_new(perlin_octaves_2d(_x, _y, generator->persistence, generator->octave)));
                }
                else
                {
                    rb_ary_push(row, rb_float_new(octave_noise_3d(generator->octave, generator->persistence, 1.0, _x, _y, generator->seed * SEED_OFFSET)));
                }

                _y += _interval;
            }
            rb_ary_push(arr, row);
            _x += _interval;
        }
        return arr;
    }
}

/*
Returns a chunk of coordinates starting from x, y, z and of size steps_x, steps_y, size_z with interval.
*/
VALUE Perlin_Generator_chunk3d(const VALUE self, const VALUE x, const VALUE y, const VALUE z, const VALUE steps_x, const VALUE steps_y, const VALUE steps_z, const VALUE interval)
{
    GENERATOR();

    VALUE arr, row, column;
    int i, j, k;

    const float x_min = NUM2DBL(x), y_min = NUM2DBL(y), z_min = NUM2DBL(z);
    float _x, _y, _z;
    const int _steps_x = NUM2INT(steps_x), _steps_y = NUM2INT(steps_y), _steps_z = NUM2INT(steps_z);
    const float _interval = NUM2DBL(interval);

    if(_steps_x < 1 || _steps_y < 1 || _steps_z < 1)
    {
        rb_raise(rb_eArgError, "steps must be >= 1");
    }

    if(generator->is_classic) seed = generator->seed; // Store in global, for speed.

    if(rb_block_given_p())
    {
        _x = x_min;
        for (i = 0; i < _steps_x; i++)
        {
            _y = y_min;
            for (j = 0; j < _steps_y; j++)
            {
                _z = z_min;
                for (k = 0; k < _steps_z; k++)
                {
                    if(generator->is_classic)
                    {
                        rb_yield_values(4, rb_float_new(perlin_octaves_3d(_x, _y, _z, generator->persistence, generator->octave)),
                                        rb_float_new(_x), rb_float_new(_y), rb_float_new(_z));
                    }
                    else
                    {
                        rb_yield_values(4,
                                        rb_float_new(octave_noise_4d(generator->octave, generator->persistence, 1.0, _x, _y, _z, generator->seed * SEED_OFFSET)),
                                        rb_float_new(_x), rb_float_new(_y), rb_float_new(_z));
                    }

                    _z += _interval;
                }
                _y += _interval;
            }
            _x += _interval;
        }
        return Qnil;
    }
    else
    {
        arr = rb_ary_new();
        _x = x_min;
        for (i = 0; i < _steps_x; i++)
        {
            row = rb_ary_new();
            _y = y_min;
            for (j = 0; j < _steps_y; j++)
            {
                column = rb_ary_new();
                _z = z_min;
                for (k = 0; k < _steps_z; k++)
                {
                    if(generator->is_classic)
                    {
                        rb_ary_push(column, rb_float_new(perlin_octaves_3d(_x, _y, _z, generator->persistence, generator->octave)));
                    }
                    else
                    {
                        rb_ary_push(column, rb_float_new(octave_noise_4d(generator->octave, generator->persistence, 1.0,
                            _x, _y, _z, generator->seed * SEED_OFFSET)));
                    }

                    _z += _interval;
                }
                rb_ary_push(row, column);
                _y += _interval;
            }
            rb_ary_push(arr, row);
            _x += _interval;
        }
        return arr;
    }
}

/*
The main initialize function which receives the inputs persistence and octave.
*/
VALUE Perlin_Generator_init(const int argc, const VALUE *argv, const VALUE self)
{
    VALUE seed, persistence, octave, options;

    rb_scan_args(argc, argv, "31", &seed, &persistence, &octave, &options);
    if(NIL_P(options))
    {
       options = rb_hash_new();
    }
    else
    {
       Check_Type(options, T_HASH);
    }

    Perlin_Generator_set_seed(self, seed);
    Perlin_Generator_set_persistence(self, persistence);
    Perlin_Generator_set_octave(self, octave);
    Perlin_Generator_set_classic(self, rb_hash_aref(options, ID2SYM(rb_intern("classic"))));

    return self;
}