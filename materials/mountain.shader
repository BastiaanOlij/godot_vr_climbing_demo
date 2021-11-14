// NOTE: Shader automatically converted from Godot Engine 3.4.rc1's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform sampler2D texture_albedo_1 : hint_albedo;
uniform sampler2D texture_albedo_2 : hint_albedo;

uniform sampler2D texture_roughness_1 : hint_white;
uniform sampler2D texture_roughness_2 : hint_white;

uniform sampler2D texture_normal_1 : hint_normal;
uniform sampler2D texture_normal_2 : hint_normal;

uniform float uv_blend_sharpness = 1.0;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

varying vec3 uv_power_normal;
varying vec3 uv1_triplanar_pos;
varying vec3 uv2_triplanar_pos;

varying vec3 n;

void vertex() {
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv_power_normal=pow(abs(NORMAL),vec3(uv_blend_sharpness));
	uv_power_normal/=dot(uv_power_normal,vec3(1.0));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	uv2_triplanar_pos = VERTEX * uv2_scale + uv2_offset;
	uv2_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	
	n = (WORLD_MATRIX * vec4(NORMAL, 0.0)).rgb;
}


vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	vec4 albedo_tex_1 = triplanar_texture(texture_albedo_1,uv_power_normal,uv1_triplanar_pos);
	vec4 albedo_tex_2 = triplanar_texture(texture_albedo_2,uv_power_normal,uv2_triplanar_pos);

	vec4 roughness_tex_1 = triplanar_texture(texture_roughness_1,uv_power_normal,uv1_triplanar_pos);
	vec4 roughness_tex_2 = triplanar_texture(texture_roughness_2,uv_power_normal,uv2_triplanar_pos);

	vec4 normal_tex_1 = triplanar_texture(texture_normal_1,uv_power_normal,uv1_triplanar_pos);
	vec4 normal_tex_2 = triplanar_texture(texture_normal_2,uv_power_normal,uv2_triplanar_pos);

	float mix_factor = clamp(dot(n, vec3(0.0, 1.0, 0.0)) + 0.1, 0.0, 1.0);

	ALBEDO = mix(albedo_tex_1.rgb, albedo_tex_2.rgb, mix_factor);
	METALLIC = 0.0;
	ROUGHNESS = mix(roughness_tex_1.rgb, roughness_tex_2.rgb, mix_factor).r * 0.5 + 0.5;
	SPECULAR = 0.5;
	NORMALMAP = mix(normal_tex_1.rgb, normal_tex_2.rgb, mix_factor).rgb;
}
