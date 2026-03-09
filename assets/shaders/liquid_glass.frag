// Placeholder fragment shader for future liquid glass refinement.
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uMotionX;
uniform float uMotionY;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 motion = vec2(uMotionX, uMotionY) * 0.12;
  vec2 center = vec2(0.5, 0.35) + motion;
  float dist = distance(uv, center);
  float sheen = smoothstep(0.85, 0.08, dist);
  float caustic = 0.5 + 0.5 * sin((uv.x * 11.0) + (uv.y * 7.0) + (uTime * 0.9) + (uMotionX * 2.0));
  float ripple = 0.5 + 0.5 * cos((uv.y * 12.0) - (uTime * 1.4) + (uMotionY * 3.0));
  vec3 base = mix(vec3(1.0, 0.77, 0.49), vec3(0.43, 0.83, 0.82), uv.y + (uMotionY * 0.08));
  vec3 accent = mix(vec3(1.0, 0.96, 0.88), vec3(0.75, 0.92, 1.0), sheen);
  vec3 color = mix(base, accent, (sheen * 0.38) + (caustic * 0.14));
  float alpha = 0.09 + (sheen * 0.13) + (ripple * 0.08);
  fragColor = vec4(color, alpha);
}
