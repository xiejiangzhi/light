#define PI 3.14159265359

uniform vec2 resolution;
uniform Image obj_tex;
uniform float alpha_through;
uniform float source_radius;

// use light (1, 0, 0) to item (0, 0, 1)
// item will get color: item * light + light * reflectance
const float reflectance = 0.3;

//sample from the 1D distance map
float sampleTex(Image tex, vec2 coord, float r) {
  return step(r, Texel(tex, coord).r);
}

float blurShadow(Image tex, vec2 tc, float dist, float blur, float shadow) {
  float sum = 0.0;
  sum += sampleTex(tex, vec2(tc.x - 4.0*blur, tc.y), dist) * 0.05;
  sum += sampleTex(tex, vec2(tc.x - 3.0*blur, tc.y), dist) * 0.09;
  sum += sampleTex(tex, vec2(tc.x - 2.0*blur, tc.y), dist) * 0.12;
  sum += sampleTex(tex, vec2(tc.x - 1.0*blur, tc.y), dist) * 0.15;
  sum += shadow * 0.16;
  sum += sampleTex(tex, vec2(tc.x + 1.0*blur, tc.y), dist) * 0.15;
  sum += sampleTex(tex, vec2(tc.x + 2.0*blur, tc.y), dist) * 0.12;
  sum += sampleTex(tex, vec2(tc.x + 3.0*blur, tc.y), dist) * 0.09;
  sum += sampleTex(tex, vec2(tc.x + 4.0*blur, tc.y), dist) * 0.05;
    
  return sum;
}

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
  // Transform rectangular to polar coordinates.
  vec2 norm = tex_coords.st * 2.0 - 1.0;
  float theta = atan(norm.y, norm.x);
  float dist = length(norm);
  float coord = (theta + PI) / (2.0 * PI);
  float light_rate = max(0.0, dist - source_radius) / (1.0 - source_radius);

  // The tex coordinate to sample our 1D lookup texture.
  //always 0.0 on y axis
  vec2 tc = vec2(coord, 0.0);


  // Multiply the blur amount by our distance from center.
  // this leads to more blurriness as the shadow "fades away"
  float blur = (1./resolution.x) * smoothstep(0., 1., light_rate);

  float shadow = sampleTex(tex, tc, dist);
  vec4 obj_col = Texel(obj_tex, vec2(tex_coords.x, 1 - tex_coords.y));

  if (obj_col.a == 0) {
    // Use a simple gaussian blur.
    shadow = blurShadow(tex, tc, dist, blur, shadow);
  }

  // Sum of 1.0 -> in light, 0.0 -> in shadow.
  // Multiply the summed amount by our distance, which gives us a radial falloff.
  float sr = smoothstep(1.0, 0.0, light_rate);
  if (obj_col.a > alpha_through) {
    return obj_col * color * sr + color * reflectance * sr;
  } else {
    return vec4(color.rgb, color.a * shadow * sr);
  }
}
