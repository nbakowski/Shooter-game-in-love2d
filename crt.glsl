#ifdef GL_ES
precision mediump float;
#endif

// Custom uniforms we will send from Lua
extern float time;
extern vec2 resolution;

vec2 curve(vec2 uv)
{
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1;	
    uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
    uv  = (uv / 2.0) + 0.5;
    uv = uv * 0.92 + 0.04;
    return uv;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 q = screen_coords / resolution;
    vec2 uv = curve(q);

    vec3 oricol = Texel(tex, q).rgb;
    vec3 col;

    float x = sin(0.3*time + uv.y*21.0)
            * sin(0.7*time + uv.y*29.0)
            * sin(0.3 + 0.33*time + uv.y*31.0)
            * 0.0017;

    col.r = Texel(tex, vec2(x+uv.x+0.001, uv.y+0.001)).r + 0.05;
    col.g = Texel(tex, vec2(x+uv.x+0.000, uv.y-0.002)).g + 0.05;
    col.b = Texel(tex, vec2(x+uv.x-0.002, uv.y+0.000)).b + 0.05;

    col.r += 0.08 * Texel(tex, 0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001, uv.y+0.001)).r;
    col.g += 0.05 * Texel(tex, 0.75*vec2(x-0.022, -0.020)+vec2(uv.x+0.000, uv.y-0.002)).g;
    col.b += 0.08 * Texel(tex, 0.75*vec2(x-0.020, -0.018)+vec2(uv.x-0.002, uv.y+0.000)).b;

    col = clamp(col*0.6 + 0.4*col*col, 0.0, 1.0);

    float vig = (16.0 * uv.x*uv.y * (1.0-uv.x) * (1.0-uv.y));
    col *= pow(vig, 0.3);

    col *= vec3(0.95, 1.05, 0.95);
    col *= 2.8;

    float scans = clamp(0.35 + 0.35 * sin(3.5*time + uv.y*resolution.y*1.5), 0.0, 1.0);
    float s = pow(scans, 1.7);
    col *= (0.4 + 0.7*s);

    col *= 1.0 + 0.01*sin(110.0*time);

    if (uv.x < 0.0 || uv.x > 1.0) col *= 0.0;
    if (uv.y < 0.0 || uv.y > 1.0) col *= 0.0;

    col *= 1.0 - 0.65 * vec3(clamp((mod(screen_coords.x, 2.0)-1.0)*2.0, 0.0, 1.0));

    return vec4(col, 1.0) * color;
}