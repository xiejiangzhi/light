#pragma language glsl3

uniform Image bg_tex;
uniform Image obj_tex;
uniform float alpha_through;

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
  vec4 light_color = Texel(tex, tex_coords);
  vec4 bg_color = Texel(bg_tex, tex_coords);
  vec4 obj_color = Texel(obj_tex, tex_coords);

  if (obj_color.a > alpha_through) {
    return vec4(obj_color.rgb * light_color.rgb, obj_color.a);
  } else if (obj_color.a > 0) {
    obj_color.rgb *= light_color.rgb;
    bg_color.rgb *=  light_color.rgb;
    return vec4(
      bg_color.rgb * (1 - obj_color.a) + obj_color.rgb * obj_color.a,
      bg_color.a + obj_color.a - bg_color.a * obj_color.a
    );
  } else {
    return vec4(bg_color.rgb * light_color.rgb, bg_color.a);
  }
}
