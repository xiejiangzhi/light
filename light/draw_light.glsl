#pragma language glsl3

uniform Image bg_tex;
uniform vec4 env_color;

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
  vec4 light_color = Texel(tex, tex_coords);
  vec4 bg_color = Texel(bg_tex, tex_coords);

  if (light_color.r > 0 || light_color.g > 0 || light_color.b > 0) {
    if (bg_color.a > 0) {
      return vec4(bg_color.rgb * (env_color + light_color).rgb, bg_color.a);
    } else {
      return bg_color + vec4(light_color.rgb, (light_color.r + light_color.g + light_color.b) / 3.0);
    }
  } else {
    return vec4(bg_color.rgb * env_color.rgb, bg_color.a);
  }
}
