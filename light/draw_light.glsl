#pragma language glsl3

uniform Image bg_tex;
uniform Image obj_tex;
uniform Image light_obj_tex;
uniform Image light_bg_tex;
uniform float alpha_through;

const float reflectance = 0.1;

vec4 colorMix(vec4 s, vec4 t) {
  s.rgb *= 1 - t.a;
  // canvas' rgb default is mixed
  // s.rgb += t.rgb * t.a;
  s.rgb += t.rgb;
  s.a += t.a - t.a * s.a;

  return s;
}

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
  vec4 light_color = Texel(tex, tex_coords);
  vec4 bg_color = Texel(bg_tex, tex_coords);
  vec4 obj_color = Texel(obj_tex, tex_coords);
  vec4 light_obj_color = Texel(light_obj_tex, tex_coords);
  vec4 light_bg_color = Texel(light_bg_tex, tex_coords);

  bg_color.rgb *= light_color.rgb;
  bg_color.rgb += light_color.rgb * reflectance;
  bg_color = colorMix(bg_color, light_bg_color);

  if (light_obj_color.a > 0) {
    return colorMix(
      bg_color,
      vec4(light_obj_color.rgb + light_color.rgb * reflectance, light_obj_color.a)
    );
  } else if (obj_color.a > alpha_through)  {
    obj_color.rgb *= light_color.rgb;
    obj_color.rgb += light_color.rgb * reflectance;
  } else {
    obj_color.rgb += light_color.rgb * reflectance;
  }

  if (obj_color.a > 0) {
    return colorMix(bg_color, obj_color);
  } else {
    return bg_color;
  }
}
