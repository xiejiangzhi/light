#define PI 3.14159265359

uniform vec2 resolution;
uniform float alpha_through;
uniform float source_radius;

vec4 effect(vec4 color, Image img, vec2 texture_coords, vec2 screen_coords) {
  float dist = 1.0;

  // Iterate through the occluder map's y-axis.
  for (float y = 0.0; y < resolution.y; y++) {
    // Rectangular to polar
    vec2 norm = vec2(texture_coords.s, y / resolution.y) * 2.0 - 1.0;
    float theta = PI * 1.5 + norm.x * PI;
    float r = (1.0 + norm.y) * 0.5;
    if (r <= source_radius) { continue; }

    //coord which we will sample from occlude map
    vec2 coord = vec2(-r * sin(theta), -r * cos(theta)) / 2.0 + 0.5;

    //sample the occlusion map
    vec4 data = Texel(img, coord);

    //the current distance is how far from the top we've come
    float dst = y / resolution.y;

    //if we've hit an opaque fragment (occluder), then get new distance
    //if the new distance is below the current, then we'll use that for our ray
    float caster = data.a;
    if (caster > alpha_through) {
      dist = min(dist, dst);
      break;
    }
  }

  return vec4(vec3(dist), 1.0);
}
