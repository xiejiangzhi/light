#define PI 3.14159265359

uniform vec2 resolution;
uniform Image scene_tex;

// use light (1, 0, 0) to item (0, 0, 1)
// item will get color: item * light + light * reflectance
const float reflectance = 0.3;

//sample from the 1D distance map
float sampleTex(Image tex, vec2 coord, float r) {
  return step(r, Texel(tex, coord).r);
}

float blurShadow(Image tex, vec2 tc, float r, float blur, float center) {
  float sum = 0.0;
  sum += sampleTex(tex, vec2(tc.x - 4.0*blur, tc.y), r) * 0.05;
  sum += sampleTex(tex, vec2(tc.x - 3.0*blur, tc.y), r) * 0.09;
  sum += sampleTex(tex, vec2(tc.x - 2.0*blur, tc.y), r) * 0.12;
  sum += sampleTex(tex, vec2(tc.x - 1.0*blur, tc.y), r) * 0.15;
  sum += center * 0.16;
  sum += sampleTex(tex, vec2(tc.x + 1.0*blur, tc.y), r) * 0.15;
  sum += sampleTex(tex, vec2(tc.x + 2.0*blur, tc.y), r) * 0.12;
  sum += sampleTex(tex, vec2(tc.x + 3.0*blur, tc.y), r) * 0.09;
  sum += sampleTex(tex, vec2(tc.x + 4.0*blur, tc.y), r) * 0.05;
    
  return sum;
}

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
  // Transform rectangular to polar coordinates.
  vec2 norm = tex_coords.st * 2.0 - 1.0;
  float theta = atan(norm.y, norm.x);
  float r = length(norm);
  float coord = (theta + PI) / (2.0 * PI);

  // The tex coordinate to sample our 1D lookup texture.
  //always 0.0 on y axis
  vec2 tc = vec2(coord, 0.0);


  // Multiply the blur amount by our distance from center.
  // this leads to more blurriness as the shadow "fades away"
  float blur = (1./resolution.x) * smoothstep(0., 1., r);

  float alpha = sampleTex(tex, tc, r);
  vec4 scene_col = Texel(scene_tex, vec2(tex_coords.x, 1 - tex_coords.y));

  if (scene_col.a == 0) {
    // Use a simple gaussian blur.
    alpha = blurShadow(tex, tc, r, blur, alpha);
  }

  // Sum of 1.0 -> in light, 0.0 -> in shadow.
  // Multiply the summed amount by our distance, which gives us a radial falloff.
  float sr = smoothstep(1.0, 0.0, r);
  if (scene_col.a > 0) {
    return scene_col * color * sr + color * reflectance * sr;
  } else {
    return vec4(color.rgb, color.a * alpha * sr);
  }
}
