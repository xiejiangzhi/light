#define PI 3.14159265358

uniform vec2 resolution;

//sample from the 1D distance map
float sample(vec2 coord, float r, Image tex) {
  return step(r, Texel(tex, coord).r);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
  // Transform rectangular to polar coordinates.
  vec2 norm = texture_coords.st * 2.0 - 1.0;
  float theta = atan(norm.y, norm.x);
  float r = length(norm);
  float coord = (theta + PI) / (2.0 * PI);

  // The tex coordinate to sample our 1D lookup texture.
  //always 0.0 on y axis
  vec2 tc = vec2(coord, 0.0);

  // The center tex coord, which gives us hard shadows.
  float center = sample(tc, r, tex);

  // Multiply the blur amount by our distance from center.
  //this leads to more blurriness as the shadow "fades away"
  float blur = (1./resolution.x) * smoothstep(0., 1., r);

  // Use a simple gaussian blur.
  float sum = 0.0;
  sum += sample(vec2(tc.x - 4.0*blur, tc.y), r, tex) * 0.05;
  sum += sample(vec2(tc.x - 3.0*blur, tc.y), r, tex) * 0.09;
  sum += sample(vec2(tc.x - 2.0*blur, tc.y), r, tex) * 0.12;
  sum += sample(vec2(tc.x - 1.0*blur, tc.y), r, tex) * 0.15;

  sum += center * 0.16;
  sum += sample(vec2(tc.x + 1.0*blur, tc.y), r, tex) * 0.15;
  sum += sample(vec2(tc.x + 2.0*blur, tc.y), r, tex) * 0.12;
  sum += sample(vec2(tc.x + 3.0*blur, tc.y), r, tex) * 0.09;
  sum += sample(vec2(tc.x + 4.0*blur, tc.y), r, tex) * 0.05;

  // Sum of 1.0 -> in light, 0.0 -> in shadow.
  // Multiply the summed amount by our distance, which gives us a radial falloff.
  return color * vec4(vec3(1.0), sum * smoothstep(1.0, 0.0, r));
}
