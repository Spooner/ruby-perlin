/*
 * "Classic" Perlin noise generation.
 */

#ifndef CLASSIC_H
#define CLASSIC_H

#include <math.h>

extern long seed;

inline float perlin_interpolate(const float a, const float b, const float x)
{
    const float ft = x * M_PI;
    const float f = (1 - cos(ft)) * 0.5;
    return    a * (1 - f) + b * f;
}

inline float perlin_noise_2d(const int x, const int y)
{
    long n = x + y * 57;
    n = (n << 13) ^ n;
    return (1.0 - ((n * (n * n * 15731*seed + 789221*seed) + 1376312589*seed) & 0x7fffffff) / 1073741824.0);
}

inline float perlin_noise_3d(const int x, const int y, const int z)
{
    long n = x + y + z * 57;
    n = (n << 13) ^ n;
    return (1.0 - ((n * (n * n * 15731*seed + 789221*seed) + 1376312589*seed) & 0x7fffffff) / 1073741824.0);
}

float perlin_smooth_noise_2d(const int x, const int y);
float perlin_interpolated_noise_2d(const float x, const float y);
float perlin_octaves_2d(const float x, const float y, const float p, const float n);

float perlin_smooth_noise_3d(const int x, const int y, const int z);
float perlin_interpolated_noise_3d(const float x, const float y, const float z);
float perlin_octaves_3d(const float x, const float y, const float z, const float p, const float n);

#endif // CLASSIC_H