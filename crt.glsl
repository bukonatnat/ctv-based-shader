#version 300 es
precision mediump float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D u_tex;
uniform vec2 u_resolution;

// Strong but smooth CRT curvature
vec2 crtCurve(vec2 uv) {
    vec2 center = vec2(0.5);
    vec2 offset = uv - center;
    float curve = 0.15; // strong curve
    offset *= 1.0 + curve * (offset.x*offset.x + offset.y*offset.y);
    return center + offset;
}

// Soft scanlines (text-friendly)
float scanline(vec2 uv) {
    float lines = u_resolution.y; // one scanline per pixel
    return 0.92 + 0.08 * sin(uv.y * lines * 3.14159); // subtle
}

// Minimal RGB separation to avoid glitch
vec3 rgbShift(vec2 uv) {
    float shift = 0.0005; // tiny, almost invisible
    float r = texture(u_tex, uv + vec2(shift, 0.0)).r;
    float g = texture(u_tex, uv).g;
    float b = texture(u_tex, uv - vec2(shift, 0.0)).b;
    return vec3(r, g, b);
}

void main() {
    vec2 uv = crtCurve(v_texcoord);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

    vec3 color = rgbShift(uv);
    color *= scanline(uv);
    color *= 0.96; // slight dim for CRT feel

    // Gruvbox warm tint (subtle, clean)
    vec3 gruvbox = vec3(
        color.r * 1.05,
        color.g * 0.95,
        color.b * 0.7
    );

    fragColor = vec4(gruvbox, 1.0);
}

